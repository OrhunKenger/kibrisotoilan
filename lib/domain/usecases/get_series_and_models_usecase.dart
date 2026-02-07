import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../presentation/bloc/car/car_state.dart';
import '../repositories/car_repository.dart';

class GetSeriesAndModels {
  final CarRepository repository;

  GetSeriesAndModels(this.repository);

  Future<Either<Failure, List<SeriesModels>>> call(int brandId) async {
    return await repository.getSeriesAndModels(brandId);
  }
}
