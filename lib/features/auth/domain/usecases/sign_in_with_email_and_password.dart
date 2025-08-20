import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for signing in a user with email and password
class SignInWithEmailAndPassword implements UseCase<User, SignInParams> {
  final UserRepository repository;

  const SignInWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters required for signing in
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
