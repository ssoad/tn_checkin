import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_repository.dart';

/// Use case for signing out the current user
class SignOut implements UseCase<Unit, NoParams> {
  final UserRepository repository;

  const SignOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.signOut();
  }
}
