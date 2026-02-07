import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/brand_entity.dart';
import '../repositories/car_repository.dart';

class GetAllBrands {
  final CarRepository repository;

  GetAllBrands(this.repository);

  Future<Either<Failure, List<BrandEntity>>> call() async {
    return await repository.getAllBrands();
  }
}
