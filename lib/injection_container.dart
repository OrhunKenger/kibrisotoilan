import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

// Core
import 'core/config/env_config.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/retry_interceptor.dart';
import 'core/services/lookup_service.dart';
import 'core/services/brand_service.dart';

// Data sources
import 'data/datasources/car_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/datasources/user_remote_data_source_impl.dart';

// Repositories
import 'data/repositories/car_repository_impl.dart';
import 'domain/repositories/car_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';

// Use cases
import 'domain/usecases/get_cars_usecase.dart';
import 'domain/usecases/get_car_by_id_usecase.dart';
import 'domain/usecases/create_car_usecase.dart';
import 'domain/usecases/add_favorite_usecase.dart';
import 'domain/usecases/remove_favorite_usecase.dart';
import 'domain/usecases/get_my_favorites_usecase.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/update_user_profile_usecase.dart';
import 'domain/usecases/get_my_listings_usecase.dart';
import 'domain/usecases/soft_delete_user.dart'; // New Import
import 'domain/usecases/get_unique_brands_usecase.dart'; // Yeni
import 'domain/usecases/get_all_brands_usecase.dart'; // Yeni
import 'domain/usecases/get_series_and_models_usecase.dart'; // Yeni
import 'domain/usecases/get_models_by_brand_usecase.dart'; // Yeni

// Blocs
import 'presentation/bloc/car/car_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/user/user_bloc.dart';

final sl = GetIt.instance;

VoidCallback? _onUnauthorizedCallback;
bool _unauthorizedFired = false;

void setOnUnauthorized(VoidCallback callback) {
  _onUnauthorizedCallback = callback;
}

void resetUnauthorizedFlag() {
  _unauthorizedFired = false;
}

Future<void> init() async {
  // External
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Core
  sl.registerLazySingleton(() => AuthInterceptor(
        authLocalDataSource: sl(),
        onUnauthorized: () {
          if (!_unauthorizedFired) {
            _unauthorizedFired = true;
            _onUnauthorizedCallback?.call();
          }
        },
      ));

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
    ));

    dio.interceptors.add(sl<AuthInterceptor>());
    dio.interceptors.add(RetryInterceptor(dio: dio));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ));
    }

    return dio;
  });

  // Services
  sl.registerLazySingleton<LookupService>(
    () => LookupService(dio: sl()),
  );
  sl.registerLazySingleton<BrandService>(
    () => BrandService(dio: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CarRemoteDataSource>(
    () => CarRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCars(sl()));
  sl.registerLazySingleton(() => GetCarById(sl()));
  sl.registerLazySingleton(() => CreateCar(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => GetMyFavorites(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => GetMyListings(sl()));
  sl.registerLazySingleton(() => SoftDeleteUser(sl())); // New
  sl.registerLazySingleton(() => GetUniqueBrands(sl())); // Yeni
  sl.registerLazySingleton(() => GetAllBrands(sl())); // Yeni
  sl.registerLazySingleton(() => GetSeriesAndModels(sl())); // Yeni
  sl.registerLazySingleton(() => GetModelsByBrand(sl())); // Yeni

  // Blocs
  sl.registerFactory(() => CarBloc(
        getCarsUseCase: sl(),
        getCarByIdUseCase: sl(),
        createCarUseCase: sl(),
        addFavoriteUseCase: sl(),
        removeFavoriteUseCase: sl(),
        getMyFavoritesUseCase: sl(),
        getUniqueBrandsUseCase: sl(), // Yeni
        getAllBrandsUseCase: sl(), // Yeni
        getSeriesAndModelsUseCase: sl(), // Yeni
        getModelsByBrandUseCase: sl(), // Yeni
      ));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => UserBloc(
        getUserProfileUseCase: sl(),
        updateUserProfileUseCase: sl(),
        getMyListingsUseCase: sl(),
        softDeleteUserUseCase: sl(), // New
      ));
}
