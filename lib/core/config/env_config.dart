import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String _devBaseUrl = 'http://192.168.1.25:8000';
  static const String _devWebBaseUrl = 'http://192.168.1.25:8000';
  static const String _prodBaseUrl = 'https://api.kibrisoto.com';

  static String get baseUrl {
    if (kReleaseMode) return _prodBaseUrl;
    return kIsWeb ? _devWebBaseUrl : _devBaseUrl;
  }

  static bool get isProduction => kReleaseMode;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
