import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../services/location_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/auth/domain/repositories/user_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/check_in/data/datasources/check_in_remote_data_source.dart';
import '../../features/check_in/data/repositories/check_in_repository_impl.dart';
import '../../features/check_in/domain/repositories/check_in_repository.dart';
import '../../features/check_in/domain/usecases/check_in_user.dart';
import '../../features/check_in/domain/usecases/create_check_in_point.dart';
import '../../features/check_in/domain/usecases/get_active_check_in_point.dart';

// External dependencies
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firebaseFirestoreProvider),
  );
});

final checkInRemoteDataSourceProvider = Provider<CheckInRemoteDataSource>((ref) {
  return CheckInRemoteDataSourceImpl(
    firestore: ref.read(firebaseFirestoreProvider),
    uuid: ref.read(uuidProvider),
  );
});

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepositoryImpl(
    remoteDataSource: ref.read(checkInRemoteDataSourceProvider),
  );
});

// Use cases - Auth
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(userRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(userRepositoryProvider));
});

// Use cases - Check-in
final createCheckInPointProvider = Provider<CreateCheckInPoint>((ref) {
  return CreateCheckInPoint(ref.read(checkInRepositoryProvider));
});

final getActiveCheckInPointProvider = Provider<GetActiveCheckInPoint>((ref) {
  return GetActiveCheckInPoint(ref.read(checkInRepositoryProvider));
});

final checkInUserProvider = Provider<CheckInUser>((ref) {
  return CheckInUser(ref.read(checkInRepositoryProvider));
});
