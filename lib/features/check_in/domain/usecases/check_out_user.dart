import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in.dart';
import '../entities/check_in_point.dart';
import '../repositories/check_in_repository.dart';

/// Use case for checking a user out of a check-in point
class CheckOutUser implements UseCase<CheckIn, CheckOutUserParams> {
  final CheckInRepository repository;

  const CheckOutUser(this.repository);

  @override
  Future<Either<Failure, CheckIn>> call(CheckOutUserParams params) async {
    return await repository.checkOutUser(
      userId: params.userId,
      checkInPointId: params.checkInPointId,
      userLocation: params.userLocation,
    );
  }
}

/// Parameters required for checking out a user
class CheckOutUserParams extends Equatable {
  final String userId;
  final String checkInPointId;
  final GeoLocation userLocation;

  const CheckOutUserParams({
    required this.userId,
    required this.checkInPointId,
    required this.userLocation,
  });

  @override
  List<Object> get props => [userId, checkInPointId, userLocation];
}
