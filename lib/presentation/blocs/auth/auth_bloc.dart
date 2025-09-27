import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/fcm_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG AUTH BLOC: AuthStarted event triggered');
    emit(AuthLoading());

    final result = await getCurrentUserUseCase();
    await result.fold(
      (failure) async {
        print('DEBUG AUTH BLOC: getCurrentUser failed: ${failure.toString()}');
        emit(AuthUnauthenticated());
      },
      (user) async {
        print(
          'DEBUG AUTH BLOC: getCurrentUser success, isAuthenticated: ${user.isAuthenticated}',
        );
        if (user.isAuthenticated) {
          // Subscribe to FCM topics for already authenticated user
          await FCMService.subscribeToUserRole(user.role);

          // Store FCM token for direct messaging using UID
          await FCMService.storeFCMToken(user.id);

          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async => emit(AuthError(_getFailureMessage(failure))),
      (user) async {
        print('DEBUG AUTH BLOC: User logged in with role: ${user.role}');
        print('DEBUG AUTH BLOC: User email: ${user.email}');
        print('DEBUG AUTH BLOC: User name: ${user.name}');

        // Subscribe to FCM topics based on user role
        await FCMService.subscribeToUserRole(user.role);

        // Store FCM token for direct messaging using UID
        await FCMService.storeFCMToken(user.id);

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      name: event.name,
      role: event.role,
      team: event.team,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(AuthError(_getFailureMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Remove FCM token from current user's document before logout
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print(
          'AUTH BLOC: Removing FCM token from user ${currentUser.uid} before logout',
        );
        await FCMService.removeFCMTokenFromFirestore(currentUser.uid);
      }
    } catch (e) {
      print('Error removing FCM token during logout: $e');
    }

    // Unsubscribe from FCM topics before logout
    try {
      await FCMService.unsubscribeFromTopic('managers');
      await FCMService.unsubscribeFromTopic('admins');
      await FCMService.unsubscribeFromTopic('employees');
      await FCMService.unsubscribeFromTopic('all_users');
    } catch (e) {
      print('Error unsubscribing from FCM topics: $e');
    }

    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(_getFailureMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.isAuthenticated) {
      emit(AuthAuthenticated(event.user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Token refresh logic would be implemented here
    // For now, we'll just get the current user
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthError(_getFailureMessage(failure))),
      (user) => emit(AuthTokenRefreshed(user)),
    );
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await resetPasswordUseCase(email: event.email);

    result.fold(
      (failure) => emit(AuthError(_getFailureMessage(failure))),
      (_) => emit(AuthPasswordResetSent(event.email)),
    );
  }

  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Password change logic would be implemented here
    // For now, we'll simulate success
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthPasswordChanged());
  }

  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Profile update logic would be implemented here
    // For now, we'll get the current user
    final result = await getCurrentUserUseCase();
    result.fold((failure) => emit(AuthError(_getFailureMessage(failure))), (
      user,
    ) {
      // Update user with new information
      final updatedUser = user.copyWith(
        name: event.name ?? user.name,
        phone: event.phone ?? user.phone,
        team: event.team ?? user.team,
      );
      emit(AuthProfileUpdated(updatedUser));
    });
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthenticationFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case ServerFailure:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
