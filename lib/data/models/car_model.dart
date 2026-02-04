import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';

// region Enum Mappings
// Using maps for direct and safe conversion between backend strings and app enums.

// SteeringType
const Map<SteeringType, String> _steeringTypeToString = {
  SteeringType.right: 'Right',
  SteeringType.left: 'Left',
};
final Map<String, SteeringType> _stringToSteeringType =
    _steeringTypeToString.map((k, v) => MapEntry(v, k));

// Currency
const Map<Currency, String> _currencyToString = {
  Currency.gbp: 'GBP',
  Currency.eur: 'EUR',
  Currency.usd: 'USD',
  Currency.try_: 'TRY',
};
final Map<String, Currency> _stringToCurrency =
    _currencyToString.map((k, v) => MapEntry(v, k));

// MileageUnit
const Map<MileageUnit, String> _mileageUnitToString = {
  MileageUnit.km: 'KM',
  MileageUnit.miles: 'Miles',
};
final Map<String, MileageUnit> _stringToMileageUnit =
    _mileageUnitToString.map((k, v) => MapEntry(v, k));

// BodyType
const Map<BodyType, String> _bodyTypeToString = {
  BodyType.sedan: 'Sedan',
  BodyType.hatchback: 'Hatchback',
  BodyType.suv: 'SUV',
  BodyType.coupe: 'Coupe',
  BodyType.convertible: 'Convertible',
  BodyType.van: 'Van',
  BodyType.pickup: 'Pickup',
};
final Map<String, BodyType> _stringToBodyType =
    _bodyTypeToString.map((k, v) => MapEntry(v, k));

// TransmissionType
const Map<TransmissionType, String> _transmissionTypeToString = {
  TransmissionType.manual: 'Manual',
  TransmissionType.automatic: 'Automatic',
  TransmissionType.semiAutomatic: 'Semi-Automatic',
};
final Map<String, TransmissionType> _stringToTransmissionType =
    _transmissionTypeToString.map((k, v) => MapEntry(v, k));

// endregion

class CarModel extends CarEntity {
  const CarModel({
    super.id,
    required super.title,
    required super.brand,
    required super.model,
    required super.year,
    required super.price,
    super.description,
    required super.city,
    super.district,
    required super.steering,
    super.currency,
    super.isFeatured,
    super.isUrgent,
    required super.mileage,
    super.mileageUnit,
    required super.engineSize,
    required super.bodyType,
    required super.color,
    required super.transmission,
    super.isExchangeable,
    super.fuelType,
    super.imageUrls,
    super.ownerId,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.exchangeRates,
    required super.steeringSide,
    required super.registrationStatus,
    super.licenseSeries,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      title: json['title'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      city: json['city'] ?? '',
      district: json['district'],
      steering: _stringToSteeringType[json['steering']] ?? SteeringType.right,
      currency: _stringToCurrency[json['currency']] ?? Currency.gbp,
      isFeatured: json['is_featured'] ?? false,
      isUrgent: json['is_urgent'] ?? false,
      mileage: json['mileage'] ?? 0,
      mileageUnit:
          _stringToMileageUnit[json['mileage_unit']] ?? MileageUnit.km,
      engineSize: json['engine_size'] ?? 0,
      bodyType: _stringToBodyType[json['body_type']] ?? BodyType.sedan,
      color: json['color'] ?? '',
      transmission: _stringToTransmissionType[json['transmission']] ??
          TransmissionType.automatic,
      isExchangeable: json['is_exchangeable'] ?? false,
      fuelType: json['fuel_type'],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ownerId: json['owner_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
      exchangeRates: json['exchange_rates'] != null
          ? ExchangeRatesModel.fromJson(json['exchange_rates'])
          : null,
      steeringSide: json['steering_side'] ?? 'Sağ',
      registrationStatus: json['registration_status'] ?? 'Belirtilmemiş',
      licenseSeries: json['license_series'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'description': description,
      'city': city,
      'district': district,
      'steering': _steeringTypeToString[steering],
      'currency': _currencyToString[currency],
      'is_featured': isFeatured,
      'is_urgent': isUrgent,
      'mileage': mileage,
      'mileage_unit': _mileageUnitToString[mileageUnit],
      'engine_size': engineSize,
      'body_type': _bodyTypeToString[bodyType],
      'color': color,
      'transmission': _transmissionTypeToString[transmission],
      'is_exchangeable': isExchangeable,
      'fuel_type': fuelType,
      'image_urls': imageUrls,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'exchange_rates': exchangeRates != null
          ? (exchangeRates as ExchangeRatesModel).toJson()
          : null,
      'steering_side': steeringSide,
      'registration_status': registrationStatus,
      'license_series': licenseSeries,
    };
  }
}

class ExchangeRatesModel extends ExchangeRatesEntity {
  const ExchangeRatesModel({
    required super.gbpToTry,
    super.lastUpdated,
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRatesModel(
      gbpToTry: (json['gbp_to_try'] as num).toDouble(),
      lastUpdated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gbp_to_try': gbpToTry,
      'last_updated': lastUpdated,
    };
  }
}
