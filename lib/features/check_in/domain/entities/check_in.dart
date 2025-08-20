import 'package:equatable/equatable.dart';

import 'check_in_point.dart';

/// Represents a user's check-in record
/// 
/// This entity tracks when and where a user checks in and out
class CheckIn extends Equatable {
  /// Unique identifier for this check-in record
  final String id;
  
  /// ID of the user who checked in
  final String userId;
  
  /// ID of the check-in point
  final String checkInPointId;
  
  /// User's location when they checked in
  final GeoLocation checkInLocation;
  
  /// Timestamp when the user checked in
  final DateTime checkInTime;
  
  /// Timestamp when the user checked out (null if still checked in)
  final DateTime? checkOutTime;
  
  /// User's location when they checked out
  final GeoLocation? checkOutLocation;

  const CheckIn({
    required this.id,
    required this.userId,
    required this.checkInPointId,
    required this.checkInLocation,
    required this.checkInTime,
    this.checkOutTime,
    this.checkOutLocation,
  });

  /// Creates a copy of this check-in with the specified fields replaced
  CheckIn copyWith({
    String? id,
    String? userId,
    String? checkInPointId,
    GeoLocation? checkInLocation,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    GeoLocation? checkOutLocation,
  }) {
    return CheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInPointId: checkInPointId ?? this.checkInPointId,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
    );
  }

  /// Checks if the user is currently checked in (no check-out time)
  bool get isActive => checkOutTime == null;

  /// Gets the duration of the check-in session
  Duration get duration {
    final endTime = checkOutTime ?? DateTime.now();
    return endTime.difference(checkInTime);
  }

  /// Creates a check-out record
  CheckIn checkOut({
    required DateTime checkOutTime,
    required GeoLocation checkOutLocation,
  }) {
    if (this.checkOutTime != null) {
      throw StateError('User is already checked out');
    }
    
    return copyWith(
      checkOutTime: checkOutTime,
      checkOutLocation: checkOutLocation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        checkInPointId,
        checkInLocation,
        checkInTime,
        checkOutTime,
        checkOutLocation,
      ];

  @override
  String toString() {
    return 'CheckIn(id: $id, userId: $userId, checkInPointId: $checkInPointId, '
        'checkInTime: $checkInTime, checkOutTime: $checkOutTime, '
        'isActive: $isActive)';
  }
}
