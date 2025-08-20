import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/check_in_point.dart';
import '../entities/check_in.dart';

/// Repository interface for check-in related operations
/// 
/// This abstract class defines the contract for check-in data operations
/// following the dependency inversion principle of clean architecture.
abstract class CheckInRepository {
  /// Creates a new check-in point
  /// 
  /// Returns [CheckInPoint] on success or [Failure] on error
  Future<Either<Failure, CheckInPoint>> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  });

  /// Gets the currently active check-in point
  /// 
  /// Returns [CheckInPoint] if there's an active one, or [Failure] if none or error
  Future<Either<Failure, CheckInPoint?>> getActiveCheckInPoint();

  /// Gets a check-in point by its ID
  /// 
  /// Returns [CheckInPoint] on success or [Failure] on error
  Future<Either<Failure, CheckInPoint>> getCheckInPointById(String id);

  /// Updates a check-in point
  /// 
  /// Returns updated [CheckInPoint] on success or [Failure] on error
  Future<Either<Failure, CheckInPoint>> updateCheckInPoint(CheckInPoint checkInPoint);

  /// Deactivates a check-in point
  /// 
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> deactivateCheckInPoint(String checkInPointId);

  /// Checks a user into a check-in point
  /// 
  /// Returns [CheckIn] record on success or [Failure] on error
  Future<Either<Failure, CheckIn>> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  /// Checks a user out of a check-in point
  /// 
  /// Returns updated [CheckIn] record on success or [Failure] on error
  Future<Either<Failure, CheckIn>> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  /// Gets the current check-in status for a user
  /// 
  /// Returns [CheckIn] if user is checked in, null if not, or [Failure] on error
  Future<Either<Failure, CheckIn?>> getUserCurrentCheckIn(String userId);

  /// Gets all check-ins for a specific check-in point
  /// 
  /// Returns list of [CheckIn] records or [Failure] on error
  Future<Either<Failure, List<CheckIn>>> getCheckInsForPoint(String checkInPointId);

  /// Gets check-in history for a user
  /// 
  /// Returns list of [CheckIn] records or [Failure] on error
  Future<Either<Failure, List<CheckIn>>> getUserCheckInHistory(String userId);

  /// Stream of active check-in point changes
  /// 
  /// Emits [CheckInPoint] when there's an active point, null when none
  Stream<CheckInPoint?> get activeCheckInPointStream;

  /// Stream of check-ins for the active check-in point
  /// 
  /// Emits list of currently checked-in users
  Stream<List<CheckIn>> get activeCheckInsStream;
}
