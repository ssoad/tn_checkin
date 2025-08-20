import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/check_in_point.dart';
import '../models/check_in_point_model.dart';
import '../models/check_in_model.dart';

/// Firebase data source for check-in operations
///
/// Simple and focused - just the operations we actually need.
abstract class CheckInRemoteDataSource {
  Future<CheckInPointModel> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  });

  Future<CheckInPointModel?> getActiveCheckInPoint();

  Future<CheckInModel> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  Future<CheckInModel> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation checkOutLocation,
  });

  Stream<CheckInPointModel?> get activeCheckInPointStream;
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CheckInRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required Uuid uuid,
  }) : _firestore = firestore,
       _uuid = uuid;

  @override
  Future<CheckInPointModel> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  }) async {
    try {
      // First, check if there's already an active check-in point
      final existingActive = await getActiveCheckInPoint();
      if (existingActive != null) {
        throw const ServerException(
          message: 'Only one check-in point can be active at a time',
        );
      }

      final checkInPoint = CheckInPointModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        location: location,
        radiusInMeters: radiusInMeters,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        isActive: true,
        checkedInUserIds: [],
      );

      await _firestore
          .collection(AppConstants.checkInPointsCollection)
          .doc(checkInPoint.id)
          .set(checkInPoint.toFirestore());

      return checkInPoint;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to create check-in point: ${e.toString()}',
      );
    }
  }

  @override
  Future<CheckInPointModel?> getActiveCheckInPoint() async {
    try {
      final query = await _firestore
          .collection(AppConstants.checkInPointsCollection)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return CheckInPointModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get active check-in point: ${e.toString()}',
      );
    }
  }

  @override
  Future<CheckInModel> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  }) async {
    try {
      // Create check-in record
      final checkIn = CheckInModel(
        id: _uuid.v4(),
        userId: userId,
        checkInPointId: checkInPointId,
        checkInLocation: userLocation,
        checkInTime: DateTime.now(),
      );

      // Use a batch to ensure atomicity
      final batch = _firestore.batch();

      // Add check-in record
      batch.set(
        _firestore.collection(AppConstants.checkInsCollection).doc(checkIn.id),
        checkIn.toFirestore(),
      );

      // Update check-in point with new user
      batch.update(
        _firestore
            .collection(AppConstants.checkInPointsCollection)
            .doc(checkInPointId),
        {
          'checkedInUserIds': FieldValue.arrayUnion([userId]),
        },
      );

      await batch.commit();
      return checkIn;
    } catch (e) {
      throw ServerException(
        message: 'Failed to check in user: ${e.toString()}',
      );
    }
  }

  @override
  Future<CheckInModel> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation checkOutLocation,
  }) async {
    try {
      // Find the user's active check-in record
      // Since checkOutTime field might not exist for active check-ins,
      // we'll query all check-ins and filter in code
      final checkInQuery = await _firestore
          .collection(AppConstants.checkInsCollection)
          .where('userId', isEqualTo: userId)
          .where('checkInPointId', isEqualTo: checkInPointId)
          .get();

      // Filter for records without checkOutTime (either null or field doesn't exist)
      final activeCheckIns = checkInQuery.docs.where((doc) {
        final data = doc.data();
        return data['checkOutTime'] == null;
      }).toList();

      if (activeCheckIns.isEmpty) {
        throw ServerException(
          message: 'No active check-in found for user $userId at point $checkInPointId',
        );
      }

      final checkInDoc = activeCheckIns.first;
      final checkIn = CheckInModel.fromFirestore(checkInDoc.data(), checkInDoc.id);

      // Create updated check-in with check-out data
      final updatedCheckIn = CheckInModel.fromEntity(checkIn.copyWith(
        checkOutTime: DateTime.now(),
        checkOutLocation: checkOutLocation,
      ));

      // Use a batch to ensure atomicity
      final batch = _firestore.batch();

      // Update check-in record with check-out data
      batch.update(
        _firestore.collection(AppConstants.checkInsCollection).doc(checkIn.id),
        {
          'checkOutTime': updatedCheckIn.checkOutTime!.millisecondsSinceEpoch,
          'checkOutLatitude': checkOutLocation.latitude,
          'checkOutLongitude': checkOutLocation.longitude,
        },
      );

      // Remove user from check-in point's checked-in users list
      batch.update(
        _firestore
            .collection(AppConstants.checkInPointsCollection)
            .doc(checkInPointId),
        {
          'checkedInUserIds': FieldValue.arrayRemove([userId]),
        },
      );

      await batch.commit();
      return updatedCheckIn;
    } catch (e) {
      throw ServerException(
        message: 'Failed to check out user: ${e.toString()}',
      );
    }
  }

  @override
  Stream<CheckInPointModel?> get activeCheckInPointStream {
    return _firestore
        .collection(AppConstants.checkInPointsCollection)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          final doc = snapshot.docs.first;
          return CheckInPointModel.fromFirestore(doc.data(), doc.id);
        });
  }
}
