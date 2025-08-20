import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_point.dart';
import '../repositories/check_in_repository.dart';

/// Use case for getting the currently active check-in point
class GetActiveCheckInPoint implements UseCase<CheckInPoint?, NoParams> {
  final CheckInRepository repository;

  const GetActiveCheckInPoint(this.repository);

  @override
  Future<Either<Failure, CheckInPoint?>> call(NoParams params) async {
    return await repository.getActiveCheckInPoint();
  }
}
