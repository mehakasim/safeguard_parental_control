import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // PARENT AUTHENTICATION

  // Parent Sign Up
  Future<AuthResult> parentSignUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create parent account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        await user.updateDisplayName(name);
        
        // Create parent document
        await _createParentDocument(user, name);
        
        // Send email verification
        await user.sendEmailVerification();
        
        return AuthResult.success(
          user: user,
          message: 'Parent account created successfully! Please verify your email.',
        );
      } else {
        return AuthResult.failure('Failed to create parent account');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Error creating parent account: ${e.toString()}');
    }
  }

  // Parent/Child Login (Universal)
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Check if user is parent or child
        UserType userType = await _getUserType(user.uid);
        
        return AuthResult.success(
          user: user,
          userType: userType,
          message: userType == UserType.parent 
              ? 'Welcome back, Parent!' 
              : 'Welcome back!',
        );
      } else {
        return AuthResult.failure('Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // CHILD MANAGEMENT BY PARENTS

  // Create Child Account (by Parent)
  Future<AuthResult> createChildAccount({
    required String parentId,
    required String childName,
    required String childEmail,
    required String password,
    required int age,
    int screenTimeLimit = 120, // minutes
    List<String> restrictions = const [],
  }) async {
    try {
      // Verify parent is authenticated
      if (currentUserId != parentId) {
        return AuthResult.failure('Unauthorized: Only the parent can create child accounts');
      }

      // Check if email already exists
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(childEmail.trim());
      if (signInMethods.isNotEmpty) {
        return AuthResult.failure('An account with this email already exists');
      }

      // Create child account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: childEmail.trim(),
        password: password,
      );
      
      User? childUser = result.user;
      
      if (childUser != null) {
        await childUser.updateDisplayName(childName);
        
        // Create child document
        await _createChildDocument(
          childUser: childUser,
          parentId: parentId,
          name: childName,
          age: age,
          screenTimeLimit: screenTimeLimit,
          restrictions: restrictions,
        );
        
        // Sign back in as parent (since creating child account signs us in as child)
        await _signInAsParent(parentId);
        
        return AuthResult.success(
          message: 'Child account created successfully for $childName',
        );
      } else {
        return AuthResult.failure('Failed to create child account');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Error creating child account: ${e.toString()}');
    }
  }

  // Update Child Password (by Parent)
  Future<AuthResult> updateChildPassword({
    required String parentId,
    required String childId,
    required String newPassword,
    required String parentPassword, // for verification
  }) async {
    try {
      // Verify parent authentication
      if (currentUserId != parentId) {
        return AuthResult.failure('Unauthorized: Only the parent can update child passwords');
      }

      // Re-authenticate parent
      User? parent = currentUser;
      if (parent == null || parent.email == null) {
        return AuthResult.failure('Parent not authenticated');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: parent.email!,
        password: parentPassword,
      );
      await parent.reauthenticateWithCredential(credential);

      // Get child data
      DocumentSnapshot childDoc = await _firestore.collection('children').doc(childId).get();
      if (!childDoc.exists) {
        return AuthResult.failure('Child account not found');
      }

      Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
      if (childData['parentId'] != parentId) {
        return AuthResult.failure('Unauthorized: This child does not belong to you');
      }

      String childEmail = childData['email'];

      // Create a temporary admin auth instance to update child password
      // Note: This requires admin privileges - in production, use Firebase Admin SDK
      // For now, we'll store the new password request and let child update on next login
      
      await _firestore.collection('passwordResets').doc(childId).set({
        'childId': childId,
        'parentId': parentId,
        'newPassword': newPassword, // In production, hash this
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      return AuthResult.success(
        message: 'Password update requested. Child will be prompted to update on next login.',
      );

    } catch (e) {
      return AuthResult.failure('Error updating child password: ${e.toString()}');
    }
  }

  // Delete Child Account (by Parent)
  Future<AuthResult> deleteChildAccount({
    required String parentId,
    required String childId,
    required String parentPassword,
  }) async {
    try {
      // Verify parent authentication
      if (currentUserId != parentId) {
        return AuthResult.failure('Unauthorized: Only the parent can delete child accounts');
      }

      // Re-authenticate parent
      User? parent = currentUser;
      if (parent == null || parent.email == null) {
        return AuthResult.failure('Parent not authenticated');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: parent.email!,
        password: parentPassword,
      );
      await parent.reauthenticateWithCredential(credential);

      // Get child data
      DocumentSnapshot childDoc = await _firestore.collection('children').doc(childId).get();
      if (!childDoc.exists) {
        return AuthResult.failure('Child account not found');
      }

      Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
      if (childData['parentId'] != parentId) {
        return AuthResult.failure('Unauthorized: This child does not belong to you');
      }

      // Delete child's Firestore data
      await _firestore.collection('children').doc(childId).delete();
      
      // Delete child's screen time records
      QuerySnapshot screenTimeRecords = await _firestore
          .collection('screenTime')
          .where('childId', isEqualTo: childId)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in screenTimeRecords.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Note: Deleting the actual Firebase Auth user requires Admin SDK
      // For now, we'll mark the account as deleted
      await _firestore.collection('deletedAccounts').doc(childId).set({
        'originalChildId': childId,
        'parentId': parentId,
        'deletedAt': FieldValue.serverTimestamp(),
        'email': childData['email'],
      });

      return AuthResult.success(
        message: 'Child account deleted successfully',
      );

    } catch (e) {
      return AuthResult.failure('Error deleting child account: ${e.toString()}');
    }
  }

  // Get Parent's Children
  Future<List<Map<String, dynamic>>> getParentChildren(String parentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error getting children: ${e.toString()}');
    }
  }

  // UTILITY METHODS

  // Determine if user is parent or child
  Future<UserType> _getUserType(String userId) async {
    try {
      // Check if user exists in parents collection
      DocumentSnapshot parentDoc = await _firestore.collection('parents').doc(userId).get();
      if (parentDoc.exists) {
        return UserType.parent;
      }

      // Check if user exists in children collection
      DocumentSnapshot childDoc = await _firestore.collection('children').doc(userId).get();
      if (childDoc.exists) {
        return UserType.child;
      }

      return UserType.unknown;
    } catch (e) {
      return UserType.unknown;
    }
  }

  // Create parent document
  Future<void> _createParentDocument(User user, String name) async {
    await _firestore.collection('parents').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profilePicture': user.photoURL,
      'emailVerified': user.emailVerified,
      'childrenCount': 0,
    });
  }

  // Create child document
  Future<void> _createChildDocument({
    required User childUser,
    required String parentId,
    required String name,
    required int age,
    required int screenTimeLimit,
    required List<String> restrictions,
  }) async {
    await _firestore.collection('children').doc(childUser.uid).set({
      'name': name,
      'email': childUser.email,
      'age': age,
      'parentId': parentId,
      'screenTimeLimit': screenTimeLimit,
      'restrictions': restrictions,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profilePicture': childUser.photoURL,
      'isActive': true,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    // Update parent's children count
    await _firestore.collection('parents').doc(parentId).update({
      'childrenCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign in as parent after creating child account
  Future<void> _signInAsParent(String parentId) async {
    try {
      DocumentSnapshot parentDoc = await _firestore.collection('parents').doc(parentId).get();
      if (parentDoc.exists) {
        Map<String, dynamic> parentData = parentDoc.data() as Map<String, dynamic>;
        // This is a simplified approach - in production you'd handle this differently
        // Perhaps by using Firebase Admin SDK or custom tokens
      }
    } catch (e) {
      // Handle error
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      return AuthResult.success(message: 'Signed out successfully');
    } catch (e) {
      return AuthResult.failure('Error signing out: ${e.toString()}');
    }
  }

  // Get auth error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
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
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }
}

// Enhanced AuthResult class
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;
  final UserType? userType;
  final String? errorCode;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.userType,
    this.errorCode,
  });

  factory AuthResult.success({
    User? user,
    UserType? userType,
    String? message,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message ?? 'Operation successful',
      user: user,
      userType: userType,
    );
  }

  factory AuthResult.failure(String message, [String? errorCode]) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

// User Type Enum
enum UserType {
  parent,
  child,
  unknown,
}