import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/usecases/get_cars_usecase.dart';
import '../../../domain/usecases/get_car_by_id_usecase.dart';
import '../../../domain/usecases/create_car_usecase.dart';
import '../../../domain/usecases/add_favorite_usecase.dart';
import '../../../domain/usecases/remove_favorite_usecase.dart';
import '../../../domain/usecases/get_my_favorites_usecase.dart';

import 'car_event.dart';
import 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCarsUseCase;
  final GetCarById getCarByIdUseCase;
  final CreateCar createCarUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;
  final GetMyFavorites getMyFavoritesUseCase;

  CarBloc({
    required this.getCarsUseCase,
    required this.getCarByIdUseCase,
    required this.createCarUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getMyFavoritesUseCase,
  }) : super(const CarInitial()) {
    on<GetCarsEvent>(_onGetCars);
    on<GetCarDetailEvent>(_onGetCarDetail);
    on<CreateCarEvent>(_onCreateCar);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<GetMyFavoritesEvent>(_onGetMyFavorites);
  }

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is ConnectionFailure) return failure.message;
    if (failure is UnauthorizedFailure) return 'Oturum süresi doldu';
    return 'Beklenmeyen bir hata oluştu';
  }

  Future<void> _onGetCars(GetCarsEvent event, Emitter<CarState> emit) async {
    final currentState = state;

    // Zaten son sayfadaysak ve daha fazla yuklenmeye calisiliyorsa dur
    if (event.page > 1 && currentState is CarsLoaded && currentState.hasReachedMax) {
      return;
    }

    // Ilk sayfa ise loading goster
    if (event.page == 1) {
      emit(const CarLoading());
    }

    final result = await getCarsUseCase(
      GetCarsParams(
        brand: event.brand,
        model: event.model,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        currency: event.currency,
        steering: event.steering,
        city: event.city,
        minMileage: event.minMileage,
        maxMileage: event.maxMileage,
        engineSize: event.engineSize,
        bodyType: event.bodyType,
        transmission: event.transmission,
        color: event.color,
        page: event.page,
        limit: event.limit,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ),
    );
    result.fold(
      (failure) => emit(CarError(message: _failureMessage(failure))),
      (newCars) {
        if (event.page == 1) {
          emit(CarsLoaded(
            cars: newCars,
            hasReachedMax: newCars.length < event.limit,
            currentPage: 1,
          ));
        } else if (currentState is CarsLoaded) {
          emit(CarsLoaded(
            cars: [...currentState.cars, ...newCars],
            hasReachedMax: newCars.length < event.limit,
            currentPage: event.page,
          ));
        }
      },
    );
  }

  Future<void> _onGetCarDetail(GetCarDetailEvent event, Emitter<CarState> emit) async {
    emit(const CarLoading());
    final result = await getCarByIdUseCase(event.carId);
    result.fold(
      (failure) => emit(CarError(message: _failureMessage(failure))),
      (car) => emit(CarDetailLoaded(car: car)),
    );
  }

  Future<void> _onCreateCar(CreateCarEvent event, Emitter<CarState> emit) async {
    emit(const CarCreating());
    final result = await createCarUseCase(event.car);
    result.fold(
      (failure) => emit(CarCreateError(message: _failureMessage(failure))),
      (car) => emit(CarCreated(car: car)),
    );
  }

  Future<void> _onAddFavorite(AddFavoriteEvent event, Emitter<CarState> emit) async {
    final result = await addFavoriteUseCase(event.carId);
    result.fold(
      (failure) => emit(FavoriteError(message: _failureMessage(failure))),
      (_) => emit(FavoriteToggled(carId: event.carId, isFavorite: true)),
    );
  }

  Future<void> _onRemoveFavorite(RemoveFavoriteEvent event, Emitter<CarState> emit) async {
    final result = await removeFavoriteUseCase(event.carId);
    result.fold(
      (failure) => emit(FavoriteError(message: _failureMessage(failure))),
      (_) => emit(FavoriteToggled(carId: event.carId, isFavorite: false)),
    );
  }

  Future<void> _onGetMyFavorites(GetMyFavoritesEvent event, Emitter<CarState> emit) async {
    final currentState = state;

    // Zaten son sayfadaysak ve daha fazla yuklenmeye calisiliyorsa dur
    if (event.page > 1 && currentState is FavoritesLoaded && currentState.hasReachedMax) {
      return;
    }

    // Ilk sayfa ise loading goster
    if (event.page == 1) {
      emit(const FavoritesLoading());
    }

    final result = await getMyFavoritesUseCase(
      GetMyFavoritesParams(page: event.page, limit: event.limit),
    );
    result.fold(
      (failure) => emit(FavoriteError(message: _failureMessage(failure))),
      (newFavorites) {
        if (event.page == 1) {
          emit(FavoritesLoaded(
            favorites: newFavorites,
            hasReachedMax: newFavorites.length < event.limit,
            currentPage: 1,
          ));
        } else if (currentState is FavoritesLoaded) {
          emit(FavoritesLoaded(
            favorites: [...currentState.favorites, ...newFavorites],
            hasReachedMax: newFavorites.length < event.limit,
            currentPage: event.page,
          ));
        }
      },
    );
  }
}
