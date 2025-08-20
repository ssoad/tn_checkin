import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for signing up a new user with email and password
class SignUpWithEmailAndPassword implements UseCase<User, SignUpParams> {
  final UserRepository repository;

  const SignUpWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
      userType: params.userType,
    );
  }
}

/// Parameters required for signing up
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final UserType userType;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });

  @override
  List<Object> get props => [email, password, name, userType];
}
