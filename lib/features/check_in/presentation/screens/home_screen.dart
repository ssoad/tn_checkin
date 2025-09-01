import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/check_in_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'create_check_in_screen.dart';
import 'widgets/custom_location_loading.dart';
import 'widgets/error_card.dart';
import 'widgets/welcome_card.dart';
import 'widgets/check_in_point_card.dart';
import 'widgets/no_active_check_in_point.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load all active check-in points when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkInProvider.notifier).loadAllActiveCheckInPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);
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
            child: const Icon(Icons.logout_rounded, size: 20),
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
              const WelcomeCard(),

              const SizedBox(height: 32),

              // Check-in status
              if (checkInState.isLoading)
                CustomLocationLoading(theme: theme)
              else if (checkInState.allActiveCheckInPoints.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: checkInState.allActiveCheckInPoints.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final checkInPoint =
                        checkInState.allActiveCheckInPoints[index];
                    return CheckInPointCard(checkInPoint: checkInPoint);
                  },
                )
              else
                const NoActiveCheckInPoint(),

              const SizedBox(height: 24),

              // Error message
              if (checkInState.error != null)
                ErrorCard(theme: theme, checkInState: checkInState, ref: ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateCheckInScreen(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Location'),
      ),
    );
  }
}
