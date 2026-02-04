import '../../domain/entities/car_enums.dart';
import '../../injection_container.dart';
import '../services/lookup_service.dart';

/// API serialization strings (English, matching backend)
class EnumSerializer {
  EnumSerializer._();

  static const Map<Currency, String> currency = {
    Currency.gbp: 'GBP',
    Currency.eur: 'EUR',
    Currency.usd: 'USD',
    Currency.try_: 'TRY',
  };

  static const Map<SteeringType, String> steering = {
    SteeringType.right: 'Right',
    SteeringType.left: 'Left',
  };

  static const Map<BodyType, String> bodyType = {
    BodyType.sedan: 'Sedan',
    BodyType.hatchback: 'Hatchback',
    BodyType.suv: 'SUV',
    BodyType.coupe: 'Coupe',
    BodyType.convertible: 'Convertible',
    BodyType.van: 'Van',
    BodyType.pickup: 'Pickup',
  };

  static const Map<TransmissionType, String> transmission = {
    TransmissionType.manual: 'Manual',
    TransmissionType.automatic: 'Automatic',
    TransmissionType.semiAutomatic: 'Semi-Automatic',
  };

  static const Map<MileageUnit, String> mileageUnit = {
    MileageUnit.km: 'km',
    MileageUnit.miles: 'miles',
  };
}

/// Turkish UI labels - uses LookupService when available, falls back to hardcoded
class EnumLabels {
  EnumLabels._();

  static Map<Currency, String> get currency {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.currencyValueToLabel.isNotEmpty) {
      final m = svc.currencyValueToLabel;
      return {
        Currency.gbp: m['GBP'] ?? _fallbackCurrency[Currency.gbp]!,
        Currency.eur: m['EUR'] ?? _fallbackCurrency[Currency.eur]!,
        Currency.usd: m['USD'] ?? _fallbackCurrency[Currency.usd]!,
        Currency.try_: m['TRY'] ?? _fallbackCurrency[Currency.try_]!,
      };
    }
    return _fallbackCurrency;
  }

  static const Map<Currency, String> _fallbackCurrency = {
    Currency.gbp: 'GBP - Sterlin',
    Currency.eur: 'EUR - Euro',
    Currency.usd: 'USD - Dolar',
    Currency.try_: 'TRY - TL',
  };

  static const Map<Currency, String> currencyShort = {
    Currency.gbp: 'GBP',
    Currency.eur: 'EUR',
    Currency.usd: 'USD',
    Currency.try_: 'TL',
  };

  static Map<SteeringType, String> get steering {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.steeringValueToLabel.isNotEmpty) {
      final m = svc.steeringValueToLabel;
      return {
        SteeringType.right: m['right'] ?? _fallbackSteering[SteeringType.right]!,
        SteeringType.left: m['left'] ?? _fallbackSteering[SteeringType.left]!,
      };
    }
    return _fallbackSteering;
  }

  static const Map<SteeringType, String> _fallbackSteering = {
    SteeringType.right: 'Sağ',
    SteeringType.left: 'Sol',
  };

  static Map<BodyType, String> get bodyType {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.bodyTypeValueToLabel.isNotEmpty) {
      final m = svc.bodyTypeValueToLabel;
      return {
        BodyType.sedan: m['sedan'] ?? _fallbackBodyType[BodyType.sedan]!,
        BodyType.hatchback: m['hatchback'] ?? _fallbackBodyType[BodyType.hatchback]!,
        BodyType.suv: m['suv'] ?? _fallbackBodyType[BodyType.suv]!,
        BodyType.coupe: m['coupe'] ?? _fallbackBodyType[BodyType.coupe]!,
        BodyType.convertible: m['convertible'] ?? _fallbackBodyType[BodyType.convertible]!,
        BodyType.van: m['van'] ?? _fallbackBodyType[BodyType.van]!,
        BodyType.pickup: m['pickup'] ?? _fallbackBodyType[BodyType.pickup]!,
      };
    }
    return _fallbackBodyType;
  }

  static const Map<BodyType, String> _fallbackBodyType = {
    BodyType.sedan: 'Sedan',
    BodyType.hatchback: 'Hatchback',
    BodyType.suv: 'SUV',
    BodyType.coupe: 'Coupe',
    BodyType.convertible: 'Cabrio',
    BodyType.van: 'Panelvan',
    BodyType.pickup: 'Pickup',
  };

  static Map<TransmissionType, String> get transmission {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.transmissionValueToLabel.isNotEmpty) {
      final m = svc.transmissionValueToLabel;
      return {
        TransmissionType.manual: m['manual'] ?? _fallbackTransmission[TransmissionType.manual]!,
        TransmissionType.automatic: m['automatic'] ?? _fallbackTransmission[TransmissionType.automatic]!,
        TransmissionType.semiAutomatic: m['semi_automatic'] ?? _fallbackTransmission[TransmissionType.semiAutomatic]!,
      };
    }
    return _fallbackTransmission;
  }

  static const Map<TransmissionType, String> _fallbackTransmission = {
    TransmissionType.manual: 'Manuel',
    TransmissionType.automatic: 'Otomatik',
    TransmissionType.semiAutomatic: 'Yarı Otomatik',
  };

  static Map<MileageUnit, String> get mileageUnit {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.mileageUnitValueToLabel.isNotEmpty) {
      final m = svc.mileageUnitValueToLabel;
      return {
        MileageUnit.km: m['km'] ?? _fallbackMileageUnit[MileageUnit.km]!,
        MileageUnit.miles: m['miles'] ?? _fallbackMileageUnit[MileageUnit.miles]!,
      };
    }
    return _fallbackMileageUnit;
  }

  static const Map<MileageUnit, String> _fallbackMileageUnit = {
    MileageUnit.km: 'KM',
    MileageUnit.miles: 'Mil',
  };

  static List<String> get fuelTypeLabels {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.fuelTypeLabels.isNotEmpty) {
      return svc.fuelTypeLabels;
    }
    return const ['Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'];
  }

  static String fuelType(String? fuel) {
    if (fuel == null || fuel.isEmpty) return 'Bilinmiyor';

    // Try lookup service first
    final svc = sl<LookupService>();
    if (svc.isLoaded) {
      final label = svc.fuelTypeValueToLabel[fuel.toLowerCase()];
      if (label != null) return label;
    }

    switch (fuel.toLowerCase()) {
      case 'gasoline':
      case 'benzin':
        return 'Benzin';
      case 'diesel':
      case 'dizel':
        return 'Dizel';
      case 'electric':
      case 'elektrik':
        return 'Elektrik';
      case 'hybrid':
      case 'hibrit':
        return 'Hibrit';
      case 'lpg':
        return 'LPG';
      default:
        return fuel;
    }
  }
}
