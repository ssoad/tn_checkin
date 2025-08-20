import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/check_in_point.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../datasources/check_in_remote_data_source.dart';

/// Implementation of CheckInRepository using Firebase
///
/// Simple and focused: just the essential operations we actually need.
class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;

  CheckInRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckInPoint>> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  }) async {
    try {
      final checkInPointModel = await remoteDataSource.createCheckInPoint(
        title: title,
        description: description,
        location: location,
        radiusInMeters: radiusInMeters,
        createdBy: createdBy,
      );
      return Right(checkInPointModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to create check-in point: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CheckInPoint?>> getActiveCheckInPoint() async {
    try {
      final checkInPointModel = await remoteDataSource.getActiveCheckInPoint();
      return Right(checkInPointModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get active check-in point: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CheckIn>> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  }) async {
    try {
      final checkInModel = await remoteDataSource.checkInUser(
        userId: userId,
        checkInPointId: checkInPointId,
        userLocation: userLocation,
      );
      return Right(checkInModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on LocationException catch (e) {
      return Left(LocationFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to check in user: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<CheckInPoint?> get activeCheckInPointStream {
    return remoteDataSource.activeCheckInPointStream;
  }
}
