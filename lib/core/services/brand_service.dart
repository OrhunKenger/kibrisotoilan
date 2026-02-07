import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BrandInfo {
  final int id;
  final String name;
  final String? logoUrl;

  const BrandInfo({required this.id, required this.name, this.logoUrl});

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class SeriesGroup {
  final int id;
  final String series;
  final List<String> models;

  const SeriesGroup({required this.id, required this.series, required this.models});

  factory SeriesGroup.fromJson(Map<String, dynamic> json) {
    return SeriesGroup(
      id: json['id'] as int,
      series: json['series'] as String,
      models: (json['models'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class BrandService {
  final Dio _dio;
  List<BrandInfo>? _brandsCache;
  final Map<int, List<SeriesGroup>> _modelsCache = {};

  BrandService({required Dio dio}) : _dio = dio;

  List<BrandInfo> get brands => _brandsCache ?? const [];
  bool get isLoaded => _brandsCache != null;

  Future<List<BrandInfo>> loadBrands() async {
    if (_brandsCache != null) return _brandsCache!;
    try {
      final response = await _dio.get('/brands');
      final data = response.data as Map<String, dynamic>;
      _brandsCache = (data['brands'] as List<dynamic>)
          .map((e) => BrandInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('BrandService: failed to load brands: $e');
      _brandsCache = [];
    }
    return _brandsCache!;
  }

  Future<List<SeriesGroup>> loadModels(int brandId) async {
    if (_modelsCache.containsKey(brandId)) return _modelsCache[brandId]!;
    try {
      final response = await _dio.get('/brands/$brandId/models');
      final list = (response.data as List<dynamic>)
          .map((e) => SeriesGroup.fromJson(e as Map<String, dynamic>))
          .toList();
      _modelsCache[brandId] = list;
    } catch (e) {
      if (kDebugMode) debugPrint('BrandService: failed to load models for brand $brandId: $e');
      _modelsCache[brandId] = [];
    }
    return _modelsCache[brandId]!;
  }
}
