/// Base failure class for error handling in clean architecture
/// 
/// All failures in the application should extend this abstract class
/// to ensure consistent error handling across different layers.
abstract class Failure {
  const Failure();
}

/// Represents failures that occur during server communication
class ServerFailure extends Failure {
  final String message;
  
  const ServerFailure({required this.message});
  
  @override
  String toString() => 'ServerFailure: $message';
}

/// Represents failures that occur during location operations
class LocationFailure extends Failure {
  final String message;
  
  const LocationFailure({required this.message});
  
  @override
  String toString() => 'LocationFailure: $message';
}

/// Represents failures that occur during authentication
class AuthFailure extends Failure {
  final String message;
  
  const AuthFailure({required this.message});
  
  @override
  String toString() => 'AuthFailure: $message';
}

/// Represents failures that occur due to invalid user permissions
class PermissionFailure extends Failure {
  final String message;
  
  const PermissionFailure({required this.message});
  
  @override
  String toString() => 'PermissionFailure: $message';
}

/// Represents failures that occur due to network connectivity issues
class NetworkFailure extends Failure {
  final String message;
  
  const NetworkFailure({required this.message});
  
  @override
  String toString() => 'NetworkFailure: $message';
}
