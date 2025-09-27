import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Core
import 'core/network/network_info.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/task_cleanup_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/vercel_notification_service.dart';

// Data sources
import 'data/datasources/auth/auth_remote_datasource.dart';
import 'data/datasources/auth/auth_local_datasource.dart';
import 'data/datasources/tasks/task_remote_datasource.dart';
import 'data/datasources/tasks/task_local_datasource.dart';
import 'data/datasources/users/user_remote_datasource.dart';
import 'data/datasources/users/user_local_datasource.dart';
import 'data/datasources/notifications/notification_remote_datasource.dart';

// Services
import 'data/services/push_notification_service.dart';

// Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/notification_repository.dart';

// Use cases
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/reset_password_usecase.dart';
import 'domain/usecases/notifications/delete_all_notification_usecase.dart';
import 'domain/usecases/tasks/create_task_usecase.dart';
import 'domain/usecases/tasks/get_tasks_for_manager_usecase.dart';
import 'domain/usecases/tasks/get_tasks_usecase.dart';
import 'domain/usecases/tasks/get_task_by_id_usecase.dart';
import 'domain/usecases/tasks/update_task_usecase.dart';
import 'domain/usecases/tasks/delete_task_usecase.dart';
import 'domain/usecases/tasks/auto_cleanup_completed_tasks_usecase.dart';
import 'domain/usecases/users/get_user_profile_usecase.dart';
import 'domain/usecases/users/update_user_profile_usecase.dart';
import 'domain/usecases/users/get_all_users_usecase.dart';
import 'domain/usecases/users/update_user_role_usecase.dart';
import 'domain/usecases/users/update_user_status_usecase.dart';
import 'domain/usecases/users/delete_user_usecase.dart';
import 'domain/usecases/notifications/send_new_task_notification_usecase.dart';
import 'domain/usecases/notifications/get_unread_notifications_count_usecase.dart';
import 'domain/usecases/notifications/get_notifications_usecase.dart';
import 'domain/usecases/notifications/mark_notification_as_read_usecase.dart';
import 'domain/usecases/notifications/mark_all_notifications_as_read_usecase.dart';
import 'domain/usecases/notifications/delete_notification_usecase.dart';
import 'domain/usecases/notifications/delete_notifications_by_task_id_usecase.dart';

// BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/tasks/task_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/notifications/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> init({bool firebaseAvailable = true}) async {
  try {
    print('Initializing dependency injection...');
    print('Firebase available: $firebaseAvailable');

    //! External - Register SharedPreferences first
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);

    //! Core - Services (Always available)
    sl.registerLazySingleton(() => CloudinaryService());
    sl.registerLazySingleton(() => TaskCleanupService());

    //! Core - Network
    sl.registerLazySingleton(() => Connectivity());
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: sl()),
    );

    if (firebaseAvailable) {
      //! Firebase instances
      sl.registerLazySingleton(() => FirebaseAuth.instance);
      sl.registerLazySingleton(() => FirebaseFirestore.instance);
      sl.registerLazySingleton(() => FirebaseStorage.instance);

      //! Data sources
      sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
      );

      sl.registerLazySingleton<AuthLocalDataSource>(
        () => const AuthLocalDataSourceImpl(),
      );

      sl.registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSourceImpl(firestore: sl(), storage: sl()),
      );

      sl.registerLazySingleton<TaskLocalDataSource>(
        () => const TaskLocalDataSourceImpl(),
      );

      sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(firestore: sl(), auth: sl()),
      );

      sl.registerLazySingleton<UserLocalDataSource>(
        () => const UserLocalDataSourceImpl(),
      );

      sl.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSourceImpl(firestore: sl()),
      );

      //! Services
      sl.registerLazySingleton<VercelNotificationService>(
        () => VercelNotificationService(),
      );

      sl.registerLazySingleton<PushNotificationService>(
        () => PushNotificationServiceImpl(vercelService: sl()),
      );

      sl.registerLazySingleton(() => FCMService());

      //! Repositories
      sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: sl(),
          localDataSource: sl(),
          networkInfo: sl(),
        ),
      );

      sl.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(
          remoteDataSource: sl(),
          localDataSource: sl(),
          networkInfo: sl(),
        ),
      );

      sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
          remoteDataSource: sl(),
          localDataSource: sl(),
          networkInfo: sl(),
        ),
      );

      sl.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(
          remoteDataSource: sl(),
          userRepository: sl(),
          networkInfo: sl(),
          pushNotificationService: sl(),
        ),
      );

      //! Use cases
      sl.registerLazySingleton(() => LoginUseCase(sl()));
      sl.registerLazySingleton(() => LogoutUseCase(sl()));
      sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
      sl.registerLazySingleton(() => RegisterUseCase(sl()));
      sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

      sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
      sl.registerLazySingleton(() => GetTasksUseCase(sl()));
      sl.registerLazySingleton(
        () => GetTasksForManagerUseCase(
          taskRepository: sl(),
          authRepository: sl(),
          userRepository: sl(),
        ),
      );
      sl.registerLazySingleton(() => GetTaskByIdUseCase(sl()));
      sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
      sl.registerLazySingleton<DeleteTaskUseCase>(
        () => DeleteTaskUseCase(
          repository: sl(),
          notificationRepository: sl(),
          cloudinaryService: sl(),
        ),
      );
      sl.registerLazySingleton(
        () => AutoCleanupCompletedTasksUseCase(
          repository: sl(),
          notificationRepository: sl(),
          cloudinaryService: sl(),
        ),
      );

      sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
      sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
      sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
      sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
      sl.registerLazySingleton(() => UpdateUserStatusUseCase(sl()));
      sl.registerLazySingleton(() => DeleteUserUseCase(sl()));

      // Notification use cases
      sl.registerLazySingleton(() => SendNewTaskNotificationUseCase(sl()));
      sl.registerLazySingleton(() => GetUnreadNotificationsCountUseCase(sl()));
      sl.registerLazySingleton(() => GetNotificationsUseCase(repository: sl()));
      sl.registerLazySingleton(
        () => MarkNotificationAsReadUseCase(repository: sl()),
      );
      sl.registerLazySingleton(
        () => MarkAllNotificationsAsReadUseCase(repository: sl()),
      );
      sl.registerLazySingleton(
        () => DeleteNotificationUseCase(repository: sl()),
      );
      sl.registerLazySingleton(
        () => DeleteNotificationsByTaskIdUseCase(repository: sl()),
      );
      sl.registerLazySingleton(
        () => DeleteAllNotificationsUseCase(repository: sl()),
      );

      //! BLoCs
      sl.registerFactory(
        () => AuthBloc(
          loginUseCase: sl(),
          logoutUseCase: sl(),
          getCurrentUserUseCase: sl(),
          registerUseCase: sl(),
          resetPasswordUseCase: sl(),
        ),
      );

      // Register TaskBloc
      sl.registerFactory(
        () => TaskBloc(
          getTasksUseCase: sl(),
          getTaskByIdUseCase: sl(),
          createTaskUseCase: sl(),
          updateTaskUseCase: sl(),
          deleteTaskUseCase: sl(),
          autoCleanupCompletedTasksUseCase: sl(),
          sendNewTaskNotificationUseCase: sl(),
          getTasksForManagerUseCase: sl(),
        ),
      );

      // Register UserBloc
      sl.registerFactory(
        () => UserBloc(
          getUserProfileUseCase: sl(),
          updateUserProfileUseCase: sl(),
          getAllUsersUseCase: sl(),
          updateUserRoleUseCase: sl(),
          updateUserStatusUseCase: sl(),
          deleteUserUseCase: sl(),
        ),
      );

      // Register NotificationBloc
      sl.registerFactory(
        () => NotificationBloc(
          getNotificationsUseCase: sl(),
          getUnreadNotificationsCountUseCase: sl(),
          markNotificationAsReadUseCase: sl(),
          markAllNotificationsAsReadUseCase: sl(),
          deleteNotificationUseCase: sl(),
          deleteAllNotificationsUseCase: sl(),
        ),
      );

      print('All services registered successfully with Firebase');
    } else {
      print('Firebase not available - app will run with limited functionality');
    }

    print('Dependency injection initialization complete');
  } catch (e) {
    print('Error during dependency injection initialization: $e');
    rethrow;
  }
}
