/// Core constants for the TN Check-in application
/// 
/// This file contains application-wide constants including:
/// - Firebase collections
/// - Default values
/// - Configuration constants
class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String checkInPointsCollection = 'check_in_points';
  static const String checkInsCollection = 'check_ins';
  
  // Default values
  static const double defaultRadius = 50.0; // meters
  static const double minRadius = 10.0; // meters (minimum for accuracy)
  
  // Location update intervals
  static const int locationUpdateIntervalSeconds = 5;
  static const int autoCheckOutDelaySeconds = 30;
  
  // User types
  static const String userTypeCreator = 'creator';
  static const String userTypeParticipant = 'participant';
}
