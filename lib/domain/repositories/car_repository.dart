import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/car_entity.dart';
import '../entities/car_enums.dart';

abstract class CarRepository {
  Future<Either<Failure, List<CarEntity>>> getCars({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    Currency? currency,
    SteeringType? steering,
    String? city,
    int? minMileage,
    int? maxMileage,
    int? engineSize,
    BodyType? bodyType,
    TransmissionType? transmission,
    String? color,
    required int page,
    required int limit,
    required String sortBy,
    required String sortOrder,
  });

  Future<Either<Failure, CarEntity>> getCarById(int id);

  Future<Either<Failure, CarEntity>> createCar(CarEntity car);

  Future<Either<Failure, Unit>> addFavorite(int carId);

  Future<Either<Failure, Unit>> removeFavorite(int carId);

  Future<Either<Failure, List<CarEntity>>> getMyFavorites({
    required int page,
    required int limit,
  });
}
