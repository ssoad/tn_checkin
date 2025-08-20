import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/check_in/presentation/providers/check_in_provider.dart';

/// Contains all provider overrides for dependency injection
/// Following clean architecture principles by keeping presentation
/// providers separate from core providers
List<Override> get providerOverrides => [
  // Auth feature overrides
  authProvider.overrideWith((ref) {
    return AuthNotifier(
      getCurrentUser: ref.read(getCurrentUserProvider),
      signOut: ref.read(signOutProvider),
      signInWithEmailAndPassword: ref.read(signInWithEmailAndPasswordProvider),
      signUpWithEmailAndPassword: ref.read(signUpWithEmailAndPasswordProvider),
    );
  }),

  // Check-in feature overrides
  checkInProvider.overrideWith((ref) {
    return CheckInNotifier(
      createCheckInPoint: ref.read(createCheckInPointProvider),
      getActiveCheckInPoint: ref.read(getActiveCheckInPointProvider),
      checkInUser: ref.read(checkInUserProvider),
      locationService: ref.read(locationServiceProvider),
    );
  }),

  // Stream providers
  activeCheckInPointStreamProvider.overrideWith((ref) {
    return ref.read(checkInRepositoryProvider).activeCheckInPointStream;
  }),
];
