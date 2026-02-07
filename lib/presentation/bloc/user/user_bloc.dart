import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_user_profile_usecase.dart';
import '../../../domain/usecases/update_user_profile_usecase.dart';
import '../../../domain/usecases/get_my_listings_usecase.dart';
import '../../../domain/usecases/soft_delete_user.dart'; // New Import

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfile getUserProfileUseCase;
  final UpdateUserProfile updateUserProfileUseCase;
  final GetMyListings getMyListingsUseCase;
  final SoftDeleteUser softDeleteUserUseCase; // New

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.getMyListingsUseCase,
    required this.softDeleteUserUseCase, // New
  }) : super(const UserInitial()) {
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<GetMyListingsEvent>(_onGetMyListings);
    on<UserDeleteEvent>(_onUserDelete); // New
  }

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is ConnectionFailure) return failure.message;
    if (failure is UnauthorizedFailure) return 'Oturum süresi doldu';
    return 'Beklenmeyen bir hata oluştu';
  }

  Future<void> _onGetUserProfile(GetUserProfileEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await getUserProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(UserError(message: _failureMessage(failure))),
      (user) => emit(UserLoaded(user: user)),
    );
  }

Future<void> _onUpdateUserProfile(UpdateUserProfileEvent event, Emitter<UserState> emit) async {
    emit(const UserUpdating());
    final result = await updateUserProfileUseCase(event.data);
    result.fold(
      (failure) {
        if (failure is VerificationRequiredFailure) {
          emit(UserVerificationRequired(codeType: failure.codeType, data: event.data));
        } else {
          emit(UserUpdateError(message: _failureMessage(failure)));
        }
      },
      (user) => emit(UserUpdated(user: user)),
    );
  }

  Future<void> _onGetMyListings(GetMyListingsEvent event, Emitter<UserState> emit) async {
    emit(const MyListingsLoading());
    final result = await getMyListingsUseCase(
      GetMyListingsParams(page: event.page, limit: event.limit),
    );
    result.fold(
      (failure) => emit(MyListingsError(message: _failureMessage(failure))),
      (listings) => emit(MyListingsLoaded(listings: listings)),
    );
  }

  Future<void> _onUserDelete(UserDeleteEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading()); // Or UserDeleting, if a specific state is preferred
    final result = await softDeleteUserUseCase();
    result.fold(
      (failure) => emit(UserError(message: _failureMessage(failure))),
      (_) => emit(const UserDeleted()),
    );
  }
}
