import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Gets all users
  Future<List<UserModel>> getAllUsers();

  /// Gets a specific user by email
  Future<UserModel> getUserByEmail(String email);

  /// Gets users by role
  Future<List<UserModel>> getUsersByRole(String role);

  /// Gets users by team
  Future<List<UserModel>> getUsersByTeam(String team);

  /// Updates user information
  Future<UserModel> updateUser(String userEmail, Map<String, dynamic> updates);

  /// Deactivates a user
  Future<void> deactivateUser(String userEmail);

  /// Activates a user
  Future<void> activateUser(String userEmail);

  /// Gets active users
  Future<List<UserModel>> getActiveUsers();

  /// Gets inactive users
  Future<List<UserModel>> getInactiveUsers();

  /// Searches users by name
  Future<List<UserModel>> searchUsersByName(String name);

  /// Search users
  Future<List<UserModel>> searchUsers(String query);

  /// Create user
  Future<UserModel> createUser(UserModel user);

  /// Delete user
  Future<void> deleteUser(String email);

  /// Get user statistics
  Future<Map<String, int>> getUserStatistics();

  /// Get users count by role
  Future<Map<String, int>> getUsersCountByRole();

  /// Get users count by team
  Future<Map<String, int>> getUsersCountByTeam();

  /// Get recent users
  Future<List<UserModel>> getRecentUsers();

  /// Check if user exists
  Future<bool> userExists(String email);

  /// Get managers
  Future<List<UserModel>> getManagers();

  /// Get employees
  Future<List<UserModel>> getEmployees();

  /// Get team members
  Future<List<UserModel>> getTeamMembers(String team);

  /// Bulk update users
  Future<List<UserModel>> bulkUpdateUsers(
    List<String> userEmails,
    Map<String, dynamic> updates,
  );

  /// Export users to CSV
  Future<String> exportUsersToCSV({String? role, String? team, bool? isActive});

  /// Get user activity summary
  Future<Map<String, dynamic>> getUserActivitySummary(
    String email,
    DateTime? startDate,
    DateTime? endDate,
  );

  /// Get team activity summary
  Future<Map<String, dynamic>> getTeamActivitySummary(
    String team,
    DateTime? startDate,
    DateTime? endDate,
  );

  /// Get users stream
  Stream<List<UserModel>> getUsersStream({
    String? role,
    String? team,
    bool? isActive,
  });

  /// Get user stream by email
  Stream<UserModel> getUserStreamByEmail(String email);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const UserRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      // Get all users - we'll filter deleted ones during document processing
      final snapshot = await firestore.collection('users').get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            // Exclude users that are explicitly marked as deleted
            return !(data.containsKey('is_deleted') &&
                data['is_deleted'] == true);
          })
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get all users: $e');
    }
  }

  @override
  Future<UserModel> getUserByEmail(String email) async {
    try {
      // Query users collection by email field instead of using email as document ID
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: 'User not found');
      }

      return UserModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get users by role: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersByTeam(String team) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('team', isEqualTo: team)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get users by team: $e');
    }
  }

  @override
  Future<UserModel> updateUser(
    String userEmail,
    Map<String, dynamic> updates,
  ) async {
    try {
      // First, find the user document by email
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: 'User not found');
      }

      final userDoc = snapshot.docs.first;
      updates['updated_at'] = FieldValue.serverTimestamp();

      // Update the document using its actual ID
      await firestore.collection('users').doc(userDoc.id).update(updates);

      // Fetch the updated document
      final updatedDoc = await firestore
          .collection('users')
          .doc(userDoc.id)
          .get();

      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ServerException(message: 'Failed to update user: $e');
    }
  }

  @override
  Future<void> deactivateUser(String userEmail) async {
    try {
      // First, find the user document by email
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: 'User not found');
      }

      final userDoc = snapshot.docs.first;
      await firestore.collection('users').doc(userDoc.id).update({
        'is_active': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to deactivate user: $e');
    }
  }

  @override
  Future<void> activateUser(String userEmail) async {
    try {
      // First, find the user document by email
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: 'User not found');
      }

      final userDoc = snapshot.docs.first;
      await firestore.collection('users').doc(userDoc.id).update({
        'is_active': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to activate user: $e');
    }
  }

  @override
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('is_active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get active users: $e');
    }
  }

  @override
  Future<List<UserModel>> getInactiveUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('is_active', isEqualTo: false)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get inactive users: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsersByName(String name) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThan: '${name}z')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search users by name: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search users: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      // Check if user already exists
      final existingSnapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: user.userEmail)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        throw const ServerException(message: 'User already exists');
      }

      // Create new document with a generated ID using merge to preserve any existing fields
      final docRef = firestore.collection('users').doc();
      await docRef.set(user.toFirestore(), SetOptions(merge: true));

      // Fetch the created document
      final doc = await docRef.get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create user: $e');
    }
  }

  @override
  Future<void> deleteUser(String email) async {
    try {
      // Step 1: Find and delete the user document from Firestore
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: 'User not found');
      }

      final userDoc = snapshot.docs.first;

      // Step 2: Mark the user as deleted in Firestore instead of hard delete
      // This preserves data integrity and allows for potential recovery
      await firestore.collection('users').doc(userDoc.id).update({
        'is_active': false,
        'is_deleted': true,
        'deleted_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Step 3: Try to disable the user in Firebase Authentication
      // Note: This requires Firebase Admin SDK or Cloud Functions for proper implementation
      // For now, we'll create a deletion request that can be processed by admin
      await firestore.collection('user_deletion_requests').add({
        'user_email': email,
        'user_id': userDoc.id,
        'requested_at': FieldValue.serverTimestamp(),
        'status': 'pending',
        'requested_by': auth.currentUser?.email ?? 'system',
      });

      developer.log(
        'User marked as deleted in Firestore. Auth deletion request created.',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to delete user: $e');
    }
  }

  @override
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final snapshot = await firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      return {
        'total': users.length,
        'active': users.where((user) => user.isActive).length,
        'inactive': users.where((user) => !user.isActive).length,
        'managers': users.where((user) => user.role == 'Manager').length,
        'employees': users.where((user) => user.role == 'Employee').length,
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get user statistics: $e');
    }
  }

  @override
  Future<Map<String, int>> getUsersCountByRole() async {
    try {
      final snapshot = await firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      final Map<String, int> roleCount = {};
      for (final user in users) {
        roleCount[user.role] = (roleCount[user.role] ?? 0) + 1;
      }

      return roleCount;
    } catch (e) {
      throw ServerException(message: 'Failed to get users count by role: $e');
    }
  }

  @override
  Future<Map<String, int>> getUsersCountByTeam() async {
    try {
      final snapshot = await firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      final Map<String, int> teamCount = {};
      for (final user in users) {
        teamCount[user.team] = (teamCount[user.team] ?? 0) + 1;
      }

      return teamCount;
    } catch (e) {
      throw ServerException(message: 'Failed to get users count by team: $e');
    }
  }

  @override
  Future<List<UserModel>> getRecentUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get recent users: $e');
    }
  }

  @override
  Future<bool> userExists(String email) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(message: 'Failed to check if user exists: $e');
    }
  }

  @override
  Future<List<UserModel>> getManagers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Manager')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get managers: $e');
    }
  }

  @override
  Future<List<UserModel>> getEmployees() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get employees: $e');
    }
  }

  @override
  Future<List<UserModel>> getTeamMembers(String team) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('team', isEqualTo: team)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get team members: $e');
    }
  }

  @override
  Future<List<UserModel>> bulkUpdateUsers(
    List<String> userEmails,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      final batch = firestore.batch();

      for (final email in userEmails) {
        final userRef = firestore.collection('users').doc(email);
        batch.update(userRef, updates);
      }

      await batch.commit();

      // Get updated users
      final updatedUsers = <UserModel>[];
      for (final email in userEmails) {
        final doc = await firestore.collection('users').doc(email).get();
        if (doc.exists) {
          updatedUsers.add(UserModel.fromFirestore(doc));
        }
      }

      return updatedUsers;
    } catch (e) {
      throw ServerException(message: 'Failed to bulk update users: $e');
    }
  }

  @override
  Future<String> exportUsersToCSV({
    String? role,
    String? team,
    bool? isActive,
  }) async {
    try {
      Query query = firestore.collection('users');

      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }
      if (team != null) {
        query = query.where('team', isEqualTo: team);
      }
      if (isActive != null) {
        query = query.where('is_active', isEqualTo: isActive);
      }

      final snapshot = await query.get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Create CSV content
      String csvContent =
          'Email,Name,Role,Team,Phone,Active,Created At,Updated At\n';

      for (final user in users) {
        csvContent +=
            '${user.userEmail},${user.name},${user.role},${user.team},${user.phone ?? ''},${user.isActive},${user.createdAt},${user.createdAt}\n';
      }

      return csvContent;
    } catch (e) {
      throw ServerException(message: 'Failed to export users to CSV: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserActivitySummary(
    String email,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      // This would typically involve querying related collections like tasks, etc.
      // For now, return basic user info
      final user = await getUserByEmail(email);

      return {
        'user_email': email,
        'user_name': user.name,
        'user_role': user.role,
        'user_team': user.team,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'summary': 'User activity summary placeholder',
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get user activity summary: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTeamActivitySummary(
    String team,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final users = await getUsersByTeam(team);

      return {
        'team': team,
        'total_members': users.length,
        'active_members': users.where((user) => user.isActive).length,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'summary': 'Team activity summary placeholder',
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get team activity summary: $e');
    }
  }

  @override
  Stream<List<UserModel>> getUsersStream({
    String? role,
    String? team,
    bool? isActive,
  }) {
    try {
      Query query = firestore.collection('users');

      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }
      if (team != null) {
        query = query.where('team', isEqualTo: team);
      }
      if (isActive != null) {
        query = query.where('is_active', isEqualTo: isActive);
      }

      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get users stream: $e');
    }
  }

  @override
  Stream<UserModel> getUserStreamByEmail(String email) {
    try {
      return firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              throw const ServerException(message: 'User not found');
            }
            return UserModel.fromFirestore(snapshot.docs.first);
          });
    } catch (e) {
      throw ServerException(message: 'Failed to get user stream: $e');
    }
  }
}
