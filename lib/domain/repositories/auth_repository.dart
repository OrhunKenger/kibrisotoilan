import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String username, String password);
  Future<Either<Failure, Unit>> register(
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
  Future<Either<Failure, Unit>> saveToken(String token);
  Future<Either<Failure, String?>> getToken(); // Can return null if no token
  Future<Either<Failure, Unit>> deleteToken();
}
