import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/user_repository.dart';

class GetMyListings implements UseCase<List<CarEntity>, GetMyListingsParams> {
  final UserRepository repository;

  GetMyListings(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(GetMyListingsParams params) async {
    return await repository.getMyListings(page: params.page, limit: params.limit);
  }
}

class GetMyListingsParams extends Equatable {
  final int page;
  final int limit;

  const GetMyListingsParams({required this.page, required this.limit});

  @override
  List<Object> get props => [page, limit];
}
