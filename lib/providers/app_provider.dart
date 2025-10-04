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

// LOGIN METHOD
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
        print('Firebase Auth failed: ${authError.code}');


        if (authError.code == 'user-not-found' ||
            authError.code == 'wrong-password' ||
            authError.code == 'invalid-credential') {
          // Try to find child account
          try {
            QuerySnapshot childQuery = await _firestore
                .collection('children')
                .where('email', isEqualTo: email.trim())
                .limit(1)
                .get();

            print('Child query results: ${childQuery.docs.length}');

            if (childQuery.docs.isNotEmpty) {
              Map<String, dynamic> childData =
                  childQuery.docs.first.data() as Map<String, dynamic>;
              String storedPasswordHash = childData['passwordHash'] ?? '';

              print('Stored hash: $storedPasswordHash');
              print('Input hash: ${_hashPassword(password)}');

              // Compare password hashes
              if (storedPasswordHash == _hashPassword(password)) {
                _isLoggedIn = true;
                _currentUserId = childQuery.docs.first.id;
                _currentUserName = childData['name'];
                _userType = UserType.child;
                _children = [];

                setLoading(false);
                clearError(); 
                notifyListeners();
                return true;
              } else {
                setError('Incorrect password');
                setLoading(false);
                return false;
              }
            } else {
              // No child found with this email either
              print('No child account found with email: $email');
              setError('Invalid Email or Password'); 
            }
          } catch (childError) {
            print('Error checking child accounts: $childError');
            setError('Error checking child account: ${childError.toString()}');
            setLoading(false);
            return false;
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

  // PARENT REGISTER METHOD
  Future<bool> parentRegister(
      String name, String email, String password) async {
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

  // ADD CHILD METHOD
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
      // Check if email already exists
      QuerySnapshot existingChild = await _firestore
          .collection('children')
          .where('email', isEqualTo: childEmail.trim())
          .limit(1)
          .get();

      if (existingChild.docs.isNotEmpty) {
        setError('A child account with this email already exists');
        setLoading(false);
        return false;
      }

      String childId = 'child_${DateTime.now().millisecondsSinceEpoch}';

      // Store password hash
      String passwordHash = _hashPassword(password);
      print('Creating child with password hash: $passwordHash'); // Debug

      await _firestore.collection('children').doc(childId).set({
        'name': childName,
        'email': childEmail.trim(),
        'age': age,
        'parentId': _currentUserId,
        'screenTimeLimit': screenTimeLimit,
        'restrictions': restrictions,
        'isActive': true,
        'screenTime': 0,
        'passwordHash': passwordHash,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('parents').doc(_currentUserId!).update({
        'childrenCount': FieldValue.increment(1),
      });

      await _loadChildren();
      setLoading(false);
      return true;
    } catch (e) {
      print('Error adding child: $e'); // Debug
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

      DocumentSnapshot parentDoc =
          await _firestore.collection('parents').doc(user.uid).get();

      if (parentDoc.exists) {
        Map<String, dynamic> parentData =
            parentDoc.data() as Map<String, dynamic>;
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

// UPDATE CHILD METHOD
  Future<bool> updateChild({
    required String childId,
    required String name,
    required String email,
    required int age,
    required int screenTimeLimit,
    required List<String> restrictions,
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can update child accounts');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Update child document in Firestore
      await _firestore.collection('children').doc(childId).update({
        'name': name,
        'email': email.trim(),
        'age': age,
        'screenTimeLimit': screenTimeLimit,
        'restrictions': restrictions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local children list
      final childIndex = _children.indexWhere((c) => c['id'] == childId);
      if (childIndex != -1) {
        _children[childIndex] = {
          ..._children[childIndex],
          'name': name,
          'email': email.trim(),
          'age': age,
          'screenTimeLimit': screenTimeLimit,
          'restrictions': restrictions,
        };
      }

      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update child: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

// DELETE CHILD METHOD (Basic)
  Future<bool> deleteChild(String childId) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can delete child accounts');
      return false;
    }

    try {
      // Delete child document from Firestore
      await _firestore.collection('children').doc(childId).delete();

      // Decrement parent's children count
      await _firestore.collection('parents').doc(_currentUserId!).update({
        'childrenCount': FieldValue.increment(-1),
      });

      // Remove from local list
      _children.removeWhere((child) => child['id'] == childId);
      notifyListeners();

      return true;
    } catch (e) {
      setError('Failed to delete child: ${e.toString()}');
      return false;
    }
  }

// DELETE CHILD COMPLETE (with all associated data)
  Future<bool> deleteChildComplete(String childId, String childEmail) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can delete child accounts');
      return false;
    }

    try {
      final childRef = _firestore.collection('children').doc(childId);

      try {
        final activityLogs = await childRef.collection('activityLogs').get();
        final batch = _firestore.batch();
        for (var doc in activityLogs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        // Continue
      }

      await childRef.delete();

      await _firestore.collection('parents').doc(_currentUserId!).update({
        'childrenCount': FieldValue.increment(-1),
      });

      await _firestore.collection('deletedAccounts').add({
        'childEmail': childEmail,
        'childId': childId,
        'parentId': _currentUserId,
        'deletedAt': FieldValue.serverTimestamp(),
        'reason': 'Parent deleted child account',
      });

      _children.removeWhere((child) => child['id'] == childId);
      notifyListeners();

      clearError();
      return true;
    } catch (e) {
      setError('Failed to delete child account: ${e.toString()}');
      return false;
    }
  }

// TOGGLE CHILD ACTIVE STATUS (Alternative to deletion - safer option)
  Future<bool> toggleChildStatus(String childId, bool isActive) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can modify child accounts');
      return false;
    }

    try {
      await _firestore.collection('children').doc(childId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      final childIndex = _children.indexWhere((c) => c['id'] == childId);
      if (childIndex != -1) {
        _children[childIndex]['isActive'] = isActive;
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update child status: ${e.toString()}');
      return false;
    }
  }

// UPDATE CHILD SCREEN TIME (for tracking usage)
  Future<bool> updateChildScreenTime(String childId, int minutesUsed) async {
    try {
      await _firestore.collection('children').doc(childId).update({
        'screenTime': FieldValue.increment(minutesUsed),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      final childIndex = _children.indexWhere((c) => c['id'] == childId);
      if (childIndex != -1) {
        _children[childIndex]['screenTime'] =
            (_children[childIndex]['screenTime'] ?? 0) + minutesUsed;
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update screen time: ${e.toString()}');
      return false;
    }
  }

// RESET DAILY SCREEN TIME (call this at midnight or on demand)
  Future<bool> resetChildScreenTime(String childId) async {
    try {
      await _firestore.collection('children').doc(childId).update({
        'screenTime': 0,
        'lastResetAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      final childIndex = _children.indexWhere((c) => c['id'] == childId);
      if (childIndex != -1) {
        _children[childIndex]['screenTime'] = 0;
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to reset screen time: ${e.toString()}');
      return false;
    }
  }

// RESET ALL CHILDREN SCREEN TIME
  Future<void> resetAllChildrenScreenTime() async {
    if (!isParent || _currentUserId == null) return;

    try {
      final batch = _firestore.batch();

      for (var child in _children) {
        final childRef = _firestore.collection('children').doc(child['id']);
        batch.update(childRef, {
          'screenTime': 0,
          'lastResetAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update local list
      for (var i = 0; i < _children.length; i++) {
        _children[i]['screenTime'] = 0;
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to reset screen times: ${e.toString()}');
    }
  }

// GET CHILD DETAILS (with real-time updates)
  Future<Map<String, dynamic>?> getChildDetails(String childId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('children').doc(childId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      setError('Failed to get child details: ${e.toString()}');
      return null;
    }
  }

// BULK UPDATE RESTRICTIONS (for multiple children at once)
  Future<bool> bulkUpdateRestrictions(
    List<String> childIds,
    List<String> restrictions,
  ) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can update restrictions');
      return false;
    }

    try {
      final batch = _firestore.batch();

      for (var childId in childIds) {
        final childRef = _firestore.collection('children').doc(childId);
        batch.update(childRef, {
          'restrictions': restrictions,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      await _loadChildren(); // Refresh local data

      return true;
    } catch (e) {
      setError('Failed to update restrictions: ${e.toString()}');
      return false;
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
        return 'Email or Password is Incorrect';
    }
  }

  String _hashPassword(String password) {
    return password.hashCode.toString();
  }
}
