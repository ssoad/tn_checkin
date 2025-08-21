import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/check_in_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/check_in_point.dart';
import '../../../../core/services/global_location_service.dart';
import '../../../../core/common/widgets/widgets.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final CheckInPoint? checkInPoint;
  
  const CheckInScreen({
    super.key,
    this.checkInPoint,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger location refresh for global location service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalLocationProvider.notifier).refreshLocation();
    });
  }

  // Helper method to check if user is within range of a specific check-in point
  bool _isWithinRangeOfPoint(CheckInPoint checkInPoint, CheckInState checkInState) {
    final globalLocationState = ref.read(globalLocationProvider);
    if (globalLocationState.currentLocation == null) {
      // If location is not available, we can't determine range
      return false;
    }
    
    return ref.read(globalLocationProvider.notifier).isWithinRangeOf(
      checkInPointLocation: checkInPoint.location,
      radiusInMeters: checkInPoint.radiusInMeters,
    );
  }

  // Helper method to determine if location is available
  bool _isLocationAvailable(CheckInState checkInState) {
    final globalLocationState = ref.read(globalLocationProvider);
    return globalLocationState.currentLocation != null && globalLocationState.hasPermission;
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);
    final activeCheckInPointAsync = ref.watch(activeCheckInPointStreamProvider);
    final theme = Theme.of(context);
    
    // Use the passed checkInPoint if provided, otherwise use the stream
    if (widget.checkInPoint != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Check In',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: _buildCheckInBody(context, widget.checkInPoint!, checkInState, theme),
      );
    }

    return activeCheckInPointAsync.when(
      data: (checkInPoint) {
        if (checkInPoint == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Check In',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active check-in point found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Check In',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          body: _buildCheckInBody(context, checkInPoint, checkInState, theme),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Check In',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading check-in point...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Check In',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading check-in point: ${error.toString()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInBody(
    BuildContext context,
    dynamic checkInPoint,
    CheckInState checkInState,
    ThemeData theme,
  ) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;
    final isUserCheckedIn = currentUserId != null && 
        checkInPoint.checkedInUserIds.contains(currentUserId);
    
    // Calculate range specifically for this check-in point
    final isWithinRange = _isWithinRangeOfPoint(checkInPoint, checkInState);
    final isLocationAvailable = _isLocationAvailable(checkInState);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Check-in point info with real-time count
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          checkInPoint.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_rounded,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${checkInPoint.checkedInCount}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Check-in radius: ${checkInPoint.radiusInMeters.toInt()} meters',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Real-time checked-in users count
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${checkInPoint.checkedInCount} ${checkInPoint.checkedInCount == 1 ? 'person' : 'people'} checked in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Location status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: !isLocationAvailable
                    ? Colors.grey.shade50
                    : isWithinRange
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !isLocationAvailable
                      ? Colors.grey.shade200
                      : isWithinRange
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (!isLocationAvailable
                                ? Colors.grey
                                : isWithinRange
                                    ? Colors.green
                                    : Colors.orange)
                            .withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          (!isLocationAvailable
                                  ? Colors.grey
                                  : isWithinRange
                                      ? Colors.green
                                      : Colors.orange)
                              .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      !isLocationAvailable
                          ? Icons.location_disabled_rounded
                          : isWithinRange
                              ? Icons.check_circle_rounded
                              : Icons.location_searching_rounded,
                      size: 48,
                      color: !isLocationAvailable
                          ? Colors.grey.shade600
                          : isWithinRange
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    !isLocationAvailable
                        ? 'Location unavailable'
                        : isWithinRange
                            ? 'You\'re in range!'
                            : 'Move closer to check in',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: !isLocationAvailable
                          ? Colors.grey.shade700
                          : isWithinRange
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    !isLocationAvailable
                        ? 'Tap "Refresh Location" to update your position'
                        : isWithinRange
                            ? 'You can now check in to this location'
                            : 'You need to be within ${checkInPoint.radiusInMeters.toInt()}m to check in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: !isLocationAvailable
                          ? Colors.grey.shade600
                          : isWithinRange
                              ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Refresh location button
            CommonButton.outlined(
              text: 'Refresh Location',
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              onPressed: checkInState.isLoading
                  ? null
                  : () =>
                        ref.read(checkInProvider.notifier).updateUserLocation(),
              fullWidth: true,
            ),

            const SizedBox(height: 16),

            // Check-in/Check-out button
            FilledButton(
              onPressed: isUserCheckedIn
                  ? (checkInState.isLoading ? null : () => _checkOut(currentUserId))
                  : (checkInState.isLoading ||
                          !isLocationAvailable ||
                          !isWithinRange)
                      ? null
                      : () => _checkIn(currentUserId),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isUserCheckedIn
                    ? Colors.orange.shade600
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: checkInState.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : isUserCheckedIn
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Check Out',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded, 
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Check In Now',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (checkInState.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        checkInState.error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkIn(String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Use the specific check-in point if provided, otherwise use the default method
    if (widget.checkInPoint != null) {
      await ref.read(checkInProvider.notifier).checkInUserToPoint(userId, widget.checkInPoint!.id);
    } else {
      await ref.read(checkInProvider.notifier).checkInUser(userId);
    }

    if (mounted && ref.read(checkInProvider).userCheckIn != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Successfully checked in!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Your attendance has been recorded',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _checkOut(String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(checkInProvider.notifier).checkOutUser(userId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Successfully checked out!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Your session has been ended',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
