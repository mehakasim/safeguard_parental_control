// lib/providers/admin_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoggedIn = false;
  String? _adminId;
  String? _adminName;
  String? _adminRole;
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics
  int _totalParents = 0;
  int _totalChildren = 0;
  int _activeChildren = 0;
  int _deletedAccounts = 0;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get adminId => _adminId;
  String? get adminName => _adminName;
  String? get adminRole => _adminRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalParents => _totalParents;
  int get totalChildren => _totalChildren;
  int get activeChildren => _activeChildren;
  int get deletedAccounts => _deletedAccounts;

  // Admin Login
  Future<bool> adminLogin(String email, String password) async {
    setLoading(true);
    clearError();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Check if user is an admin
        DocumentSnapshot adminDoc =
            await _firestore.collection('admin').doc(result.user!.uid).get();

        if (adminDoc.exists) {
          Map<String, dynamic> adminData =
              adminDoc.data() as Map<String, dynamic>;

          if (adminData['isActive'] == true) {
            _isLoggedIn = true;
            _adminId = result.user!.uid;
            _adminName = adminData['name'];
            _adminRole = adminData['role'];

            // Update last login
            await _firestore.collection('admin').doc(_adminId).update({
              'lastLoginAt': FieldValue.serverTimestamp(),
            });

            await loadStatistics();
            setLoading(false);
            notifyListeners();
            return true;
          } else {
            await _auth.signOut();
            setError('Your admin account has been deactivated');
            setLoading(false);
            return false;
          }
        } else {
          await _auth.signOut();
          setError('You do not have admin access');
          setLoading(false);
          return false;
        }
      }
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

  // Load Statistics
  Future<void> loadStatistics() async {
    try {
      // Count parents
      QuerySnapshot parentsSnapshot =
          await _firestore.collection('parents').get();
      _totalParents = parentsSnapshot.docs.length;

      // Count children
      QuerySnapshot childrenSnapshot =
          await _firestore.collection('children').get();
      _totalChildren = childrenSnapshot.docs.length;

      // Count active children
      QuerySnapshot activeChildrenSnapshot = await _firestore
          .collection('children')
          .where('isActive', isEqualTo: true)
          .get();
      _activeChildren = activeChildrenSnapshot.docs.length;

      // Count deleted accounts
      QuerySnapshot deletedSnapshot =
          await _firestore.collection('deletedAccounts').get();
      _deletedAccounts = deletedSnapshot.docs.length;

      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Get all parents
  Future<List<Map<String, dynamic>>> getAllParents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('parents').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      setError('Failed to load parents: ${e.toString()}');
      return [];
    }
  }

  // Get all children
  Future<List<Map<String, dynamic>>> getAllChildren() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('children').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      setError('Failed to load children: ${e.toString()}');
      return [];
    }
  }

  // Get children by parent
  Future<List<Map<String, dynamic>>> getChildrenByParent(
      String parentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      setError('Failed to load children: ${e.toString()}');
      return [];
    }
  }

  // Delete parent account (admin action)
  Future<bool> deleteParentAccount(String parentId) async {
    if (!_isLoggedIn || _adminRole != 'admin') {
      setError('Unauthorized action');
      return false;
    }

    try {
      // Get all children of this parent
      QuerySnapshot children = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .get();

      // Delete all children
      final batch = _firestore.batch();
      for (var doc in children.docs) {
        batch.delete(doc.reference);

        // Log deletion
        batch.set(_firestore.collection('deletedAccounts').doc(), {
          'childId': doc.id,
          'childEmail':
              doc.data() != null ? (doc.data() as Map)['email'] : null,
          'parentId': parentId,
          'deletedBy': 'admin',
          'adminId': _adminId,
          'deletedAt': FieldValue.serverTimestamp(),
          'reason': 'Parent account deleted by admin',
        });
      }

      // Delete parent document
      batch.delete(_firestore.collection('parents').doc(parentId));

      // Log parent deletion
      batch.set(_firestore.collection('deletedAccounts').doc(), {
        'parentId': parentId,
        'deletedBy': 'admin',
        'adminId': _adminId,
        'deletedAt': FieldValue.serverTimestamp(),
        'reason': 'Account deleted by admin',
      });

      await batch.commit();
      await loadStatistics();

      return true;
    } catch (e) {
      setError('Failed to delete parent account: ${e.toString()}');
      return false;
    }
  }

  // Toggle child active status (admin action)
  Future<bool> toggleChildStatus(String childId, bool isActive) async {
    if (!_isLoggedIn) {
      setError('Unauthorized action');
      return false;
    }

    try {
      await _firestore.collection('children').doc(childId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'admin',
        'adminId': _adminId,
      });

      await loadStatistics();
      return true;
    } catch (e) {
      setError('Failed to update child status: ${e.toString()}');
      return false;
    }
  }

  // Format Screen Time

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

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      _adminId = null;
      _adminName = null;
      _adminRole = null;
      _totalParents = 0;
      _totalChildren = 0;
      _activeChildren = 0;
      _deletedAccounts = 0;
      notifyListeners();
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

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
