import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/notifications/delete_all_notification_usecase.dart';
import '../../../domain/usecases/notifications/get_notifications_usecase.dart';
import '../../../domain/usecases/notifications/get_unread_notifications_count_usecase.dart';
import '../../../domain/usecases/notifications/mark_notification_as_read_usecase.dart';
import '../../../domain/usecases/notifications/mark_all_notifications_as_read_usecase.dart';
import '../../../domain/usecases/notifications/delete_notification_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadNotificationsCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase deleteAllNotificationsUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.getUnreadNotificationsCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.deleteAllNotificationsUseCase,
  }) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await getNotificationsUseCase(
      userEmail: event.userEmail,
      limit: event.limit,
      lastNotificationId: event.lastNotificationId,
    );

    await result.fold(
      (failure) async => emit(NotificationError(message: failure.message)),
      (notifications) async {
        // Also get unread count
        final unreadResult = await getUnreadNotificationsCountUseCase(
          event.userEmail,
        );
        final unreadCount = unreadResult.fold((failure) => 0, (count) => count);

        // Check if emitter is still active before emitting
        if (!emit.isDone) {
          emit(
            NotificationsLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getUnreadNotificationsCountUseCase(event.userEmail);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (count) => emit(UnreadCountLoaded(count: count)),
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading()); // 👈 add this
    final result = await markNotificationAsReadUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notification) =>
          emit(NotificationMarkedAsRead(notification: notification)),
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading()); // 👈 add this
    final result = await deleteNotificationUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(NotificationDeleted(notificationId: event.notificationId)),
    );
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading()); // 👈 add this
    final result = await deleteAllNotificationsUseCase(event.userEmail);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const NotificationsLoaded(notifications: [], unreadCount: 0)),
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Emit loading first
    emit(const NotificationLoading());

    final result = await markAllNotificationsAsReadUseCase(event.userEmail);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const AllNotificationsMarkedAsRead()),
    );
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Refresh is the same as loading notifications
    add(LoadNotifications(userEmail: event.userEmail));
  }
}
