import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  // Login with email and password
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  // Register new user
  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String team,
    String? phone,
  });

  // Logout current user
  Future<Either<Failure, void>> logout();

  // Get current authenticated user
  Future<Either<Failure, AppUser>> getCurrentUser();

  // Check if user is authenticated
  Future<bool> isAuthenticated();

  // Refresh authentication token
  Future<Either<Failure, AppUser>> refreshToken();

  // Reset password
  Future<Either<Failure, void>> resetPassword({required String email});

  // Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Update user profile
  Future<Either<Failure, AppUser>> updateProfile({
    String? name,
    String? phone,
    String? team,
  });

  // Delete account
  Future<Either<Failure, void>> deleteAccount();

  // Get authentication status stream
  Stream<AppUser> get authStateChanges;

  // Verify email
  Future<Either<Failure, void>> verifyEmail();

  // Resend verification email
  Future<Either<Failure, void>> resendVerificationEmail();
}
