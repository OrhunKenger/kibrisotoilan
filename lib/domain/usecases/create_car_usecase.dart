import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class CreateCar implements UseCase<CarEntity, CarEntity> {
  final CarRepository repository;

  CreateCar(this.repository);

  @override
  Future<Either<Failure, CarEntity>> call(CarEntity params) async {
    return await repository.createCar(params);
  }
}
