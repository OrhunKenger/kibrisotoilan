import 'package:dio/dio.dart';
import '../../core/network/dio_error_handler.dart';
import '../../domain/entities/car_enums.dart';
import '../models/car_model.dart';
import 'dart:typed_data';

// region Enum to String Mappers for API
const Map<Currency, String> _currencyToString = {
  Currency.gbp: 'GBP',
  Currency.eur: 'EUR',
  Currency.usd: 'USD',
  Currency.try_: 'TRY',
};

const Map<SteeringType, String> _steeringTypeToString = {
  SteeringType.right: 'Right',
  SteeringType.left: 'Left',
};

const Map<BodyType, String> _bodyTypeToString = {
  BodyType.sedan: 'Sedan',
  BodyType.hatchback: 'Hatchback',
  BodyType.suv: 'SUV',
  BodyType.coupe: 'Coupe',
  BodyType.convertible: 'Convertible',
  BodyType.van: 'Van',
  BodyType.pickup: 'Pickup',
};

const Map<TransmissionType, String> _transmissionTypeToString = {
  TransmissionType.manual: 'Manual',
  TransmissionType.automatic: 'Automatic',
  TransmissionType.semiAutomatic: 'Semi-Automatic',
};
// endregion

abstract class ImageUploadDataSource {
  Future<List<String>> uploadImages(List<String> filePaths);
}

abstract class CarRemoteDataSource {
  Future<List<CarModel>> getCars({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    Currency? currency,
    SteeringType? steering,
    String? city,
    int? minMileage,
    int? maxMileage,
    int? engineSize,
    BodyType? bodyType,
    TransmissionType? transmission,
    String? color,
    required int page,
    required int limit,
    required String sortBy,
    required String sortOrder,
  });

  Future<CarModel> getCarById(int id);
  Future<CarModel> createCar(CarModel car);
  Future<void> addFavorite(int id);
  Future<void> removeFavorite(int id);
  Future<List<CarModel>> getMyFavorites({required int page, required int limit});
}

class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final Dio dio;

  CarRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CarModel>> getCars({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    Currency? currency,
    SteeringType? steering,
    String? city,
    int? minMileage,
    int? maxMileage,
    int? engineSize,
    BodyType? bodyType,
    TransmissionType? transmission,
    String? color,
    required int page,
    required int limit,
    required String sortBy,
    required String sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': limit,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (currency != null) 'currency': _currencyToString[currency],
      if (steering != null) 'steering': _steeringTypeToString[steering],
      if (city != null) 'city': city,
      if (minMileage != null) 'min_mileage': minMileage,
      if (maxMileage != null) 'max_mileage': maxMileage,
      if (engineSize != null) 'engine_size': engineSize,
      if (bodyType != null) 'body_type': _bodyTypeToString[bodyType],
      if (transmission != null) 'transmission': _transmissionTypeToString[transmission],
      if (color != null) 'color': color,
    };

    try {
      final response = await dio.get('/cars', queryParameters: queryParameters);
      List<dynamic> dataList;

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('items')) {
          dataList = response.data['items'];
        } else if (response.data.containsKey('data')) {
          dataList = response.data['data'];
        } else {
          dataList = [];
        }
      } else if (response.data is List) {
        dataList = response.data;
      } else {
        dataList = [];
      }

      return dataList.map((e) => CarModel.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<CarModel> getCarById(int id) async {
    try {
      final response = await dio.get('/cars/$id');
      return CarModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<CarModel> createCar(CarModel car) async {
    try {
      final json = car.toJson();
      json.removeWhere((key, value) =>
          value == null ||
          key == 'id' ||
          key == 'owner_id' ||
          key == 'created_at' ||
          key == 'updated_at' ||
          key == 'is_deleted');
      final response = await dio.post('/cars', data: json);
      return CarModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> addFavorite(int id) async {
    try {
      await dio.post('/cars/$id/favorite');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    try {
      await dio.delete('/cars/$id/favorite');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<List<CarModel>> getMyFavorites({required int page, required int limit}) async {
    try {
      final response = await dio.get(
        '/users/me/favorites',
        queryParameters: {'page': page, 'size': limit},
      );
      final data = response.data as List;
      return data.map((json) => CarModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<List<String>> uploadImages(List<Uint8List> imageBytes, List<String> fileNames) async {
    try {
      final formData = FormData();
      for (int i = 0; i < imageBytes.length; i++) {
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(imageBytes[i], filename: fileNames[i]),
        ));
      }
      final response = await dio.post('/upload/images', data: formData);
      return (response.data as List).map((e) => e as String).toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) => DioErrorHandler.handle(e);
}
