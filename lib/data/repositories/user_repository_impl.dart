import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/car_model.dart';
import '../../domain/entities/car_entity.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final remoteUser = await remoteDataSource.getUserProfile();
      return Right(remoteUser);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Profil alınamadı'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final updatedUser = await remoteDataSource.updateUserProfile(data);
      return Right(updatedUser);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Profil güncellenemedi'));
    }
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getMyListings({
    required int page,
    required int limit,
  }) async {
    try {
      final rawList = await remoteDataSource.getMyListings(page: page, limit: limit);
      final cars = rawList.map((json) => CarModel.fromJson(json) as CarEntity).toList();
      return Right(cars);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'İlanlar alınamadı'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser() async {
    try {
      await remoteDataSource.deleteUser();
      return const Right(null);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Hesap silinemedi'));
    }
  }
}
