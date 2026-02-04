import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfile implements UseCase<UserEntity, Map<String, dynamic>> {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(Map<String, dynamic> params) async {
    return await repository.updateUserProfile(params);
  }
}
