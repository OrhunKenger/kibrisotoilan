import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';
import 'package:flutter/foundation.dart';

// region Enum Mappings
const Map<SteeringType, String> _steeringTypeToString = {
  SteeringType.right: 'Right',
  SteeringType.left: 'Left',
};
final Map<String, SteeringType> _stringToSteeringType =
    _steeringTypeToString.map((k, v) => MapEntry(v.toLowerCase(), k));

const Map<Currency, String> _currencyToString = {
  Currency.gbp: 'GBP',
  Currency.eur: 'EUR',
  Currency.usd: 'USD',
  Currency.try_: 'TRY',
};
final Map<String, Currency> _stringToCurrency =
    _currencyToString.map((k, v) => MapEntry(v.toUpperCase(), k));

const Map<MileageUnit, String> _mileageUnitToString = {
  MileageUnit.km: 'KM',
  MileageUnit.miles: 'Miles',
};
final Map<String, MileageUnit> _stringToMileageUnit =
    _mileageUnitToString.map((k, v) => MapEntry(v.toUpperCase(), k));

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
    _bodyTypeToString.map((k, v) => MapEntry(v.toLowerCase(), k));

const Map<TransmissionType, String> _transmissionTypeToString = {
  TransmissionType.manual: 'Manual',
  TransmissionType.automatic: 'Automatic',
  TransmissionType.semiAutomatic: 'Semi-Automatic',
};
final Map<String, TransmissionType> _stringToTransmissionType =
    _transmissionTypeToString.map((k, v) => MapEntry(v.toLowerCase().replaceAll('-', ''), k));
// endregion

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

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
    super.owner,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.status,
    super.viewsCount,
    super.exchangeRates,
    required super.steeringSide,
    required super.registrationStatus,
    super.licenseSeries,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper for nested/multiple keys
      dynamic getVal(String k1, String k2) => json[k1] ?? json[k2];

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
        steering: _stringToSteeringType[(json['steering'] as String?)?.toLowerCase()] ?? SteeringType.right,
        currency: _stringToCurrency[(json['currency'] as String?)?.toUpperCase()] ?? Currency.gbp,
        isFeatured: getVal('is_featured', 'isFeatured') ?? false,
        isUrgent: getVal('is_urgent', 'isUrgent') ?? false,
        mileage: json['mileage'] ?? 0,
        mileageUnit: _stringToMileageUnit[(getVal('mileage_unit', 'mileageUnit') as String?)?.toUpperCase()] ?? MileageUnit.km,
        engineSize: getVal('engine_size', 'engineSize') ?? 0,
        bodyType: _stringToBodyType[(getVal('body_type', 'bodyType') as String?)?.toLowerCase()] ?? BodyType.sedan,
        color: json['color'] ?? '',
        transmission: _stringToTransmissionType[(json['transmission'] as String?)?.toLowerCase().replaceAll('-', '')] ?? TransmissionType.automatic,
        isExchangeable: getVal('is_exchangeable', 'isExchangeable') ?? false,
        fuelType: getVal('fuel_type', 'fuelType'),
        imageUrls: _parseStringList(getVal('image_urls', 'imageUrls')),
        ownerId: getVal('owner_id', 'ownerId'),
        owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
        createdAt: getVal('created_at', 'createdAt') != null ? DateTime.tryParse(getVal('created_at', 'createdAt').toString()) : null,
        updatedAt: getVal('updated_at', 'updatedAt') != null ? DateTime.tryParse(getVal('updated_at', 'updatedAt').toString()) : null,
        isDeleted: getVal('is_deleted', 'isDeleted') ?? false,
        status: json['status'],
        viewsCount: _safeParseInt(json['views_count'] ?? json['viewsCount']),
        exchangeRates: getVal('exchange_rates', 'exchangeRates') != null ? ExchangeRatesModel.fromJson(getVal('exchange_rates', 'exchangeRates')) : null,
        steeringSide: getVal('steering_side', 'steeringSide') ?? 'Sağ',
        registrationStatus: getVal('registration_status', 'registrationStatus') ?? 'Belirtilmemiş',
        licenseSeries: getVal('license_series', 'licenseSeries'),
      );
    } catch (e, stack) {
      if (kDebugMode) print('CRITICAL: CarModel.fromJson error: $e\n$stack\nJSON: $json');
      rethrow;
    }
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
      'owner': owner != null ? (owner as UserModel).toJson() : null,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'status': status,
      'views_count': viewsCount,
      'exchange_rates': exchangeRates != null ? (exchangeRates as ExchangeRatesModel).toJson() : null,
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
    final gbpRate = json['gbp_to_try'] ?? json['gbpToTry'];
    final updated = json['last_updated'] ?? json['lastUpdated'];
    
    return ExchangeRatesModel(
      gbpToTry: (gbpRate is num) ? gbpRate.toDouble() : 0.0,
      lastUpdated: updated?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gbp_to_try': gbpToTry,
      'last_updated': lastUpdated,
    };
  }
}