import 'package:flutter/material.dart';

/// A reusable primary button widget following Material 3 design principles
class CommonButton extends StatelessWidget {
  /// The text to display on the button
  final String text;
  
  /// The callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// The icon to display before the text (optional)
  final Widget? icon;
  
  /// Whether the button is loading
  final bool isLoading;
  
  /// The button style variant
  final CommonButtonStyle style;
  
  /// Whether the button should expand to full width
  final bool fullWidth;
  
  /// Custom background color (overrides style)
  final Color? backgroundColor;
  
  /// Custom foreground color (overrides style)
  final Color? foregroundColor;
  
  /// Button size
  final CommonButtonSize size;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = CommonButtonStyle.filled,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = CommonButtonSize.medium,
  });

  /// Creates a filled button (primary style)
  const CommonButton.filled({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = CommonButtonSize.medium,
  }) : style = CommonButtonStyle.filled;

  /// Creates an outlined button (secondary style)
  const CommonButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = CommonButtonSize.medium,
  }) : style = CommonButtonStyle.outlined;

  /// Creates a text button (tertiary style)
  const CommonButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = CommonButtonSize.medium,
  }) : style = CommonButtonStyle.text;

  /// Creates a tonal button (surface variant)
  const CommonButton.tonal({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = CommonButtonSize.medium,
  }) : style = CommonButtonStyle.tonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    
    // Button dimensions based on size
    final double buttonHeight = switch (size) {
      CommonButtonSize.small => 36,
      CommonButtonSize.medium => 48,
      CommonButtonSize.large => 56,
    };
    
    final EdgeInsets padding = switch (size) {
      CommonButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      CommonButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      CommonButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    };

    final double iconSize = switch (size) {
      CommonButtonSize.small => 16,
      CommonButtonSize.medium => 20,
      CommonButtonSize.large => 24,
    };

    Widget buttonChild = _buildButtonContent(iconSize, context);

    Widget button = switch (style) {
      CommonButtonStyle.filled => FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, buttonHeight),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        ),
      CommonButtonStyle.outlined => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, buttonHeight),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: foregroundColor ?? theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: buttonChild,
        ),
      CommonButtonStyle.text => TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, buttonHeight),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        ),
      CommonButtonStyle.tonal => FilledButton.tonal(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, buttonHeight),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildButtonContent(double iconSize, BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == CommonButtonStyle.filled 
                ? Colors.white 
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: icon!,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

/// Button style variants
enum CommonButtonStyle {
  filled,
  outlined,
  text,
  tonal,
}

/// Button size variants
enum CommonButtonSize {
  small,
  medium,
  large,
}

/// A floating action button variant following Material 3 design
class CommonFloatingActionButton extends StatelessWidget {
  /// The callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// The icon to display
  final Widget? icon;
  
  /// The label text (for extended FAB)
  final String? label;
  
  /// Whether this is an extended FAB
  final bool extended;
  
  /// Whether this is a mini FAB
  final bool mini;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Custom foreground color
  final Color? foregroundColor;
  
  /// Hero tag for multiple FABs
  final String? heroTag;

  const CommonFloatingActionButton({
    super.key,
    this.onPressed,
    this.icon,
    this.label,
    this.extended = false,
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  /// Creates an extended FAB with icon and label
  const CommonFloatingActionButton.extended({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  }) : extended = true, mini = false;

  /// Creates a mini FAB
  const CommonFloatingActionButton.mini({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  }) : extended = false, mini = true, label = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
        heroTag: heroTag,
        icon: icon,
        label: Text(label!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
      heroTag: heroTag,
      mini: mini,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(mini ? 12 : 16),
      ),
      child: icon,
    );
  }
}
