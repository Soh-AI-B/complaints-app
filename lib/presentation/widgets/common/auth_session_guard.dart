import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class AuthSessionGuard extends StatefulWidget {
  final Widget child;

  const AuthSessionGuard({super.key, required this.child});

  @override
  State<AuthSessionGuard> createState() => _AuthSessionGuardState();
}

class _AuthSessionGuardState extends State<AuthSessionGuard> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  String? _watchedUserId;
  bool _isEndingSession = false;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _watchUserDocument(state.user.id);
        } else {
          _stopWatchingUserDocument();
        }
      },
      child: widget.child,
    );
  }

  void _watchUserDocument(String userId) {
    if (userId.isEmpty || _watchedUserId == userId) return;

    _stopWatchingUserDocument();
    _watchedUserId = userId;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists) {
              _endSession('Your account is no longer available.');
              return;
            }

            final data = snapshot.data() ?? {};
            final isDeleted = data['is_deleted'] == true;
            final isActive = data['is_active'] as bool? ?? true;
            if (isDeleted || !isActive) {
              _endSession(
                isDeleted
                    ? 'Your account was removed by an administrator.'
                    : 'Your account was deactivated by an administrator.',
              );
            }
          },
          onError: (_) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              _endSession('Your session has ended.');
            }
          },
        );
  }

  void _stopWatchingUserDocument() {
    _subscription?.cancel();
    _subscription = null;
    _watchedUserId = null;
    _isEndingSession = false;
  }

  void _endSession(String message) {
    if (_isEndingSession || !mounted) return;
    _isEndingSession = true;

    context.read<AuthBloc>().add(AuthLogoutRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    });
  }
}
