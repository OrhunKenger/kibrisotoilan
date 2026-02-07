import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/car_repository.dart';

class GetUniqueBrands {
  final CarRepository repository;

  GetUniqueBrands(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getUniqueBrands();
  }
}
