import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_point.dart';
import '../entities/check_in.dart';
import '../repositories/check_in_repository.dart';

class CheckOutUser implements UseCase<CheckIn, CheckOutUserParams> {
  final CheckInRepository repository;

  CheckOutUser(this.repository);

  @override
  Future<Either<Failure, CheckIn>> call(CheckOutUserParams params) async {
    return await repository.checkOutUser(
      userId: params.userId,
      checkInPointId: params.checkInPointId,
      checkOutLocation: params.checkOutLocation,
    );
  }
}

class CheckOutUserParams {
  final String userId;
  final String checkInPointId;
  final GeoLocation checkOutLocation;

  CheckOutUserParams({
    required this.userId,
    required this.checkInPointId,
    required this.checkOutLocation,
  });
}
