import 'package:equatable/equatable.dart';
import 'car_enums.dart';
import 'user_entity.dart';

class CarEntity extends Equatable {
  final int? id;
  final String title;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String? description;
  final String city;
  final String? district;
  final SteeringType steering;
  final Currency currency;
  final bool isFeatured;
  final bool isUrgent;
  final int mileage;
  final MileageUnit mileageUnit;
  final int engineSize;
  final BodyType bodyType;
  final String color;
  final TransmissionType transmission;
  final bool isExchangeable;
  final String? fuelType;
  final List<String> imageUrls;
  final int? ownerId;
  final UserEntity? owner;  // Owner bilgileri
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDeleted;
  final String? status;
  final int viewsCount;
  final ExchangeRatesEntity? exchangeRates;
  final String steeringSide;
  final String registrationStatus;
  final String? licenseSeries;

  const CarEntity({
    this.id,
    required this.title,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    this.description,
    required this.city,
    this.district,
    required this.steering,
    this.currency = Currency.gbp,
    this.isFeatured = false,
    this.isUrgent = false,
    required this.mileage,
    this.mileageUnit = MileageUnit.km,
    required this.engineSize,
    required this.bodyType,
    required this.color,
    required this.transmission,
    this.isExchangeable = false,
    this.fuelType,
    this.imageUrls = const [],
    this.ownerId,
    this.owner,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.status,
    this.viewsCount = 0,
    this.exchangeRates,
    required this.steeringSide,
    required this.registrationStatus,
    this.licenseSeries,
  });

  bool get isEligibleForFeaturing => price > 10000;

  @override
  List<Object?> get props => [
        id,
        title,
        brand,
        model,
        year,
        price,
        description,
        city,
        district,
        steering,
        currency,
        isFeatured,
        isUrgent,
        mileage,
        mileageUnit,
        engineSize,
        bodyType,
        color,
        transmission,
        isExchangeable,
        fuelType,
        imageUrls,
        ownerId,
        owner,
        createdAt,
        updatedAt,
        isDeleted,
        status,
        viewsCount,
        exchangeRates,
        steeringSide,
        registrationStatus,
        licenseSeries,
      ];
}

class ExchangeRatesEntity extends Equatable {
  final double gbpToTry;
  final String? lastUpdated;

  const ExchangeRatesEntity({
    required this.gbpToTry,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [gbpToTry, lastUpdated];
}
