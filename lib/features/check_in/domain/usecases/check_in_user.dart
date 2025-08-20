import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in.dart';
import '../entities/check_in_point.dart';
import '../repositories/check_in_repository.dart';

/// Use case for checking a user into a check-in point
class CheckInUser implements UseCase<CheckIn, CheckInUserParams> {
  final CheckInRepository repository;

  const CheckInUser(this.repository);

  @override
  Future<Either<Failure, CheckIn>> call(CheckInUserParams params) async {
    return await repository.checkInUser(
      userId: params.userId,
      checkInPointId: params.checkInPointId,
      userLocation: params.userLocation,
    );
  }
}

/// Parameters required for checking in a user
class CheckInUserParams extends Equatable {
  final String userId;
  final String checkInPointId;
  final GeoLocation userLocation;

  const CheckInUserParams({
    required this.userId,
    required this.checkInPointId,
    required this.userLocation,
  });

  @override
  List<Object> get props => [userId, checkInPointId, userLocation];
}
