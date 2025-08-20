import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/check_in_point.dart';
import '../models/check_in_point_model.dart';
import '../models/check_in_model.dart';

/// Firebase data source for check-in operations
/// 
/// This handles all the Firestore operations for check-ins and check-in points.
/// I'm keeping the business logic simple here - just CRUD operations.
abstract class CheckInRemoteDataSource {
  Future<CheckInPointModel> createCheckInPoint({
    required String title,
    required String description,
    required GeoLocation location,
    required double radiusInMeters,
    required String createdBy,
  });

  Future<CheckInPointModel?> getActiveCheckInPoint();
  Future<CheckInPointModel> getCheckInPointById(String id);
  Future<CheckInPointModel> updateCheckInPoint(CheckInPointModel checkInPoint);
  Future<void> deactivateCheckInPoint(String checkInPointId);

  Future<CheckInModel> checkInUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  Future<CheckInModel> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  });

  Future<CheckInModel?> getUserCurrentCheckIn(String userId);
  Future<List<CheckInModel>> getCheckInsForPoint(String checkInPointId);
  
  Stream<CheckInPointModel?> get activeCheckInPointStream;
  Stream<List<CheckInModel>> getActiveCheckInsStream(String checkInPointId);
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CheckInRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required Uuid uuid,
  })  : _firestore = firestore,
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
      throw ServerException(message: 'Failed to create check-in point: ${e.toString()}');
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
      throw ServerException(message: 'Failed to get active check-in point: ${e.toString()}');
    }
  }

  @override
  Future<CheckInPointModel> getCheckInPointById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.checkInPointsCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const ServerException(message: 'Check-in point not found');
      }

      return CheckInPointModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get check-in point: ${e.toString()}');
    }
  }

  @override
  Future<CheckInPointModel> updateCheckInPoint(CheckInPointModel checkInPoint) async {
    try {
      await _firestore
          .collection(AppConstants.checkInPointsCollection)
          .doc(checkInPoint.id)
          .update(checkInPoint.toFirestore());

      return checkInPoint;
    } catch (e) {
      throw ServerException(message: 'Failed to update check-in point: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateCheckInPoint(String checkInPointId) async {
    try {
      await _firestore
          .collection(AppConstants.checkInPointsCollection)
          .doc(checkInPointId)
          .update({
        'isActive': false,
        'checkedInUserIds': [], // Clear all checked-in users
      });
    } catch (e) {
      throw ServerException(message: 'Failed to deactivate check-in point: ${e.toString()}');
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
        _firestore.collection(AppConstants.checkInPointsCollection).doc(checkInPointId),
        {
          'checkedInUserIds': FieldValue.arrayUnion([userId]),
        },
      );

      await batch.commit();
      return checkIn;
    } catch (e) {
      throw ServerException(message: 'Failed to check in user: ${e.toString()}');
    }
  }

  @override
  Future<CheckInModel> checkOutUser({
    required String userId,
    required String checkInPointId,
    required GeoLocation userLocation,
  }) async {
    try {
      // Find the active check-in record
      final currentCheckIn = await getUserCurrentCheckIn(userId);
      if (currentCheckIn == null) {
        throw const ServerException(message: 'User is not currently checked in');
      }

      // Update check-in record with checkout info
      final updatedCheckIn = currentCheckIn.checkOut(
        checkOutTime: DateTime.now(),
        checkOutLocation: userLocation,
      );

      final batch = _firestore.batch();

      // Update check-in record
      batch.update(
        _firestore.collection(AppConstants.checkInsCollection).doc(currentCheckIn.id),
        CheckInModel.fromEntity(updatedCheckIn).toFirestore(),
      );

      // Remove user from check-in point
      batch.update(
        _firestore.collection(AppConstants.checkInPointsCollection).doc(checkInPointId),
        {
          'checkedInUserIds': FieldValue.arrayRemove([userId]),
        },
      );

      await batch.commit();
      return CheckInModel.fromEntity(updatedCheckIn);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to check out user: ${e.toString()}');
    }
  }

  @override
  Future<CheckInModel?> getUserCurrentCheckIn(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.checkInsCollection)
          .where('userId', isEqualTo: userId)
          .where('checkOutTime', isNull: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return CheckInModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      throw ServerException(message: 'Failed to get user check-in status: ${e.toString()}');
    }
  }

  @override
  Future<List<CheckInModel>> getCheckInsForPoint(String checkInPointId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.checkInsCollection)
          .where('checkInPointId', isEqualTo: checkInPointId)
          .where('checkOutTime', isNull: true) // Only active check-ins
          .get();

      return query.docs
          .map((doc) => CheckInModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get check-ins: ${e.toString()}');
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

  @override
  Stream<List<CheckInModel>> getActiveCheckInsStream(String checkInPointId) {
    return _firestore
        .collection(AppConstants.checkInsCollection)
        .where('checkInPointId', isEqualTo: checkInPointId)
        .where('checkOutTime', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckInModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
