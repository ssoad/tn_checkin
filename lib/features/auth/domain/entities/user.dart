import 'package:equatable/equatable.dart';

/// Represents a user in the TN Check-in system
/// 
/// This entity encapsulates all user-related data and business logic
/// following clean architecture principles.
class User extends Equatable {
  /// Unique identifier for the user
  final String id;
  
  /// Display name of the user
  final String name;
  
  /// Email address of the user
  final String email;
  
  /// Type of user (creator or participant)
  final UserType userType;
  
  /// Timestamp when the user was created
  final DateTime createdAt;
  
  /// Timestamp when the user was last updated
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this user with the specified fields replaced
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Checks if this user can create check-in points
  bool get canCreateCheckInPoints => userType == UserType.creator;
  
  /// Checks if this user can participate in check-ins
  bool get canParticipateInCheckIns => true; // All users can participate

  @override
  List<Object?> get props => [id, name, email, userType, createdAt, updatedAt];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, userType: $userType)';
  }
}

/// Enum representing different types of users in the system
enum UserType {
  /// Users who can create and manage check-in points
  creator,
  
  /// Users who can only participate in check-ins
  participant;
  
  /// Returns a human-readable string representation
  String get displayName {
    switch (this) {
      case UserType.creator:
        return 'Creator';
      case UserType.participant:
        return 'Participant';
    }
  }
}
