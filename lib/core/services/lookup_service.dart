import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/lookup_model.dart';

class LookupService {
  final Dio _dio;
  LookupsData? _cache;

  LookupService({required Dio dio}) : _dio = dio;

  LookupsData get data => _cache ?? const LookupsData();

  bool get isLoaded => _cache != null;

  /// Load all lookups from the backend. Safe to call multiple times.
  Future<void> loadLookups() async {
    if (_cache != null) return;
    try {
      final response = await _dio.get('/lookups');
      _cache = LookupsData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('LookupService: failed to load lookups: $e');
      // Fallback: leave cache null, consumers use hardcoded defaults
    }
  }

  /// Force refresh from backend.
  Future<void> refresh() async {
    _cache = null;
    await loadLookups();
  }

  // ---- Convenience getters ----

  List<String> get cityNames =>
      data.cities.map((c) => c.labelTr).toList();

  Map<String, List<String>> get districtsByCityName {
    final map = <String, List<String>>{};
    for (final city in data.cities) {
      map[city.labelTr] = city.districts.map((d) => d.labelTr).toList();
    }
    return map;
  }

  List<String> get fuelTypeLabels =>
      data.fuelTypes.map((f) => f.labelTr).toList();

  Map<String, String> get fuelTypeValueToLabel {
    final map = <String, String>{};
    for (final f in data.fuelTypes) {
      map[f.value] = f.labelTr;
    }
    return map;
  }

  Map<String, String> get bodyTypeValueToLabel {
    final map = <String, String>{};
    for (final b in data.bodyTypes) {
      map[b.value] = b.labelTr;
    }
    return map;
  }

  Map<String, String> get transmissionValueToLabel {
    final map = <String, String>{};
    for (final t in data.transmissionTypes) {
      map[t.value] = t.labelTr;
    }
    return map;
  }

  Map<String, String> get steeringValueToLabel {
    final map = <String, String>{};
    for (final s in data.steeringTypes) {
      map[s.value] = s.labelTr;
    }
    return map;
  }

  Map<String, String> get currencyValueToLabel {
    final map = <String, String>{};
    for (final c in data.currencies) {
      map[c.value] = c.labelTr;
    }
    return map;
  }

  Map<String, String> get mileageUnitValueToLabel {
    final map = <String, String>{};
    for (final m in data.mileageUnits) {
      map[m.value] = m.labelTr;
    }
    return map;
  }
}
