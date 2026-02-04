class LookupItem {
  final int id;
  final String value;
  final String labelTr;
  final String? labelEn;
  final int sortOrder;

  const LookupItem({
    required this.id,
    required this.value,
    required this.labelTr,
    this.labelEn,
    this.sortOrder = 0,
  });

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'] as int,
      value: json['value'] as String,
      labelTr: json['label_tr'] as String,
      labelEn: json['label_en'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class CityLookup {
  final int id;
  final String value;
  final String labelTr;
  final String? labelEn;
  final int sortOrder;
  final List<LookupItem> districts;

  const CityLookup({
    required this.id,
    required this.value,
    required this.labelTr,
    this.labelEn,
    this.sortOrder = 0,
    this.districts = const [],
  });

  factory CityLookup.fromJson(Map<String, dynamic> json) {
    return CityLookup(
      id: json['id'] as int,
      value: json['value'] as String,
      labelTr: json['label_tr'] as String,
      labelEn: json['label_en'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      districts: (json['districts'] as List<dynamic>?)
              ?.map((d) => LookupItem.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LookupsData {
  final List<CityLookup> cities;
  final List<LookupItem> fuelTypes;
  final List<LookupItem> bodyTypes;
  final List<LookupItem> transmissionTypes;
  final List<LookupItem> steeringTypes;
  final List<LookupItem> currencies;
  final List<LookupItem> mileageUnits;

  const LookupsData({
    this.cities = const [],
    this.fuelTypes = const [],
    this.bodyTypes = const [],
    this.transmissionTypes = const [],
    this.steeringTypes = const [],
    this.currencies = const [],
    this.mileageUnits = const [],
  });

  factory LookupsData.fromJson(Map<String, dynamic> json) {
    return LookupsData(
      cities: (json['cities'] as List<dynamic>?)
              ?.map((c) => CityLookup.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      fuelTypes: _parseItems(json['fuel_types']),
      bodyTypes: _parseItems(json['body_types']),
      transmissionTypes: _parseItems(json['transmission_types']),
      steeringTypes: _parseItems(json['steering_types']),
      currencies: _parseItems(json['currencies']),
      mileageUnits: _parseItems(json['mileage_units']),
    );
  }

  static List<LookupItem> _parseItems(dynamic list) {
    if (list == null) return [];
    return (list as List<dynamic>)
        .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
