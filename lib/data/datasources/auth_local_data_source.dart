import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

const String _tokenKey = 'auth_token';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) =>
      secureStorage.write(key: _tokenKey, value: token);

  @override
  Future<String?> getToken() => secureStorage.read(key: _tokenKey);

  @override
  Future<void> deleteToken() => secureStorage.delete(key: _tokenKey);
}
