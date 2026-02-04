import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String token;
  const Authenticated({required this.token});

  @override
  List<Object> get props => [token];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class RegisterSuccess extends AuthState {
  final String message;
  const RegisterSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
