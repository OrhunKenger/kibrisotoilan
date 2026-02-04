// frontend/mobile/lib/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfile implements UseCase<UserEntity, NoParams> {
  final UserRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
