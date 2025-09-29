import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { parent, child, unknown }

class AppProvider with ChangeNotifier {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current user state
  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserName;
  UserType? _userType;
  
  // App state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Children management (for parents)
  List<Map<String, dynamic>> _children = [];
  bool _childrenLoading = false;
  
  // Getters (same as before)
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  UserType? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get children => _children;
  bool get childrenLoading => _childrenLoading;
  
  bool get isParent => _userType == UserType.parent;
  bool get isChild => _userType == UserType.child;

  // Initialize Firebase Auth listener
  void initializeAuth() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _resetUserState();
      } else {
        _loadUserData(user);
      }
    });
  }

  // KEEP YOUR EXISTING LOGIN METHOD NAME - just replace the implementation
  Future<bool> login(String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // Try Firebase Auth first (for parents)
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        
        if (result.user != null) {
          await _loadUserData(result.user!);
          setLoading(false);
          return true;
        }
      } on FirebaseAuthException catch (authError) {
        // If Firebase Auth fails, check if it's a child account in Firestore
        if (authError.code == 'user-not-found') {
          QuerySnapshot childQuery = await _firestore
              .collection('children')
              .where('email', isEqualTo: email.trim())
              .limit(1)
              .get();
              
          if (childQuery.docs.isNotEmpty) {
            Map<String, dynamic> childData = childQuery.docs.first.data() as Map<String, dynamic>;
            String storedPasswordHash = childData['passwordHash'] ?? '';
            
            if (storedPasswordHash == _hashPassword(password)) {
              _isLoggedIn = true;
              _currentUserId = childQuery.docs.first.id;
              _currentUserName = childData['name'];
              _userType = UserType.child;
              _children = [];
              
              setLoading(false);
              notifyListeners();
              return true;
            } else {
              setError('Incorrect password');
              setLoading(false);
              return false;
            }
          }
        }
        throw authError;
      }
      
      setError('Login failed');
      setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      setError(_getFirebaseErrorMessage(e));
      setLoading(false);
      return false;
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
  
  // KEEP YOUR EXISTING PARENT REGISTER METHOD NAME
  Future<bool> parentRegister(String name, String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        
        await _firestore.collection('parents').doc(result.user!.uid).set({
          'name': name,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'childrenCount': 0,
        });
        
        _isLoggedIn = true;
        _currentUserId = result.user!.uid;
        _currentUserName = name;
        _userType = UserType.parent;
        _children = [];
        
        setLoading(false);
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      setError(_getFirebaseErrorMessage(e));
      setLoading(false);
      return false;
    }
  }

  // KEEP YOUR EXISTING ADD CHILD METHOD NAME
  Future<bool> addChildAccount({
    required String childName,
    required String childEmail,
    required String password,
    required int age,
    int screenTimeLimit = 120,
    List<String> restrictions = const [],
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can add child accounts');
      return false;
    }

    setLoading(true);
    clearError();
    
    try {
      String childId = 'child_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('children').doc(childId).set({
        'name': childName,
        'email': childEmail.trim(),
        'age': age,
        'parentId': _currentUserId,
        'screenTimeLimit': screenTimeLimit,
        'restrictions': restrictions,
        'isActive': true,
        'screenTime': 0,
        'passwordHash': _hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('parents').doc(_currentUserId!).update({
        'childrenCount': FieldValue.increment(1),
      });

      await _loadChildren();
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to add child: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Load children from Firestore
  Future<void> _loadChildren() async {
    if (!isParent || _currentUserId == null) return;

    _childrenLoading = true;
    notifyListeners();
    
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: _currentUserId)
          .get();

      _children = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      setError('Failed to load children: ${e.toString()}');
    }
    
    _childrenLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData(User user) async {
    try {
      _currentUserId = user.uid;
      
      DocumentSnapshot parentDoc = await _firestore.collection('parents').doc(user.uid).get();
      
      if (parentDoc.exists) {
        Map<String, dynamic> parentData = parentDoc.data() as Map<String, dynamic>;
        _currentUserName = parentData['name'] ?? user.displayName;
        _userType = UserType.parent;
        _isLoggedIn = true;
        await _loadChildren();
      }
      
      notifyListeners();
    } catch (e) {
      setError('Failed to load user data: ${e.toString()}');
    }
  }

  void _resetUserState() {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _userType = null;
    _children = [];
    notifyListeners();
  }

  Future<void> refreshChildren() async {
    if (!isParent) return;
    await _loadChildren();
  }

  Map<String, dynamic>? getChildById(String childId) {
    try {
      return _children.firstWhere((child) => child['id'] == childId);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
    }
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper methods (keep all your existing helper methods)
  int getChildScreenTimeToday(String childId) {
    final child = getChildById(childId);
    return child?['screenTime'] ?? 0;
  }

  int getChildScreenTimeLimit(String childId) {
    final child = getChildById(childId);
    return child?['screenTimeLimit'] ?? 120;
  }

  bool hasChildExceededScreenTime(String childId) {
    final screenTime = getChildScreenTimeToday(childId);
    final limit = getChildScreenTimeLimit(childId);
    return screenTime >= limit;
  }

  double getChildScreenTimeProgress(String childId) {
    final screenTime = getChildScreenTimeToday(childId);
    final limit = getChildScreenTimeLimit(childId);
    if (limit == 0) return 0.0;
    return (screenTime / limit).clamp(0.0, 1.0);
  }

  String formatScreenTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }

  String _hashPassword(String password) {
    return password.hashCode.toString();
  }
}