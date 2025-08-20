import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// Represents a geographical location with latitude and longitude
class GeoLocation extends Equatable {
  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  /// Creates a GeoLocation from a Geolocator Position
  factory GeoLocation.fromPosition(Position position) {
    return GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Calculates the distance in meters to another location
  double distanceTo(GeoLocation other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Checks if this location is within the specified radius of another location
  bool isWithinRadius(GeoLocation center, double radiusInMeters) {
    return distanceTo(center) <= radiusInMeters;
  }

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoLocation(lat: $latitude, lng: $longitude)';
}

/// Represents a check-in point in the system
/// 
/// This entity encapsulates all check-in point related data and business logic
/// following clean architecture principles.
class CheckInPoint extends Equatable {
  /// Unique identifier for the check-in point
  final String id;
  
  /// Title/name of the check-in point
  final String title;
  
  /// Optional description providing more details
  final String description;
  
  /// Geographic location of the check-in point
  final GeoLocation location;
  
  /// Radius in meters within which users can check in
  final double radiusInMeters;
  
  /// ID of the user who created this check-in point
  final String createdBy;
  
  /// Timestamp when the check-in point was created
  final DateTime createdAt;
  
  /// Whether the check-in point is currently active
  final bool isActive;
  
  /// List of user IDs who are currently checked in
  final List<String> checkedInUserIds;

  const CheckInPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.radiusInMeters,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
    required this.checkedInUserIds,
  });

  /// Creates a copy of this check-in point with the specified fields replaced
  CheckInPoint copyWith({
    String? id,
    String? title,
    String? description,
    GeoLocation? location,
    double? radiusInMeters,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
    List<String>? checkedInUserIds,
  }) {
    return CheckInPoint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      checkedInUserIds: checkedInUserIds ?? this.checkedInUserIds,
    );
  }

  /// Checks if a user is currently checked in
  bool isUserCheckedIn(String userId) {
    return checkedInUserIds.contains(userId);
  }

  /// Gets the number of users currently checked in
  int get checkedInCount => checkedInUserIds.length;

  /// Checks if a location is within the check-in radius
  bool isLocationWithinRadius(GeoLocation userLocation) {
    return userLocation.isWithinRadius(location, radiusInMeters);
  }

  /// Adds a user to the checked-in list
  CheckInPoint addCheckedInUser(String userId) {
    if (checkedInUserIds.contains(userId)) return this;
    
    final updatedList = List<String>.from(checkedInUserIds)..add(userId);
    return copyWith(checkedInUserIds: updatedList);
  }

  /// Removes a user from the checked-in list
  CheckInPoint removeCheckedInUser(String userId) {
    final updatedList = List<String>.from(checkedInUserIds)..remove(userId);
    return copyWith(checkedInUserIds: updatedList);
  }

  /// Deactivates the check-in point
  CheckInPoint deactivate() {
    return copyWith(
      isActive: false,
      checkedInUserIds: [], // Clear all checked-in users when deactivating
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        radiusInMeters,
        createdBy,
        createdAt,
        isActive,
        checkedInUserIds,
      ];

  @override
  String toString() {
    return 'CheckInPoint(id: $id, title: $title, location: $location, '
        'radius: ${radiusInMeters}m, active: $isActive, '
        'checkedIn: ${checkedInUserIds.length})';
  }
}
