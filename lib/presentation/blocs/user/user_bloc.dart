import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/users/delete_user_usecase.dart';
import '../../../domain/usecases/users/get_user_profile_usecase.dart';
import '../../../domain/usecases/users/update_user_profile_usecase.dart';
import '../../../domain/usecases/users/get_all_users_usecase.dart';
import '../../../domain/usecases/users/update_user_role_usecase.dart';
import '../../../domain/usecases/users/update_user_status_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final UpdateUserStatusUseCase updateUserStatusUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.getAllUsersUseCase,
    required this.updateUserRoleUseCase,
    required this.updateUserStatusUseCase,
    required this.deleteUserUseCase,
  }) : super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<LoadUsersByRole>(_onLoadUsersByRole);
    on<LoadUsersByTeam>(_onLoadUsersByTeam);
    on<SearchUsers>(_onSearchUsers);
    on<ActivateUser>(_onActivateUser);
    on<DeactivateUser>(_onDeactivateUser);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await getUserProfileUseCase(event.userEmail);

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (user) => emit(UserProfileLoaded(user: user)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await updateUserProfileUseCase(
      email: event.userEmail,
      name: event.name,
      phone: event.phone,
      team: event.team,
    );

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (user) => emit(UserProfileUpdated(user: user)),
    );
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await getAllUsersUseCase();

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (users) => emit(AllUsersLoaded(users: users)),
    );
  }

  Future<void> _onLoadUsersByRole(
    LoadUsersByRole event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    // TODO: Implement get users by role use case
    emit(const UserError(message: 'Get users by role not implemented'));
  }

  Future<void> _onLoadUsersByTeam(
    LoadUsersByTeam event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    // TODO: Implement get users by team use case
    emit(const UserError(message: 'Get users by team not implemented'));
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    // TODO: Implement search users use case
    emit(const UserError(message: 'Search users not implemented'));
  }

  Future<void> _onActivateUser(
    ActivateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    // TODO: Implement activate user use case
    emit(const UserError(message: 'Activate user not implemented'));
  }

  Future<void> _onDeactivateUser(
    DeactivateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    // TODO: Implement deactivate user use case
    emit(const UserError(message: 'Deactivate user not implemented'));
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final params = UpdateUserRoleParams(
      email: event.userEmail,
      newRole: event.newRole,
      managedCategories: event.managedCategories,
    );
    final result = await updateUserRoleUseCase(params);

    result.fold((failure) => emit(UserError(message: failure.message)), (user) {
      emit(UserRoleUpdated(userEmail: event.userEmail, newRole: event.newRole));
      // Reload all users to refresh the list
      add(const LoadAllUsers());
    });
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatus event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final params = UpdateUserStatusParams(
      email: event.userEmail,
      isActive: event.isActive,
    );
    final result = await updateUserStatusUseCase(params);

    result.fold((failure) => emit(UserError(message: failure.message)), (user) {
      emit(
        UserStatusUpdated(userEmail: event.userEmail, isActive: event.isActive),
      );
      // Reload all users to refresh the list
      add(const LoadAllUsers());
    });
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await deleteUserUseCase(event.userEmail);

    result.fold((failure) => emit(UserError(message: failure.message)), (_) {
      emit(UserDeleted(userEmail: event.userEmail));
      // Reload all users to refresh the list
      add(const LoadAllUsers());
    });
  }
}
