import 'package:dartz/dartz.dart';
import 'package:mobile/domain/entities/user_entity.dart';
import '../../core/errors/failures.dart';
import '../entities/car_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserProfile();
  Future<Either<Failure, UserEntity>> updateUserProfile(Map<String, dynamic> data);
  Future<Either<Failure, List<CarEntity>>> getMyListings({required int page, required int limit});
}
