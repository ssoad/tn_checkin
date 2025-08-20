/// Custom exceptions for the TN Check-in application
/// 
/// These exceptions are thrown by data sources and converted to
/// Failures by repository implementations.

class ServerException implements Exception {
  final String message;
  
  const ServerException({required this.message});
  
  @override
  String toString() => 'ServerException: $message';
}

class LocationException implements Exception {
  final String message;
  
  const LocationException({required this.message});
  
  @override
  String toString() => 'LocationException: $message';
}

class AuthException implements Exception {
  final String message;
  
  const AuthException({required this.message});
  
  @override
  String toString() => 'AuthException: $message';
}

class PermissionException implements Exception {
  final String message;
  
  const PermissionException({required this.message});
  
  @override
  String toString() => 'PermissionException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({required this.message});
  
  @override
  String toString() => 'NetworkException: $message';
}
