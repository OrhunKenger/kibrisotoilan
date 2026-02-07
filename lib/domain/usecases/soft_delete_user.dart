import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

class SoftDeleteUser {
  final UserRepository repository;

  SoftDeleteUser(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteUser();
  }
}