import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.getToken();
    result.fold(
      (failure) {
        // If cannot get token (e.g., CacheFailure or no token), consider unauthenticated
        emit(const Unauthenticated());
      },
      (token) {
        if (token != null && token.isNotEmpty) {
          emit(Authenticated(token: token));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.login(event.username, event.password);
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          emit(AuthError(message: failure.message));
        } else {
          emit(const AuthError(message: 'An unexpected error occurred during login.'));
        }
      },
      (token) => emit(Authenticated(token: token)),
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.register(
      event.email,
      event.username,
      event.password,
      event.fullName,
      event.phoneNumber,
      event.city,
      event.accountType,
      event.profileImageUrl,
      event.bio,
      event.district,
      event.isPhoneVisible,
      event.companyName,
      event.taxNumber,
      event.landlinePhone,
      event.addressDetail,
      event.mapsUrl,
      event.website,
    );
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          emit(AuthError(message: failure.message));
        } else {
          emit(const AuthError(message: 'An unexpected error occurred during registration.'));
        }
      },
      (_) {
        emit(const RegisterSuccess(message: 'Kayıt başarılı! Giriş yapabilirsiniz.'));
      },
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.deleteToken();
    result.fold(
      (failure) {
        // Even if deleting token fails, consider user unauthenticated
        emit(const Unauthenticated());
        // Optionally emit an error for feedback if needed
        // emit(AuthError(message: failure.message));
      },
      (_) => emit(const Unauthenticated()),
    );
  }
}
