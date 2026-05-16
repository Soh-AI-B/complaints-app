import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Signs in user with email and password
  /// Returns [UserModel] if successful
  /// Throws [ServerException] on failure
  Future<UserModel> signIn(String email, String password);

  /// Registers a new user with email and password
  /// Returns [UserModel] if successful
  /// Throws [ServerException] on failure
  Future<UserModel> signUp(
    String email,
    String password,
    String name,
    String role,
    String team,
  );

  /// Signs out the current user
  /// Throws [ServerException] on failure
  Future<void> signOut();

  /// Gets the currently authenticated user
  /// Returns [UserModel] if user is authenticated
  /// Throws [ServerException] if user is not authenticated
  Future<UserModel> getCurrentUser();

  /// Updates user profile information
  /// Returns [UserModel] with updated information
  /// Throws [ServerException] on failure
  Future<UserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  );

  /// Sends password reset email
  /// Throws [ServerException] on failure
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      developer.log('DEBUG: Starting sign in for $email');

      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        developer.log('DEBUG: Firebase auth failed - no user returned');
        throw const ServerException(message: 'Sign in failed');
      }

      developer.log(
        'DEBUG: Firebase auth successful, user ID: ${credential.user!.uid}',
      );

      // First, try to get user data from Firestore using UID
      developer.log(
        'DEBUG: Fetching user document from Firestore using UID...',
      );
      final userDocByUid = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDocByUid.exists) {
        developer.log(
          'DEBUG: User document found by UID, converting to UserModel...',
        );
        _ensureAccountCanAccess(userDocByUid.data() ?? {});
        return UserModel.fromFirestore(userDocByUid);
      }

      // If not found by UID, try to find by email (for users created via AdminSetup)
      developer.log(
        'DEBUG: User document not found by UID, searching by email...',
      );
      final userQueryByEmail = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .get();

      if (userQueryByEmail.docs.isNotEmpty) {
        developer.log(
          'DEBUG: User document found by email, migrating to UID-based document...',
        );
        final existingUserDoc = userQueryByEmail.docs.first;
        final userData = existingUserDoc.data();
        _ensureAccountCanAccess(userData);

        // Create a new document using the Firebase Auth UID
        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        // Delete the old document (optional, but keeps database clean)
        await existingUserDoc.reference.delete();

        developer.log('DEBUG: User migrated to UID-based document');
        return UserModel.fromFirestore(
          await firestore.collection('users').doc(credential.user!.uid).get(),
        );
      }

      // If user doesn't exist in Firestore at all, this shouldn't happen for login
      // This indicates the user needs to register first
      developer.log('DEBUG: No user document found in Firestore for $email');
      throw const ServerException(
        message:
            'User account not found. Please register first or contact administrator.',
      );
    } on FirebaseAuthException catch (e) {
      developer.log('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      throw ServerException(message: _mapFirebaseAuthException(e));
    } on ServerException {
      rethrow;
    } catch (e) {
      developer.log('DEBUG: Unexpected error in signIn: $e');
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String name,
    String role,
    String team,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const ServerException(message: 'Sign up failed');
      }

      // Create user document in Firestore
      final userModel = UserModel(
        userEmail: email,
        name: name,
        role: role,
        team: team,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _mapFirebaseAuthException(e));
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: 'Sign out failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'No authenticated user found');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw const ServerException(message: 'User data not found');
      }

      _ensureAccountCanAccess(userDoc.data() ?? {});
      return UserModel.fromFirestore(userDoc);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get current user: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection('users').doc(userId).update(updates);

      // Get updated user data
      final userDoc = await firestore.collection('users').doc(userId).get();

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _mapFirebaseAuthException(e));
    } catch (e) {
      throw ServerException(message: 'Failed to send password reset email: $e');
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  void _ensureAccountCanAccess(Map<String, dynamic> data) {
    if (data['is_deleted'] == true) {
      throw const ServerException(
        message:
            'This account has been removed. Please contact an administrator.',
      );
    }

    if (data['is_active'] == false) {
      throw const ServerException(
        message:
            'This account is deactivated. Please contact an administrator.',
      );
    }
  }
}
