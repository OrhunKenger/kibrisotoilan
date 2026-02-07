import 'package:equatable/equatable.dart';
import '../../../domain/entities/car_entity.dart';
import '../../../domain/entities/car_enums.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();

  @override
  List<Object?> get props => [];
}

class GetCarsEvent extends CarEvent {
  final String? brand;
  final String? model;
  final double? minPrice;
  final double? maxPrice;
  final Currency? currency;
  final SteeringType? steering;
  final String? city;
  final int? minMileage;
  final int? maxMileage;
  final int? minYear;
  final int? maxYear;
  final int? engineSize;
  final BodyType? bodyType;
  final TransmissionType? transmission;
  final String? color;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const GetCarsEvent({
    this.brand,
    this.model,
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.steering,
    this.city,
    this.minMileage,
    this.maxMileage,
    this.minYear,
    this.maxYear,
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
    brand, model, minPrice, maxPrice, currency, steering, city,
    minMileage, maxMileage, minYear, maxYear, engineSize, bodyType, transmission,
    color, page, limit, sortBy, sortOrder
  ];
}

class GetCarDetailEvent extends CarEvent {
  final int carId;

  const GetCarDetailEvent({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class CreateCarEvent extends CarEvent {
  final CarEntity car;

  const CreateCarEvent({required this.car});

  @override
  List<Object?> get props => [car];
}

class AddFavoriteEvent extends CarEvent {
  final int carId;

  const AddFavoriteEvent({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class RemoveFavoriteEvent extends CarEvent {
  final int carId;

  const RemoveFavoriteEvent({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class GetMyFavoritesEvent extends CarEvent {
  final int page;
  final int limit;

  const GetMyFavoritesEvent({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class GetUniqueBrandsEvent extends CarEvent {
  const GetUniqueBrandsEvent();
}

class GetAllBrandsEvent extends CarEvent {
  const GetAllBrandsEvent();
}

class GetModelsByBrandEvent extends CarEvent {
  final String brand;

  const GetModelsByBrandEvent({required this.brand});

  @override
  List<Object?> get props => [brand];
}

class GetSeriesAndModelsEvent extends CarEvent {
  final int brandId;

  const GetSeriesAndModelsEvent({required this.brandId});

  @override
  List<Object?> get props => [brandId];
}
