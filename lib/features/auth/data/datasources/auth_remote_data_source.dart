import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart' as domain;
import '../models/user_model.dart';

/// Firebase implementation for user authentication operations
/// 
/// This is where we actually talk to Firebase. All the auth magic happens here.
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required domain.UserType userType,
  });

  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Future<UserModel> getUserById(String userId);
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed - no user returned');
      }

      // Get user data from Firestore
      return await getUserById(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _handleAuthError(e));
    } catch (e) {
      throw AuthException(message: 'Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required domain.UserType userType,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign up failed - no user returned');
      }

      // Create user profile in Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        userType: userType,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _handleAuthError(e));
    } catch (e) {
      throw AuthException(message: 'Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException(message: 'No user is currently signed in');
      }

      return await getUserById(firebaseUser.uid);
    } catch (e) {
      throw AuthException(message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw const AuthException(message: 'User not found');
      }

      return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw AuthException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        return await getUserById(firebaseUser.uid);
      } catch (e) {
        // If we can't get user data, user is effectively not authenticated
        return null;
      }
    });
  }

  /// Convert Firebase auth errors to user-friendly messages
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
