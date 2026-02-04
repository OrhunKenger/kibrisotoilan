import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, String>> login(String username, String password) async {
    try {
      final token = await remoteDataSource.login(username, password);
      await localDataSource.saveToken(token);
      return Right(token);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Giriş başarısız'));
    } catch (e) {
      return Left(ServerFailure(message: 'Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
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
  ) async {
    try {
      await remoteDataSource.register(
        email, username, password, fullName, phoneNumber, city, accountType,
        profileImageUrl, bio, district, isPhoneVisible, companyName,
        taxNumber, landlinePhone, addressDetail, mapsUrl, website,
      );
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Kayıt başarısız'));
    } catch (e) {
      return Left(ServerFailure(message: 'Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Token kaydedilemedi'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(message: 'Token alınamadı'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteToken() async {
    try {
      await localDataSource.deleteToken();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Token silinemedi'));
    }
  }
}
