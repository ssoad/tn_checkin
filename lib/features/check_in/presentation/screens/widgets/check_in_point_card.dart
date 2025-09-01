import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/global_location_service.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../domain/entities/check_in_point.dart';
import '../../providers/check_in_provider.dart';
import '../check_in_screen.dart';

class CheckInPointCard extends ConsumerWidget {
  final CheckInPoint checkInPoint;
  const CheckInPointCard({super.key, required this.checkInPoint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final globalLocationState = ref.watch(globalLocationProvider);
    final currentUserId = authState.user?.id;
    final isUserCheckedIn =
        currentUserId != null &&
        checkInPoint.checkedInUserIds.contains(currentUserId);

    final isWithinRange =
        globalLocationState.currentLocation != null &&
        ref
            .read(globalLocationProvider.notifier)
            .isWithinRangeOf(
              checkInPointLocation: checkInPoint.location,
              radiusInMeters: checkInPoint.radiusInMeters,
            );

    Color primaryColor;
    Color backgroundColor;
    Color borderColor;
    Color shadowColor;
    String statusText;
    IconData statusIcon;

    if (!globalLocationState.hasPermission ||
        globalLocationState.currentLocation == null) {
      primaryColor = Colors.grey.shade600;
      backgroundColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade200;
      shadowColor = Colors.grey;
      statusText = 'Location unavailable';
      statusIcon = Icons.location_disabled_rounded;
    } else if (isWithinRange) {
      primaryColor = Colors.green.shade600;
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade200;
      shadowColor = Colors.green;
      statusText = 'In range - Ready to check in!';
      statusIcon = Icons.check_circle_rounded;
    } else {
      primaryColor = Colors.orange.shade600;
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
      shadowColor = Colors.orange;
      statusText = 'Out of range';
      statusIcon = Icons.location_searching_rounded;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckInScreen(checkInPoint: checkInPoint),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
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
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        statusText.toUpperCase(),
                        style: const TextStyle(
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
                color: primaryColor,
              ),
            ),
            if (authState.user?.userType == UserType.creator) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Radius: ${checkInPoint.radiusInMeters.toInt()}m',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: isUserCheckedIn
                      ? FilledButton.icon(
                          onPressed: () async {
                            final authState = ref.read(authProvider);
                            final userId = authState.user?.id;
                            if (userId != null) {
                              await ref
                                  .read(checkInProvider.notifier)
                                  .checkOutUser(userId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
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
                                builder: (context) =>
                                    CheckInScreen(checkInPoint: checkInPoint),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(statusIcon, size: 20),
                          label: Text(
                            isWithinRange ? 'Check In Now' : 'Out of Range',
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
                      border: Border.all(color: borderColor),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckInScreen(checkInPoint: checkInPoint),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryColor,
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
}
