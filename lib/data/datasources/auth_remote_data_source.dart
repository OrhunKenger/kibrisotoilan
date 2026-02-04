import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_error_handler.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<void> register(
    String email,
    String username,
    String password,
    String? fullName,
    String? phoneNumber,
    String? city,
    String accountType,
    String? profileImageUrl,
    String? bio,
    String? district,
    bool isPhoneVisible,
    String? companyName,
    String? taxNumber,
    String? landlinePhone,
    String? addressDetail,
    String? mapsUrl,
    String? website,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/token',
        data: FormData.fromMap({
          'username': username,
          'password': password,
          'grant_type': 'password',
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data.containsKey('access_token')) {
        return response.data['access_token'];
      }
      throw ServerException(message: 'Giriş başarısız: Geçersiz yanıt');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> register(
    String email,
    String username,
    String password,
    String? fullName,
    String? phoneNumber,
    String? city,
    String accountType,
    String? profileImageUrl,
    String? bio,
    String? district,
    bool isPhoneVisible,
    String? companyName,
    String? taxNumber,
    String? landlinePhone,
    String? addressDetail,
    String? mapsUrl,
    String? website,
  ) async {
    try {
      await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'city': city,
          'account_type': accountType,
          'profile_image_url': profileImageUrl,
          'bio': bio,
          'district': district,
          'is_phone_visible': isPhoneVisible,
          'company_name': companyName,
          'tax_number': taxNumber,
          'landline_phone': landlinePhone,
          'address_detail': addressDetail,
          'maps_url': mapsUrl,
          'website': website,
        },
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) => DioErrorHandler.handle(e);
}
