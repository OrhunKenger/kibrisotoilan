class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  final dynamic responseBody;

  ServerException({this.message, this.statusCode, this.responseBody});
}

class CacheException implements Exception {
  final String? message;
  CacheException({this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Baglanti hatasi'});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = 'Oturum suresi doldu'});
}
