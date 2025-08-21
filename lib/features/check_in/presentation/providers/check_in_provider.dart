import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/check_in_point.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/usecases/create_check_in_point.dart';
import '../../domain/usecases/get_active_check_in_point.dart';
import '../../domain/usecases/get_all_active_check_in_points.dart';
import '../../domain/usecases/check_in_user.dart';
import '../../domain/usecases/check_out_user.dart';

class CheckInState extends Equatable {
  final bool isLoading;
  final CheckInPoint? activeCheckInPoint;
  final List<CheckInPoint> allActiveCheckInPoints;
  final CheckIn? userCheckIn;
  final String? error;
  final bool isWithinRange;
  final GeoLocation? userLocation;

  const CheckInState({
    this.isLoading = true, // Start with loading true to prevent flash of empty state
    this.activeCheckInPoint,
    this.allActiveCheckInPoints = const [],
    this.userCheckIn,
    this.error,
    this.isWithinRange = false,
    this.userLocation,
  });

  CheckInState copyWith({
    bool? isLoading,
    CheckInPoint? activeCheckInPoint,
    List<CheckInPoint>? allActiveCheckInPoints,
    CheckIn? userCheckIn,
    String? error,
    bool? isWithinRange,
    GeoLocation? userLocation,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      activeCheckInPoint: activeCheckInPoint ?? this.activeCheckInPoint,
      allActiveCheckInPoints: allActiveCheckInPoints ?? this.allActiveCheckInPoints,
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
    allActiveCheckInPoints,
    userCheckIn,
    error,
    isWithinRange,
    userLocation,
  ];
}

class CheckInNotifier extends StateNotifier<CheckInState> {
  final CreateCheckInPoint _createCheckInPoint;
  final GetActiveCheckInPoint _getActiveCheckInPoint;
  final GetAllActiveCheckInPoints _getAllActiveCheckInPoints;
  final CheckInUser _checkInUser;
  final CheckOutUser _checkOutUser;
  final LocationService _locationService;
  
  StreamSubscription<GeoLocation>? _locationSubscription;
  bool _isLocationMonitoringActive = false;

  CheckInNotifier({
    required CreateCheckInPoint createCheckInPoint,
    required GetActiveCheckInPoint getActiveCheckInPoint,
    required GetAllActiveCheckInPoints getAllActiveCheckInPoints,
    required CheckInUser checkInUser,
    required CheckOutUser checkOutUser,
    required LocationService locationService,
  }) : _createCheckInPoint = createCheckInPoint,
       _getActiveCheckInPoint = getActiveCheckInPoint,
       _getAllActiveCheckInPoints = getAllActiveCheckInPoints,
       _checkInUser = checkInUser,
       _checkOutUser = checkOutUser,
       _locationService = locationService,
       super(const CheckInState());

  @override
  void dispose() {
    _stopLocationMonitoring();
    super.dispose();
  }

  Future<void> loadActiveCheckInPoint() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getActiveCheckInPoint(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkInPoint) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          activeCheckInPoint: checkInPoint,
        );
        
        // Also load user's current check-in status if there's an active point
        if (checkInPoint != null) {
          await _loadUserCheckInStatus(checkInPoint.id);
        }
      },
    );
  }

  Future<void> _loadUserCheckInStatus(String checkInPointId) async {
    // This would need to be implemented with a new use case
    // For now, we'll check if the user is in the checked-in users list
    // This is a simplified approach - in a real app, you'd want a proper use case
    
    // If user has an active check-in, start location monitoring
    if (state.userCheckIn != null && state.userCheckIn!.isActive) {
      await startLocationMonitoring();
    }
  }

  Future<void> loadAllActiveCheckInPoints() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAllActiveCheckInPoints(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkInPoints) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          allActiveCheckInPoints: checkInPoints,
          // If there's at least one check-in point, set it as active
          activeCheckInPoint: checkInPoints.isNotEmpty ? checkInPoints.first : null,
        );
      },
    );
  }

  Future<void> updateUserLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      final wasInRange = state.isWithinRange;
      
      state = state.copyWith(userLocation: location);

      // Check if user is within range of active check-in point
      if (state.activeCheckInPoint != null) {
        final isInRange = _locationService.isWithinCheckInRadius(
          userLocation: location,
          checkInPointLocation: state.activeCheckInPoint!.location,
          radiusInMeters: state.activeCheckInPoint!.radiusInMeters,
        );
        state = state.copyWith(isWithinRange: isInRange);

        // Auto check-out if user was checked in but moved out of range
        if (wasInRange && 
            !isInRange && 
            state.userCheckIn != null && 
            state.userCheckIn!.isActive) {
          await _autoCheckOut();
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _autoCheckOut() async {
    if (state.activeCheckInPoint == null || 
        state.userCheckIn == null || 
        state.userLocation == null) {
      return;
    }

    // Get the current user ID from auth - this should be injected
    // For now, we'll use the userCheckIn's userId
    final userId = state.userCheckIn!.userId;

    final params = CheckOutUserParams(
      userId: userId,
      checkInPointId: state.activeCheckInPoint!.id,
      checkOutLocation: state.userLocation!,
    );

    final result = await _checkOutUser(params);

    result.fold(
      (failure) {
        // Don't show error for auto check-out, just log it
        state = state.copyWith(error: null);
      },
      (checkOut) {
        state = state.copyWith(
          userCheckIn: checkOut,
        );
        // Stop location monitoring after auto checkout
        _stopLocationMonitoring();
        // Refresh the check-in points to update user counts in real-time
        loadAllActiveCheckInPoints();
      },
    );
  }

  Future<void> checkOutUser(String userId) async {
    if (state.activeCheckInPoint == null) {
      state = state.copyWith(error: 'No active check-in point available');
      return;
    }

    if (state.userLocation == null) {
      state = state.copyWith(error: 'Location not available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final params = CheckOutUserParams(
      userId: userId,
      checkInPointId: state.activeCheckInPoint!.id,
      checkOutLocation: state.userLocation!,
    );

    final result = await _checkOutUser(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkOut) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          userCheckIn: checkOut,
        );
        // Stop location monitoring after checkout
        _stopLocationMonitoring();
        // Refresh the check-in points to update user counts in real-time
        loadAllActiveCheckInPoints();
      },
    );
  }

  Future<void> createCheckInPoint({
    required String title,
    String? description,
    required String createdBy,
    required double radiusInMeters,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current location first
      final location = await _locationService.getCurrentLocation();

      final params = CreateCheckInPointParams(
        title: title,
        description: description ?? '',
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCheckInPointWithLocation({
    required String title,
    String? description,
    required String createdBy,
    required double radiusInMeters,
    required GeoLocation location,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final params = CreateCheckInPointParams(
        title: title,
        description: description ?? '',
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
        (checkInPoint) {
          state = state.copyWith(
            isLoading: false,
            error: null,
            activeCheckInPoint: checkInPoint,
          );
          // Refresh the check-in points list to include the new location
          loadAllActiveCheckInPoints();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

    await checkInUserToPoint(userId, state.activeCheckInPoint!.id);
  }

  Future<void> checkInUserToPoint(String userId, String checkInPointId) async {
    if (state.userLocation == null) {
      state = state.copyWith(error: 'Location not available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final params = CheckInUserParams(
      userId: userId,
      checkInPointId: checkInPointId,
      userLocation: state.userLocation!,
    );

    final result = await _checkInUser(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (checkIn) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          userCheckIn: checkIn,
        );
        // Start location monitoring after successful check-in
        startLocationMonitoring();
        // Refresh the check-in points to update user counts in real-time
        loadAllActiveCheckInPoints();
      },
    );
  }

  /// Start real-time location monitoring for auto checkout
  Future<void> startLocationMonitoring() async {
    if (_isLocationMonitoringActive) return;

    try {
      // Check if we have location permission first
      if (!await _locationService.hasLocationPermission()) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) return;
      }

      _isLocationMonitoringActive = true;
      
      // Listen to location changes
      _locationSubscription = _locationService.locationStream.listen(
        (newLocation) async {
          await _onLocationChanged(newLocation);
        },
        onError: (error) {
          // Handle location stream errors gracefully
          _isLocationMonitoringActive = false;
        },
      );
    } catch (e) {
      _isLocationMonitoringActive = false;
    }
  }

  /// Stop location monitoring
  void _stopLocationMonitoring() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isLocationMonitoringActive = false;
  }

  /// Handle location changes and trigger auto checkout if needed
  Future<void> _onLocationChanged(GeoLocation newLocation) async {
    final wasInRange = state.isWithinRange;
    
    // Update state with new location
    state = state.copyWith(userLocation: newLocation);

    // Check if user is within range of active check-in point
    if (state.activeCheckInPoint != null) {
      final isInRange = _locationService.isWithinCheckInRadius(
        userLocation: newLocation,
        checkInPointLocation: state.activeCheckInPoint!.location,
        radiusInMeters: state.activeCheckInPoint!.radiusInMeters,
      );
      
      state = state.copyWith(isWithinRange: isInRange);

      // Auto check-out if user was checked in but moved out of range
      if (wasInRange && 
          !isInRange && 
          state.userCheckIn != null && 
          state.userCheckIn!.isActive) {
        await _autoCheckOut();
      }
    }
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

final checkInProvider = StateNotifierProvider<CheckInNotifier, CheckInState>((
  ref,
) {
  // These will be injected from the core providers
  throw UnimplementedError(
    'CheckIn provider should be overridden in main.dart',
  );
});

// Stream provider for active check-in point
final activeCheckInPointStreamProvider = StreamProvider<CheckInPoint?>((ref) {
  // This will be injected from the core providers
  throw UnimplementedError(
    'ActiveCheckInPointStream provider should be overridden in main.dart',
  );
});
