import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/car_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserEntity user;
  const UserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;
  const UserError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserUpdating extends UserState {
  const UserUpdating();
}

class UserUpdated extends UserState {
  final UserEntity user;
  const UserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class UserUpdateError extends UserState {
  final String message;
  const UserUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

class MyListingsLoading extends UserState {
  const MyListingsLoading();
}

class MyListingsLoaded extends UserState {
  final List<CarEntity> listings;
  const MyListingsLoaded({required this.listings});

  @override
  List<Object> get props => [listings];
}

class MyListingsError extends UserState {
  final String message;
  const MyListingsError({required this.message});

  @override
  List<Object> get props => [message];
}
