import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth/auth_local_datasource.dart';
import '../datasources/auth/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signIn(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(_userModelToAppUser(userModel));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String team,
    String? phone,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signUp(
          email,
          password,
          name,
          role,
          team,
        );
        await localDataSource.cacheUser(userModel);
        return Right(_userModelToAppUser(userModel));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getCurrentUser() async {
    try {
      if (await networkInfo.isConnected) {
        // Try to get from remote first
        try {
          final userModel = await remoteDataSource.getCurrentUser();
          await localDataSource.cacheUser(userModel);
          return Right(_userModelToAppUser(userModel));
        } on ServerException {
          // If remote fails, try local cache
          final cachedUser = await localDataSource.getCachedUser();
          return Right(_userModelToAppUser(cachedUser));
        }
      } else {
        // No internet, get from cache
        final cachedUser = await localDataSource.getCachedUser();
        return Right(_userModelToAppUser(cachedUser));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check if user is cached locally
      final hasUser = await localDataSource.hasUserCached();
      if (!hasUser) {
        return false;
      }

      // Check if user is still authenticated remotely (if connected)
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.getCurrentUser();
          return true;
        } on ServerException {
          // Remote auth failed, clear cache
          await localDataSource.clearCache();
          return false;
        }
      } else {
        // No internet, trust local cache
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, AppUser>> refreshToken() async {
    // For Firebase, token refresh is handled automatically
    return getCurrentUser();
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Password reset failed: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement password change
    return const Left(
      ServerFailure(message: 'Password change not implemented'),
    );
  }

  @override
  Future<Either<Failure, AppUser>> updateProfile({
    String? name,
    String? phone,
    String? team,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (phone != null) updates['phone'] = phone;
        if (team != null) updates['team'] = team;

        final currentUser = await remoteDataSource.getCurrentUser();
        final userModel = await remoteDataSource.updateUserProfile(
          currentUser.userEmail,
          updates,
        );
        await localDataSource.cacheUser(userModel);
        return Right(_userModelToAppUser(userModel));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Profile update failed: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    // TODO: Implement account deletion
    return const Left(
      ServerFailure(message: 'Account deletion not implemented'),
    );
  }

  @override
  Stream<AppUser> get authStateChanges {
    // TODO: Implement auth state stream
    throw UnimplementedError('Auth state stream not implemented');
  }

  @override
  Future<Either<Failure, void>> verifyEmail() async {
    // TODO: Implement email verification
    return const Left(
      ServerFailure(message: 'Email verification not implemented'),
    );
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    // TODO: Implement resend verification email
    return const Left(
      ServerFailure(message: 'Resend verification email not implemented'),
    );
  }

  // Helper method to convert UserModel to AppUser
  AppUser _userModelToAppUser(userModel) {
    // Use Firebase Auth UID as the primary ID, fallback to email if not available
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userId = firebaseUser?.uid ?? userModel.userEmail;

    print('🔔 AUTH: Converting UserModel to AppUser');
    print('🔔 AUTH: Firebase UID: ${firebaseUser?.uid}');
    print('🔔 AUTH: User Email: ${userModel.userEmail}');
    print('🔔 AUTH: Using ID: $userId');

    return AppUser(
      id: userId, // ✅ Use Firebase Auth UID instead of email
      name: userModel.name,
      email: userModel.userEmail,
      role: userModel.role,
      team: userModel.team,
      phone: userModel.phone,
      isAuthenticated: true,
    );
  }
}
