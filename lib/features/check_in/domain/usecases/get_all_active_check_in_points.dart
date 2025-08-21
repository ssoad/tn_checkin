import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_point.dart';
import '../repositories/check_in_repository.dart';

/// Use case for getting all active check-in points
class GetAllActiveCheckInPoints implements UseCase<List<CheckInPoint>, NoParams> {
  final CheckInRepository repository;

  const GetAllActiveCheckInPoints(this.repository);

  @override
  Future<Either<Failure, List<CheckInPoint>>> call(NoParams params) async {
    return await repository.getAllActiveCheckInPoints();
  }
}
