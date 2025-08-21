import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'location_service.dart';
import '../providers/providers.dart';
import '../../features/check_in/domain/entities/check_in_point.dart';

class GlobalLocationState extends Equatable {
  final GeoLocation? currentLocation;
  final bool isLocationEnabled;
  final bool hasPermission;
  final String? error;
  final bool isLoading;

  const GlobalLocationState({
    this.currentLocation,
    this.isLocationEnabled = false,
    this.hasPermission = false,
    this.error,
    this.isLoading = true,
  });

  GlobalLocationState copyWith({
    GeoLocation? currentLocation,
    bool? isLocationEnabled,
    bool? hasPermission,
    String? error,
    bool? isLoading,
  }) {
    return GlobalLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        currentLocation,
        isLocationEnabled,
        hasPermission,
        error,
        isLoading,
      ];
}

class GlobalLocationNotifier extends StateNotifier<GlobalLocationState> {
  final LocationService _locationService;
  StreamSubscription<GeoLocation>? _locationSubscription;
  Timer? _retryTimer;

  GlobalLocationNotifier(this._locationService) : super(const GlobalLocationState()) {
    _initializeLocationService();
  }

  Future<void> _initializeLocationService() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check permissions
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) {
          state = state.copyWith(
            isLoading: false,
            hasPermission: false,
            error: 'Location permission denied',
          );
          return;
        }
      }

      // Get initial location
      final location = await _locationService.getCurrentLocation();
      state = state.copyWith(
        currentLocation: location,
        hasPermission: true,
        isLocationEnabled: true,
        isLoading: false,
        error: null,
      );

      // Start continuous location monitoring
      _startLocationMonitoring();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      // Retry after 10 seconds
      _scheduleRetry();
    }
  }

  void _startLocationMonitoring() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.locationStream.listen(
      (location) {
        state = state.copyWith(
          currentLocation: location,
          isLocationEnabled: true,
          hasPermission: true,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
        _scheduleRetry();
      },
    );
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _initializeLocationService();
      }
    });
  }

  Future<void> refreshLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      state = state.copyWith(
        currentLocation: location,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Helper method to check if user is within range of a specific location
  bool isWithinRangeOf({
    required GeoLocation checkInPointLocation,
    required double radiusInMeters,
  }) {
    if (state.currentLocation == null) return false;
    
    return _locationService.isWithinCheckInRadius(
      userLocation: state.currentLocation!,
      checkInPointLocation: checkInPointLocation,
      radiusInMeters: radiusInMeters,
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}

// Provider for the global location service
final globalLocationProvider = StateNotifierProvider<GlobalLocationNotifier, GlobalLocationState>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return GlobalLocationNotifier(locationService);
});
