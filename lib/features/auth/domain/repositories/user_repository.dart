import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for user-related operations
/// 
/// This abstract class defines the contract for user data operations
/// following the dependency inversion principle of clean architecture.
abstract class UserRepository {
  /// Signs in a user with email and password
  /// 
  /// Returns [User] on success or [AuthFailure] on failure
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up a new user with email, password, name, and user type
  /// 
  /// Returns [User] on success or [AuthFailure] on failure
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  });

  /// Signs out the current user
  /// 
  /// Returns [Unit] on success or [AuthFailure] on failure
  Future<Either<Failure, Unit>> signOut();

  /// Gets the currently authenticated user
  /// 
  /// Returns [User] if authenticated or [AuthFailure] if not
  Future<Either<Failure, User>> getCurrentUser();

  /// Updates user profile information
  /// 
  /// Returns updated [User] on success or [Failure] on error
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
  });

  /// Gets a user by their ID
  /// 
  /// Returns [User] on success or [Failure] on error
  Future<Either<Failure, User>> getUserById(String userId);

  /// Checks if a user is currently authenticated
  /// 
  /// Returns true if authenticated, false otherwise
  Future<bool> isUserAuthenticated();

  /// Stream of authentication state changes
  /// 
  /// Emits [User] when signed in, null when signed out
  Stream<User?> get authStateChanges;
}
