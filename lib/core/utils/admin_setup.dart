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

      print('Creating admin user in Firebase Auth...');
      UserCredential? userCredential;

      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('Admin email already exists in Firebase Auth');
          print('Trying to sign in with existing credentials...');

          try {
            userCredential = await firebaseAuth.signInWithEmailAndPassword(
              email: adminEmail,
              password: adminPassword,
            );
            print('Successfully signed in with existing admin account');
          } catch (signInError) {
            print('Could not sign in with admin credentials: $signInError');
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

      print('Admin user authenticated with UID: ${userCredential.user!.uid}');

      // Now that we're authenticated, try to create/update the Firestore document
      try {
        // Check if user document already exists
        final existingDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (existingDoc.exists) {
          print('Admin user document already exists in Firestore');

          // Update to ensure it has admin role
          await firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'role': 'Admin'});

          print('Ensured admin user has Admin role');
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

        print('Initial admin user created successfully');
        print('Email: $adminEmail');
        print('Password: $adminPassword');
        print('UID: ${userCredential.user!.uid}');
        print('You can now login with these credentials');
      } catch (firestoreError) {
        print('Firestore operation failed: $firestoreError');

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
      print('Error creating admin user: $e');
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

      print('User $userEmail promoted to Admin successfully');
    } catch (e) {
      print('Error promoting user to admin: $e');
    }
  }
}
