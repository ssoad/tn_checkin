import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/check_in_point.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/usecases/create_check_in_point.dart';
import '../../domain/usecases/get_active_check_in_point.dart';
import '../../domain/usecases/check_in_user.dart';

class CheckInState extends Equatable {
  final bool isLoading;
  final CheckInPoint? activeCheckInPoint;
  final CheckIn? userCheckIn;
  final String? error;
  final bool isWithinRange;
  final GeoLocation? userLocation;

  const CheckInState({
    this.isLoading = false,
    this.activeCheckInPoint,
    this.userCheckIn,
    this.error,
    this.isWithinRange = false,
    this.userLocation,
  });

  CheckInState copyWith({
    bool? isLoading,
    CheckInPoint? activeCheckInPoint,
    CheckIn? userCheckIn,
    String? error,
    bool? isWithinRange,
    GeoLocation? userLocation,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      activeCheckInPoint: activeCheckInPoint ?? this.activeCheckInPoint,
      userCheckIn: userCheckIn ?? this.userCheckIn,
      error: error,
      isWithinRange: isWithinRange ?? this.isWithinRange,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        activeCheckInPoint,
        userCheckIn,
        error,
        isWithinRange,
        userLocation,
      ];
}

class CheckInNotifier extends StateNotifier<CheckInState> {
  final CreateCheckInPoint _createCheckInPoint;
  final GetActiveCheckInPoint _getActiveCheckInPoint;
  final CheckInUser _checkInUser;
  final LocationService _locationService;

  CheckInNotifier({
    required CreateCheckInPoint createCheckInPoint,
    required GetActiveCheckInPoint getActiveCheckInPoint,
    required CheckInUser checkInUser,
    required LocationService locationService,
  })  : _createCheckInPoint = createCheckInPoint,
        _getActiveCheckInPoint = getActiveCheckInPoint,
        _checkInUser = checkInUser,
        _locationService = locationService,
        super(const CheckInState());

  Future<void> loadActiveCheckInPoint() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getActiveCheckInPoint(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkInPoint) => state = state.copyWith(
        isLoading: false,
        error: null,
        activeCheckInPoint: checkInPoint,
      ),
    );
  }

  Future<void> updateUserLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      state = state.copyWith(userLocation: location);

      // Check if user is within range of active check-in point
      if (state.activeCheckInPoint != null) {
        final isInRange = _locationService.isWithinCheckInRadius(
          userLocation: location,
          checkInPointLocation: state.activeCheckInPoint!.location,
          radiusInMeters: state.activeCheckInPoint!.radiusInMeters,
        );
        state = state.copyWith(isWithinRange: isInRange);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createCheckInPoint({
    required String title,
    required String description,
    required String createdBy,
    required double radiusInMeters,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current location first
      final location = await _locationService.getCurrentLocation();

      final params = CreateCheckInPointParams(
        title: title,
        description: description,
        location: location,
        radiusInMeters: radiusInMeters,
        createdBy: createdBy,
      );

      final result = await _createCheckInPoint(params);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: _getFailureMessage(failure),
        ),
        (checkInPoint) => state = state.copyWith(
          isLoading: false,
          error: null,
          activeCheckInPoint: checkInPoint,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkInUser(String userId) async {
    if (state.activeCheckInPoint == null) {
      state = state.copyWith(error: 'No active check-in point available');
      return;
    }

    if (!state.isWithinRange) {
      state = state.copyWith(error: 'You must be within the check-in area');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final params = CheckInUserParams(
      userId: userId,
      checkInPointId: state.activeCheckInPoint!.id,
      userLocation: state.userLocation!,
    );

    final result = await _checkInUser(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkIn) => state = state.copyWith(
        isLoading: false,
        error: null,
        userCheckIn: checkIn,
      ),
    );
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is LocationFailure) return failure.message;
    if (failure is PermissionFailure) return failure.message;
    return 'An unexpected error occurred';
  }
}

final checkInProvider = StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  return CheckInNotifier(
    createCheckInPoint: ref.read(createCheckInPointProvider),
    getActiveCheckInPoint: ref.read(getActiveCheckInPointProvider),
    checkInUser: ref.read(checkInUserProvider),
    locationService: ref.read(locationServiceProvider),
  );
});

// Stream provider for active check-in point
final activeCheckInPointStreamProvider = StreamProvider<CheckInPoint?>((ref) {
  return ref.read(checkInRepositoryProvider).activeCheckInPointStream;
});
