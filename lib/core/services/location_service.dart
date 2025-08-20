import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../errors/exceptions.dart';
import '../../features/check_in/domain/entities/check_in_point.dart';

class LocationService {
  
  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Request location permission from user
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }

  /// Get current location of the user
  Future<GeoLocation> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException(
          message: 'Location services are disabled. Please enable them in settings.',
        );
      }

      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw const LocationException(
            message: 'Location permission denied. Please grant permission to use this feature.',
          );
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(message: 'Failed to get location: ${e.toString()}');
    }
  }

  /// Check if user location is within the check-in point radius
  bool isWithinCheckInRadius({
    required GeoLocation userLocation,
    required GeoLocation checkInPointLocation,
    required double radiusInMeters,
  }) {
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      checkInPointLocation.latitude,
      checkInPointLocation.longitude,
    );

    return distance <= radiusInMeters;
  }

  /// Calculate distance between two locations in meters
  double calculateDistance({
    required GeoLocation from,
    required GeoLocation to,
  }) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Get location stream for real-time tracking (if needed)
  Stream<GeoLocation> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) => GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
}
