import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class GetMyFavorites implements UseCase<List<CarEntity>, GetMyFavoritesParams> {
  final CarRepository repository;

  GetMyFavorites(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(GetMyFavoritesParams params) async {
    return await repository.getMyFavorites(page: params.page, limit: params.limit);
  }
}

class GetMyFavoritesParams extends Equatable {
  final int page;
  final int limit;

  const GetMyFavoritesParams({required this.page, required this.limit});

  @override
  List<Object> get props => [page, limit];
}
