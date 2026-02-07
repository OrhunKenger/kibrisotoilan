import 'package:dio/dio.dart';
import '../../core/network/dio_error_handler.dart';
import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/users/me', data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyListings({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dio.get('/users/me/cars', queryParameters: {
        'page': page,
        'size': limit,
      });
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      if (response.data is Map && response.data.containsKey('items')) {
        return (response.data['items'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) => DioErrorHandler.handle(e);

  @override
  Future<void> deleteUser() async {
    try {
      await dio.delete('/users/me');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }
}
