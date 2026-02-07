import 'package:mobile/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getMyListings({required int page, required int limit});
  Future<void> deleteUser();
}
