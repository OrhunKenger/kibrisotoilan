import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../repositories/car_repository.dart';

class GetModelsByBrand {
  final CarRepository repository;

  GetModelsByBrand(this.repository);

  Future<Either<Failure, List<String>>> call(GetModelsByBrandParams params) async {
    return await repository.getModelsByBrand(params.brand);
  }
}

class GetModelsByBrandParams extends Equatable {
  final String brand;

  const GetModelsByBrandParams({required this.brand});

  @override
  List<Object> get props => [brand];
}
