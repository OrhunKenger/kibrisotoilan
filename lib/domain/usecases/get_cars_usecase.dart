import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../entities/car_enums.dart';
import '../repositories/car_repository.dart';

class GetCars implements UseCase<List<CarEntity>, GetCarsParams> {
  final CarRepository repository;

  GetCars(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(GetCarsParams params) async {
    return await repository.getCars(
      brand: params.brand,
      model: params.model,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      currency: params.currency,
      steering: params.steering,
      city: params.city,
      minMileage: params.minMileage,
      maxMileage: params.maxMileage,
      engineSize: params.engineSize,
      bodyType: params.bodyType,
      transmission: params.transmission,
      color: params.color,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetCarsParams extends Equatable {
  final String? brand;
  final String? model;
  final double? minPrice;
  final double? maxPrice;
  final Currency? currency;
  final SteeringType? steering;
  final String? city;
  final int? minMileage;
  final int? maxMileage;
  final int? engineSize;
  final BodyType? bodyType;
  final TransmissionType? transmission;
  final String? color;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const GetCarsParams({
    this.brand,
    this.model,
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.steering,
    this.city,
    this.minMileage,
    this.maxMileage,
    this.engineSize,
    this.bodyType,
    this.transmission,
    this.color,
    required this.page,
    required this.limit,
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
        brand,
        model,
        minPrice,
        maxPrice,
        currency,
        steering,
        city,
        minMileage,
        maxMileage,
        engineSize,
        bodyType,
        transmission,
        color,
        page,
        limit,
        sortBy,
        sortOrder
      ];
}
