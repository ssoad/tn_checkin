import 'package:flutter/material.dart';

/// A reusable card widget following Material 3 design principles
class CommonCard extends StatelessWidget {
  /// The widget to display inside the card
  final Widget child;
  
  /// The callback function when card is tapped
  final VoidCallback? onTap;
  
  /// The callback function when card is long pressed
  final VoidCallback? onLongPress;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Custom border color
  final Color? borderColor;
  
  /// Custom shadow color
  final Color? shadowColor;
  
  /// The elevation of the card
  final double elevation;
  
  /// Border radius for rounded corners
  final double borderRadius;
  
  /// Internal padding
  final EdgeInsets padding;
  
  /// External margin
  final EdgeInsets margin;
  
  /// Card style variant
  final CommonCardStyle style;
  
  /// Whether to show a border
  final bool showBorder;
  
  /// Border width when showBorder is true
  final double borderWidth;

  const CommonCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.elevation = 1.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.style = CommonCardStyle.elevated,
    this.showBorder = false,
    this.borderWidth = 1.0,
  });

  /// Creates an elevated card (default Material 3 style)
  const CommonCard.elevated({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.shadowColor,
    this.elevation = 1.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  }) : style = CommonCardStyle.elevated,
       borderColor = null,
       showBorder = false,
       borderWidth = 1.0;

  /// Creates a filled card (tonal style)
  const CommonCard.filled({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  }) : style = CommonCardStyle.filled,
       borderColor = null,
       shadowColor = null,
       elevation = 0.0,
       showBorder = false,
       borderWidth = 1.0;

  /// Creates an outlined card
  const CommonCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderWidth = 1.0,
  }) : style = CommonCardStyle.outlined,
       shadowColor = null,
       elevation = 0.0,
       showBorder = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine background color based on style
    Color cardBackgroundColor = backgroundColor ?? switch (style) {
      CommonCardStyle.elevated => theme.colorScheme.surface,
      CommonCardStyle.filled => theme.colorScheme.surfaceVariant,
      CommonCardStyle.outlined => theme.colorScheme.surface,
    };

    // Determine shadow color
    Color cardShadowColor = shadowColor ?? theme.colorScheme.shadow;

    // Determine border
    Border? border = showBorder ? Border.all(
      color: borderColor ?? theme.colorScheme.outline,
      width: borderWidth,
    ) : null;

    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: elevation > 0 ? [
          BoxShadow(
            color: cardShadowColor.withOpacity(0.1),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    // Add tap functionality if provided
    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Card style variants
enum CommonCardStyle {
  elevated,
  filled,
  outlined,
}

/// A specialized info card widget with icon, title, and description
class CommonInfoCard extends StatelessWidget {
  /// The icon to display
  final Widget? icon;
  
  /// The title text
  final String title;
  
  /// The description text
  final String? description;
  
  /// The callback function when card is tapped
  final VoidCallback? onTap;
  
  /// Custom primary color (affects icon and title)
  final Color? primaryColor;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Card style variant
  final CommonCardStyle style;
  
  /// Whether to show a trailing arrow
  final bool showTrailingArrow;
  
  /// Custom trailing widget
  final Widget? trailing;

  const CommonInfoCard({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.onTap,
    this.primaryColor,
    this.backgroundColor,
    this.style = CommonCardStyle.elevated,
    this.showTrailingArrow = false,
    this.trailing,
  });

  /// Creates an info card with trailing arrow
  const CommonInfoCard.navigation({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.onTap,
    this.primaryColor,
    this.backgroundColor,
    this.style = CommonCardStyle.elevated,
    this.trailing,
  }) : showTrailingArrow = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;

    List<Widget> children = [];

    // Icon
    if (icon != null) {
      children.add(
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectivePrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: effectivePrimaryColor,
              size: 24,
            ),
            child: icon!,
          ),
        ),
      );
      children.add(const SizedBox(width: 16));
    }

    // Title and description
    children.add(
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: effectivePrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Trailing widget
    if (trailing != null) {
      children.add(const SizedBox(width: 16));
      children.add(trailing!);
    } else if (showTrailingArrow) {
      children.add(const SizedBox(width: 16));
      children.add(
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return CommonCard(
      style: style,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        children: children,
      ),
    );
  }
}

/// A status card widget for displaying status information
class CommonStatusCard extends StatelessWidget {
  /// The status text
  final String status;
  
  /// The description text
  final String? description;
  
  /// The status type
  final CommonStatusType type;
  
  /// Custom icon
  final Widget? icon;
  
  /// The callback function when card is tapped
  final VoidCallback? onTap;
  
  /// Whether to show the status with a badge style
  final bool badge;

  const CommonStatusCard({
    super.key,
    required this.status,
    this.description,
    required this.type,
    this.icon,
    this.onTap,
    this.badge = false,
  });

  /// Creates a success status card
  const CommonStatusCard.success({
    super.key,
    required this.status,
    this.description,
    this.icon,
    this.onTap,
    this.badge = false,
  }) : type = CommonStatusType.success;

  /// Creates an error status card
  const CommonStatusCard.error({
    super.key,
    required this.status,
    this.description,
    this.icon,
    this.onTap,
    this.badge = false,
  }) : type = CommonStatusType.error;

  /// Creates a warning status card
  const CommonStatusCard.warning({
    super.key,
    required this.status,
    this.description,
    this.icon,
    this.onTap,
    this.badge = false,
  }) : type = CommonStatusType.warning;

  /// Creates an info status card
  const CommonStatusCard.info({
    super.key,
    required this.status,
    this.description,
    this.icon,
    this.onTap,
    this.badge = false,
  }) : type = CommonStatusType.info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine colors based on status type
    final (backgroundColor, borderColor, iconColor, textColor) = switch (type) {
      CommonStatusType.success => (
        Colors.green.withOpacity(0.1),
        Colors.green,
        Colors.green,
        Colors.green.shade700,
      ),
      CommonStatusType.error => (
        Colors.red.withOpacity(0.1),
        Colors.red,
        Colors.red,
        Colors.red.shade700,
      ),
      CommonStatusType.warning => (
        Colors.orange.withOpacity(0.1),
        Colors.orange,
        Colors.orange,
        Colors.orange.shade700,
      ),
      CommonStatusType.info => (
        Colors.blue.withOpacity(0.1),
        Colors.blue,
        Colors.blue,
        Colors.blue.shade700,
      ),
    };

    // Determine default icon
    Widget defaultIcon = switch (type) {
      CommonStatusType.success => const Icon(Icons.check_circle),
      CommonStatusType.error => const Icon(Icons.error),
      CommonStatusType.warning => const Icon(Icons.warning),
      CommonStatusType.info => const Icon(Icons.info),
    };

    Widget effectiveIcon = icon ?? defaultIcon;

    if (badge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: iconColor, size: 16),
              child: effectiveIcon,
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return CommonCard.outlined(
      backgroundColor: backgroundColor,
      borderColor: borderColor.withOpacity(0.3),
      onTap: onTap,
      child: Row(
        children: [
          IconTheme(
            data: IconThemeData(color: iconColor, size: 24),
            child: effectiveIcon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status type for status cards
enum CommonStatusType {
  success,
  error,
  warning,
  info,
}
