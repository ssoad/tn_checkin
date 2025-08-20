import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/check_in_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/check_in_point.dart';
import 'create_check_in_screen.dart';
import 'check_in_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load active check-in point when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkInProvider.notifier).loadActiveCheckInPoint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);
    final activeCheckInPointAsync = ref.watch(activeCheckInPointStreamProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TN Check-in',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          FilledButton.tonal(
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
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
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.waving_hand_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User: ${authState.user?.userType.name ?? 'Guest'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Check-in status
              if (checkInState.isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                activeCheckInPointAsync.when(
                  data: (activeCheckInPoint) {
                    if (activeCheckInPoint != null) {
                      return _buildActiveCheckInPoint(context, activeCheckInPoint);
                    } else {
                      return _buildNoActiveCheckInPoint(context);
                    }
                  },
                  loading: () => Center(
                    child: Column(
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
                  error: (error, stackTrace) => Container(
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

              const SizedBox(height: 24),

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
      ),
    );
  }

  Widget _buildActiveCheckInPoint(BuildContext context, CheckInPoint checkInPoint) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;
    final isUserCheckedIn = currentUserId != null && 
        checkInPoint.checkedInUserIds.contains(currentUserId);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CheckInScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.green.shade100.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${checkInPoint.checkedInCount}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              checkInPoint.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.radio_button_checked_rounded,
                  color: Colors.green.shade600,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Radius: ${checkInPoint.radiusInMeters.toInt()}m',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: isUserCheckedIn
                      ? FilledButton.icon(
                          onPressed: () async {
                            // Get current user ID from auth state
                            final authState = ref.read(authProvider);
                            final userId = authState.user?.id;
                            if (userId != null) {
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
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Successfully checked out!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text(
                            'Check Out',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CheckInScreen(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.location_on_rounded, size: 20),
                          label: Text(
                            'Check In Now',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                if (!isUserCheckedIn) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CheckInScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveCheckInPoint(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Active Check-in Point',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new check-in point to get started\nand manage your attendance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCheckInScreen(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              'Create Check-in Point',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
