import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class GetCarById implements UseCase<CarEntity, int> {
  final CarRepository repository;

  GetCarById(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(int params) async {
    return await repository.getCarById(params);
  }
}
