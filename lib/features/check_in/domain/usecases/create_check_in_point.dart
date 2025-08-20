import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_point.dart';
import '../repositories/check_in_repository.dart';

/// Use case for creating a new check-in point
class CreateCheckInPoint implements UseCase<CheckInPoint, CreateCheckInPointParams> {
  final CheckInRepository repository;

  const CreateCheckInPoint(this.repository);

  @override
  Future<Either<Failure, CheckInPoint>> call(CreateCheckInPointParams params) async {
    return await repository.createCheckInPoint(
      title: params.title,
      description: params.description,
      location: params.location,
      radiusInMeters: params.radiusInMeters,
      createdBy: params.createdBy,
    );
  }
}

/// Parameters required for creating a check-in point
class CreateCheckInPointParams extends Equatable {
  final String title;
  final String description;
  final GeoLocation location;
  final double radiusInMeters;
  final String createdBy;

  const CreateCheckInPointParams({
    required this.title,
    required this.description,
    required this.location,
    required this.radiusInMeters,
    required this.createdBy,
  });

  @override
  List<Object> get props => [title, description, location, radiusInMeters, createdBy];
}
