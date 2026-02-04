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
    minMileage, maxMileage, engineSize, bodyType, transmission,
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
