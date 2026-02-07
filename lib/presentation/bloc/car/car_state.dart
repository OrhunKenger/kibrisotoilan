import 'package:equatable/equatable.dart';
import '../../../domain/entities/car_entity.dart';

abstract class CarState extends Equatable {
  const CarState();

  @override
  List<Object?> get props => [];
}

class CarInitial extends CarState {
  const CarInitial();
}

class CarLoading extends CarState {
  const CarLoading();
}

class CarsLoaded extends CarState {
  final List<CarEntity> cars;
  final bool hasReachedMax;
  final int currentPage;
  const CarsLoaded({
    required this.cars,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [cars, hasReachedMax, currentPage];
}

class CarDetailLoaded extends CarState {
  final CarEntity car;
  const CarDetailLoaded({required this.car});

  @override
  List<Object?> get props => [car];
}

class CarError extends CarState {
  final String message;
  const CarError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarCreating extends CarState {
  const CarCreating();
}

class CarCreated extends CarState {
  final CarEntity car;
  const CarCreated({required this.car});

  @override
  List<Object?> get props => [car];
}

class CarCreateError extends CarState {
  final String message;
  const CarCreateError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FavoritesLoading extends CarState {
  const FavoritesLoading();
}

class FavoritesLoaded extends CarState {
  final List<CarEntity> favorites;
  final bool hasReachedMax;
  final int currentPage;
  const FavoritesLoaded({
    required this.favorites,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [favorites, hasReachedMax, currentPage];
}

class FavoriteToggled extends CarState {
  final int carId;
  final bool isFavorite;
  const FavoriteToggled({required this.carId, required this.isFavorite});

  @override
  List<Object?> get props => [carId, isFavorite];
}

class FavoriteError extends CarState {
  final String message;
  const FavoriteError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarBrandsLoaded extends CarState {
  final List<String> brands;
  const CarBrandsLoaded({required this.brands});

  @override
  List<Object?> get props => [brands];
}

class CarModelsLoaded extends CarState {
  final List<String> models;
  final String brand; // To identify which brand these models belong to
  const CarModelsLoaded({required this.models, required this.brand});

  @override
  List<Object?> get props => [models, brand];
}
