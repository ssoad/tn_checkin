import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/common/widgets/widgets.dart';
import '../../providers/check_in_provider.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.theme,
    required this.checkInState,
    required this.ref,
  });

  final ThemeData theme;
  final CheckInState checkInState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
          const SizedBox(height: 12),
          CommonButton.text(
            text: 'Retry',
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () {
              ref
                  .read(checkInProvider.notifier)
                  .loadAllActiveCheckInPoints();
            },
            foregroundColor: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}
