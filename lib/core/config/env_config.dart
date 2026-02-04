import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String _devBaseUrl = 'http://192.168.1.25:8000';
  static const String _devWebBaseUrl = 'http://192.168.1.25:8000';
  
  // DÜZELTİLDİ: Release modda da senin bilgisayara bakacak
  static const String _prodBaseUrl = 'http://192.168.1.25:8000';

  static String get baseUrl {
    // Release mod (bizim github build) artık prodBaseUrl'i, yani senin IP'yi kullanacak
    if (kReleaseMode) return _prodBaseUrl;
    return kIsWeb ? _devWebBaseUrl : _devBaseUrl;
  }

  static bool get isProduction => kReleaseMode;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}