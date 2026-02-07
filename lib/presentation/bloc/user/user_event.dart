import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserProfileEvent extends UserEvent {
  const GetUserProfileEvent();
}

class UpdateUserProfileEvent extends UserEvent {
  final Map<String, dynamic> data;

  const UpdateUserProfileEvent({required this.data});

  @override
  List<Object> get props => [data];
}

class UserDeleteEvent extends UserEvent {
  const UserDeleteEvent();
}

class GetMyListingsEvent extends UserEvent {
  final int page;
  final int limit;

  const GetMyListingsEvent({required this.page, required this.limit});

  @override
  List<Object> get props => [page, limit];
}
