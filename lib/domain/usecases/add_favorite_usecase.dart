import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

class AddFavorite implements UseCase<Unit, int> {
  final CarRepository repository;

  AddFavorite(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int params) async {
    return await repository.addFavorite(params);
  }
}
