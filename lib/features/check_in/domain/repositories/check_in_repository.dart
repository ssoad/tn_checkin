import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/check_in_point.dart';
import '../entities/check_in.dart';

/// Repository interface for check-in operations
///
/// Super simple: create a check-in point, get it, check users in, and stream updates.
abstract class CheckInRepository {
  /// Creates a new check-in point
  Future<Either<Failure, CheckInPoint>> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  });

  /// Gets the currently active check-in point
  Future<Either<Failure, CheckInPoint?>> getActiveCheckInPoint();

  /// Gets all active check-in points
  Future<Either<Failure, List<CheckInPoint>>> getAllActiveCheckInPoints();

  /// Checks a user into the active check-in point
  Future<Either<Failure, CheckIn>> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  /// Checks a user out of the active check-in point
  Future<Either<Failure, CheckIn>> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation checkOutLocation,
  });

  /// Stream of active check-in point changes
  Stream<CheckInPoint?> get activeCheckInPointStream;
}
