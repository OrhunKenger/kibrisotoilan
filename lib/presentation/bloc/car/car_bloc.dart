import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/get_cars_usecase.dart';
import '../../../domain/usecases/get_car_by_id_usecase.dart';
import '../../../domain/usecases/create_car_usecase.dart';
import '../../../domain/usecases/add_favorite_usecase.dart';
import '../../../domain/usecases/remove_favorite_usecase.dart';
import '../../../domain/usecases/get_my_favorites_usecase.dart';
import '../../../domain/usecases/get_unique_brands_usecase.dart';
import '../../../domain/usecases/get_models_by_brand_usecase.dart';
import '../../../domain/entities/car_entity.dart'; // Eklendi

import 'car_event.dart';
import 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCarsUseCase;
  final GetCarById getCarByIdUseCase;
  final CreateCar createCarUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;
  final GetMyFavorites getMyFavoritesUseCase;
  final GetUniqueBrands getUniqueBrandsUseCase;
  final GetModelsByBrand getModelsByBrandUseCase;

  // Hafızada tutulan son araç listesi
  List<CarEntity> _lastCars = [];

  CarBloc({
    required this.getCarsUseCase,
    required this.getCarByIdUseCase,
    required this.createCarUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getMyFavoritesUseCase,
    required this.getUniqueBrandsUseCase,
    required this.getModelsByBrandUseCase,
  }) : super(const CarInitial()) {
    on<GetCarsEvent>(_onGetCars);
    on<GetCarDetailEvent>(_onGetCarDetail);
    on<CreateCarEvent>(_onCreateCar);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<GetMyFavoritesEvent>(_onGetMyFavorites);
    on<GetUniqueBrandsEvent>(_onGetUniqueBrands);
    on<GetModelsByBrandEvent>(_onGetModelsByBrand);
  }

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is ConnectionFailure) return failure.message;
    return 'İşlem sırasında bir hata oluştu';
  }

  Future<void> _onGetCars(GetCarsEvent event, Emitter<CarState> emit) async {
    if (event.page == 1 && _lastCars.isEmpty) emit(const CarLoading());

    final result = await getCarsUseCase(GetCarsParams(
      brand: event.brand, model: event.model, minPrice: event.minPrice, maxPrice: event.maxPrice,
      currency: event.currency, steering: event.steering, city: event.city,
      minMileage: event.minMileage, maxMileage: event.maxMileage, engineSize: event.engineSize,
      bodyType: event.bodyType, transmission: event.transmission, color: event.color,
      page: event.page, limit: event.limit, sortBy: event.sortBy, sortOrder: event.sortOrder,
    ));

    result.fold(
      (failure) => emit(CarError(message: _failureMessage(failure))),
      (newCars) {
        if (event.page == 1) {
          _lastCars = newCars;
        } else {
          _lastCars = [..._lastCars, ...newCars];
        }
        emit(CarsLoaded(cars: List.from(_lastCars), hasReachedMax: newCars.length < event.limit, currentPage: event.page));
      },
    );
  }

  Future<void> _onGetCarDetail(GetCarDetailEvent event, Emitter<CarState> emit) async {
    final result = await getCarByIdUseCase(event.carId);
    result.fold(
      (failure) => emit(CarError(message: _failureMessage(failure))),
      (updatedCar) {
        // Listeyi güncelle ve yay
        _lastCars = _lastCars.map((c) => c.id == updatedCar.id ? updatedCar : c).toList();
        emit(CarsLoaded(cars: List.from(_lastCars), hasReachedMax: false, currentPage: 1));
        emit(CarDetailLoaded(car: updatedCar));
      },
    );
  }

  // Diğer metodlar...
  Future<void> _onGetUniqueBrands(GetUniqueBrandsEvent event, Emitter<CarState> emit) async {
    final result = await getUniqueBrandsUseCase();
    result.fold((f) => emit(CarError(message: _failureMessage(f))), (b) => emit(CarBrandsLoaded(brands: b)));
  }

  Future<void> _onGetModelsByBrand(GetModelsByBrandEvent event, Emitter<CarState> emit) async {
    final result = await getModelsByBrandUseCase(GetModelsByBrandParams(brand: event.brand));
    result.fold((f) => emit(CarError(message: _failureMessage(f))), (m) => emit(CarModelsLoaded(models: m, brand: event.brand)));
  }

  Future<void> _onCreateCar(CreateCarEvent event, Emitter<CarState> emit) async {
    emit(const CarCreating());
    final result = await createCarUseCase(event.car);
    result.fold((f) => emit(CarCreateError(message: _failureMessage(f))), (c) => emit(CarCreated(car: c)));
  }

  Future<void> _onAddFavorite(AddFavoriteEvent event, Emitter<CarState> emit) async {
    final result = await addFavoriteUseCase(event.carId);
    result.fold((f) => emit(FavoriteError(message: _failureMessage(f))), (_) => emit(FavoriteToggled(carId: event.carId, isFavorite: true)));
  }

  Future<void> _onRemoveFavorite(RemoveFavoriteEvent event, Emitter<CarState> emit) async {
    final result = await removeFavoriteUseCase(event.carId);
    result.fold((f) => emit(FavoriteError(message: _failureMessage(f))), (_) => emit(FavoriteToggled(carId: event.carId, isFavorite: false)));
  }

  Future<void> _onGetMyFavorites(GetMyFavoritesEvent event, Emitter<CarState> emit) async {
    if (event.page == 1) emit(const FavoritesLoading());
    final result = await getMyFavoritesUseCase(GetMyFavoritesParams(page: event.page, limit: event.limit));
    result.fold((f) => emit(FavoriteError(message: _failureMessage(f))), (faves) => emit(FavoritesLoaded(favorites: faves, hasReachedMax: faves.length < event.limit, currentPage: event.page)));
  }
}
