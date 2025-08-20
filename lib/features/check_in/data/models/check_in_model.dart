import '../../domain/entities/check_in.dart';
import '../../domain/entities/check_in_point.dart';

/// Firebase data model for CheckIn records
/// 
/// This tracks individual check-in/check-out events. I'm storing these separately
/// from the CheckInPoint because it makes querying user history much easier.
class CheckInModel extends CheckIn {
  const CheckInModel({
    required super.id,
    required super.userId,
    required super.checkInPointId,
    required super.checkInLocation,
    required super.checkInTime,
    super.checkOutTime,
    super.checkOutLocation,
  });

  /// Convert from domain entity
  factory CheckInModel.fromEntity(CheckIn checkIn) {
    return CheckInModel(
      id: checkIn.id,
      userId: checkIn.userId,
      checkInPointId: checkIn.checkInPointId,
      checkInLocation: checkIn.checkInLocation,
      checkInTime: checkIn.checkInTime,
      checkOutTime: checkIn.checkOutTime,
      checkOutLocation: checkIn.checkOutLocation,
    );
  }

  /// Create from Firebase document
  factory CheckInModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return CheckInModel(
      id: documentId,
      userId: json['userId'] as String? ?? '',
      checkInPointId: json['checkInPointId'] as String? ?? '',
      checkInLocation: GeoLocation(
        latitude: (json['checkInLatitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['checkInLongitude'] as num?)?.toDouble() ?? 0.0,
      ),
      checkInTime: _parseDateTime(json['checkInTime']),
      checkOutTime: json['checkOutTime'] != null 
          ? _parseDateTime(json['checkOutTime']) 
          : null,
      checkOutLocation: json['checkOutLatitude'] != null && json['checkOutLongitude'] != null
          ? GeoLocation(
              latitude: (json['checkOutLatitude'] as num).toDouble(),
              longitude: (json['checkOutLongitude'] as num).toDouble(),
            )
          : null,
    );
  }

  /// Convert to Firebase format
  /// I'm flattening the GeoLocation objects because Firebase doesn't handle nested objects gracefully
  Map<String, dynamic> toFirestore() {
    final data = {
      'userId': userId,
      'checkInPointId': checkInPointId,
      'checkInLatitude': checkInLocation.latitude,
      'checkInLongitude': checkInLocation.longitude,
      'checkInTime': checkInTime.millisecondsSinceEpoch,
      'isActive': isActive, // Helpful for quick queries
    };

    // Only add checkout data if user has checked out
    if (checkOutTime != null) {
      data['checkOutTime'] = checkOutTime!.millisecondsSinceEpoch;
    }
    
    if (checkOutLocation != null) {
      data['checkOutLatitude'] = checkOutLocation!.latitude;
      data['checkOutLongitude'] = checkOutLocation!.longitude;
    }

    return data;
  }

  /// Parse DateTime from Firebase (same logic as other models)
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    try {
      if (dateTime is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } else if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else {
        return (dateTime as dynamic).toDate() as DateTime;
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'CheckInModel(id: $id, userId: $userId, active: $isActive, duration: ${duration.inMinutes}min)';
  }
}
