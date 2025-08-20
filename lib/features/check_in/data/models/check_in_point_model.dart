import '../../domain/entities/check_in_point.dart';

/// Firebase data model for CheckInPoint
/// 
/// This handles the messy business of converting between our nice clean domain
/// objects and Firebase's document structure. Not glamorous work, but necessary!
class CheckInPointModel extends CheckInPoint {
  const CheckInPointModel({
    required super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.radiusInMeters,
    required super.createdBy,
    required super.createdAt,
    required super.isActive,
    required super.checkedInUserIds,
  });

  /// Convert from domain entity to data model
  factory CheckInPointModel.fromEntity(CheckInPoint checkInPoint) {
    return CheckInPointModel(
      id: checkInPoint.id,
      title: checkInPoint.title,
      description: checkInPoint.description,
      location: checkInPoint.location,
      radiusInMeters: checkInPoint.radiusInMeters,
      createdBy: checkInPoint.createdBy,
      createdAt: checkInPoint.createdAt,
      isActive: checkInPoint.isActive,
      checkedInUserIds: checkInPoint.checkedInUserIds,
    );
  }

  /// Create from Firebase document
  /// Firebase stores everything as basic types, so we need to reconstruct our objects
  factory CheckInPointModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return CheckInPointModel(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Check-in Point',
      description: json['description'] as String? ?? '',
      location: GeoLocation(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      radiusInMeters: (json['radiusInMeters'] as num?)?.toDouble() ?? 50.0,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
      checkedInUserIds: _parseUserIdsList(json['checkedInUserIds']),
    );
  }

  /// Convert to Firebase document format
  /// Keep it simple - Firebase likes basic types
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radiusInMeters': radiusInMeters,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'checkedInUserIds': checkedInUserIds, // Firebase handles lists well
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      // Adding some metadata that might be useful later
      'checkedInCount': checkedInUserIds.length,
    };
  }

  /// Safely parse user IDs list from Firebase
  /// Firebase might return this in different formats depending on the client
  static List<String> _parseUserIdsList(dynamic userIds) {
    if (userIds == null) return [];
    
    if (userIds is List) {
      // Convert each item to string, filter out nulls
      return userIds
          .where((id) => id != null)
          .map((id) => id.toString())
          .toList();
    }
    
    return []; // Safe fallback
  }

  /// Parse DateTime from various Firebase formats
  /// Firebase is... creative... with how it stores dates
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    try {
      if (dateTime is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } else if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else {
        // Firestore Timestamp
        return (dateTime as dynamic).toDate() as DateTime;
      }
    } catch (e) {
      // When Firebase throws us a curveball, just use now
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'CheckInPointModel(id: $id, title: $title, active: $isActive, users: ${checkedInUserIds.length})';
  }
}
