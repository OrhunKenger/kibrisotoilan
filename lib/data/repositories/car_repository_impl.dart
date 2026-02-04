import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/car_remote_data_source.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarRemoteDataSource remoteDataSource;

  CarRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final remoteCars = await remoteDataSource.getCars(
        brand: brand,
        model: model,
        minPrice: minPrice,
        maxPrice: maxPrice,
        currency: currency,
        steering: steering,
        city: city,
        minMileage: minMileage,
        maxMileage: maxMileage,
        engineSize: engineSize,
        bodyType: bodyType,
        transmission: transmission,
        color: color,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      return Right(remoteCars);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> getCarById(int id) async {
    try {
      final remoteCar = await remoteDataSource.getCarById(id);
      return Right(remoteCar);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> createCar(CarEntity car) async {
    try {
      final carModel = CarModel(
        id: car.id,
        title: car.title,
        brand: car.brand,
        model: car.model,
        year: car.year,
        price: car.price,
        description: car.description,
        city: car.city,
        district: car.district,
        steering: car.steering,
        currency: car.currency,
        isFeatured: car.isFeatured,
        isUrgent: car.isUrgent,
        mileage: car.mileage,
        mileageUnit: car.mileageUnit,
        engineSize: car.engineSize,
        bodyType: car.bodyType,
        color: car.color,
        transmission: car.transmission,
        isExchangeable: car.isExchangeable,
        fuelType: car.fuelType,
        imageUrls: car.imageUrls,
        ownerId: car.ownerId,
        createdAt: car.createdAt,
        updatedAt: car.updatedAt,
        isDeleted: car.isDeleted,
        steeringSide: car.steeringSide,
        registrationStatus: car.registrationStatus,
        licenseSeries: car.licenseSeries,
      );
      final remoteCar = await remoteDataSource.createCar(carModel);
      return Right(remoteCar);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(int carId) async {
    try {
      await remoteDataSource.addFavorite(carId);
      return const Right(unit);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int carId) async {
    try {
      await remoteDataSource.removeFavorite(carId);
      return const Right(unit);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getMyFavorites({
    required int page,
    required int limit,
  }) async {
    try {
      final remoteFavorites =
          await remoteDataSource.getMyFavorites(page: page, limit: limit);
      return Right(remoteFavorites);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Sunucu hatası'));
    }
  }
}
