import '../../domain/entities/user.dart';

/// Data model for User that handles Firebase serialization
/// 
/// I'm keeping this separate from the domain entity because Firebase
/// has its own quirks (like requiring Map<String, dynamic>) and I don't
/// want those concerns bleeding into my business logic.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a UserModel from a domain User entity
  /// Useful when we need to save domain data to Firebase
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      userType: user.userType,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Creates UserModel from Firebase document
  /// This is where the Firebase magic happens - converting their data to ours
  factory UserModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId, // Firebase doc ID becomes our user ID
      name: json['name'] as String? ?? 'Unknown User', // Defensive programming
      email: json['email'] as String? ?? '',
      userType: _parseUserType(json['userType'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Converts UserModel to Firebase-friendly format
  /// Firebase likes simple key-value pairs, so we'll give them what they want
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'userType': userType.name, // Enum to string for Firebase
      'createdAt': createdAt.millisecondsSinceEpoch, // Timestamp as int
      'updatedAt': DateTime.now().millisecondsSinceEpoch, // Always update this
    };
  }

  /// Helper to safely parse UserType from string
  /// Firebase might return weird data, so let's be defensive
  static UserType _parseUserType(String? typeString) {
    if (typeString == null) return UserType.participant; // Safe default
    
    try {
      return UserType.values.firstWhere(
        (type) => type.name == typeString,
        orElse: () => UserType.participant, // Better safe than sorry
      );
    } catch (e) {
      // If something goes wrong, default to participant
      return UserType.participant;
    }
  }

  /// Helper to safely parse DateTime from various formats
  /// Firebase can return timestamps in different ways, so we handle them all
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    try {
      if (dateTime is int) {
        // Timestamp as milliseconds
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      } else if (dateTime is String) {
        // ISO string format
        return DateTime.parse(dateTime);
      } else {
        // Firestore Timestamp object has a toDate() method
        return (dateTime as dynamic).toDate() as DateTime;
      }
    } catch (e) {
      // When in doubt, use current time
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, type: ${userType.name})';
  }
}
