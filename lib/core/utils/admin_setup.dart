import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

class AdminSetup {
  static const String adminEmail = 'admin@complaints.com';
  static const String adminPassword = 'admin123456'; // Default password
  static const String adminName = 'System Administrator';

  /// Creates the initial admin user in both Firebase Auth and Firestore
  /// This should only be called once during initial setup
  static Future<void> createInitialAdmin() async {
    try {
      final firebaseAuth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      developer.log('Creating admin user in Firebase Auth...');
      UserCredential? userCredential;

      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          developer.log('Admin email already exists in Firebase Auth');
          developer.log('Trying to sign in with existing credentials...');

          try {
            userCredential = await firebaseAuth.signInWithEmailAndPassword(
              email: adminEmail,
              password: adminPassword,
            );
            developer.log('Successfully signed in with existing admin account');
          } catch (signInError) {
            developer.log(
              'Could not sign in with admin credentials: $signInError',
            );
            throw Exception(
              'Admin account exists but password might be different. '
              'Please check Firebase Authentication console or try logging in manually.',
            );
          }
        } else {
          rethrow;
        }
      }

      if (userCredential.user == null) {
        throw Exception('Failed to create or authenticate admin user');
      }

      developer.log(
        'Admin user authenticated with UID: ${userCredential.user!.uid}',
      );

      // Now that we're authenticated, try to create/update the Firestore document
      try {
        // Check if user document already exists
        final existingDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (existingDoc.exists) {
          developer.log('Admin user document already exists in Firestore');

          // Update to ensure it has admin role
          await firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'role': 'Admin'});

          developer.log('Ensured admin user has Admin role');
          return;
        }

        // Create new admin user document
        final adminUser = UserModel(
          userEmail: adminEmail,
          name: adminName,
          role: 'Admin',
          team: 'Administration',
          phone: '+1234567890',
          createdAt: DateTime.now(),
          isActive: true,
        );

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(adminUser.toFirestore(), SetOptions(merge: true));

        developer.log('Initial admin user created successfully');
        developer.log('Email: $adminEmail');
        developer.log('Password: $adminPassword');
        developer.log('UID: ${userCredential.user!.uid}');
        developer.log('You can now login with these credentials');
      } catch (firestoreError) {
        developer.log('Firestore operation failed: $firestoreError');

        if (firestoreError.toString().contains('permission-denied')) {
          throw Exception(
            'Firestore permissions error. Please update your Firestore Security Rules to allow authenticated users to read/write the users collection. '
            'Add this rule: allow read, write: if request.auth != null;',
          );
        } else {
          throw Exception('Failed to create user document: $firestoreError');
        }
      }
    } catch (e) {
      developer.log('Error creating admin user: $e');
      rethrow;
    }
  }

  /// Utility function to promote an existing user to admin
  static Future<void> promoteUserToAdmin(String userEmail) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final userQuery = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = userQuery.docs.first;
      await userDoc.reference.update({'role': 'Admin'});

      developer.log('User $userEmail promoted to Admin successfully');
    } catch (e) {
      developer.log('Error promoting user to admin: $e');
    }
  }
}
