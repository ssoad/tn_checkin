import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/check_in_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  @override
  void initState() {
    super.initState();
    // Update user location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkInProvider.notifier).updateUserLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);
    final checkInPoint = checkInState.activeCheckInPoint;

    if (checkInPoint == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Check In'),
          elevation: 0,
        ),
        body: const Center(
          child: Text('No active check-in point found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Check-in point info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkInPoint.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkInPoint.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.radio_button_checked, 
                               color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Radius: ${checkInPoint.radiusInMeters.toInt()}m',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Location status
              Card(
                color: checkInState.isWithinRange 
                    ? Colors.green.shade50 
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        checkInState.isWithinRange 
                            ? Icons.check_circle_outline 
                            : Icons.location_searching,
                        size: 48,
                        color: checkInState.isWithinRange 
                            ? Colors.green.shade600 
                            : Colors.orange.shade600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        checkInState.isWithinRange 
                            ? 'You are within check-in range!'
                            : 'Move closer to the check-in point',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: checkInState.isWithinRange 
                                  ? Colors.green.shade700 
                                  : Colors.orange.shade700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkInState.isWithinRange 
                            ? 'Tap the button below to check in'
                            : 'You need to be within ${checkInPoint.radiusInMeters.toInt()}m to check in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: checkInState.isWithinRange 
                                  ? Colors.green.shade600 
                                  : Colors.orange.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Refresh location button
              OutlinedButton.icon(
                onPressed: checkInState.isLoading 
                    ? null 
                    : () => ref.read(checkInProvider.notifier).updateUserLocation(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Location'),
              ),

              const SizedBox(height: 16),

              // Check-in button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (checkInState.isLoading || 
                              !checkInState.isWithinRange ||
                              checkInState.userCheckIn != null) 
                      ? null 
                      : _checkIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: checkInState.userCheckIn != null 
                        ? Colors.green 
                        : null,
                  ),
                  child: checkInState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : checkInState.userCheckIn != null
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Checked In', 
                                     style: TextStyle(color: Colors.white)),
                              ],
                            )
                          : const Text('Check In'),
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              if (checkInState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checkInState.error!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkIn() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(checkInProvider.notifier).checkInUser(userId);

    if (mounted && ref.read(checkInProvider).userCheckIn != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully checked in!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
