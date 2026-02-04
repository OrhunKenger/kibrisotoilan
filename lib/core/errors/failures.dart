import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<dynamic> properties;
  final String message;

  const Failure([this.properties = const <dynamic>[], this.message = 'Beklenmeyen bir hata olustu']);

  @override
  List<Object?> get props => properties;
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super([message], message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) : super([message], message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super([message], message);
}

class ConnectionFailure extends Failure {
  ConnectionFailure({String message = 'Internet baglantinizi kontrol edin'}) : super([message], message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({String message = 'Oturum suresi doldu, tekrar giris yapin'}) : super([message], message);
}
