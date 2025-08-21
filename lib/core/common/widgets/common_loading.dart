import 'package:flutter/material.dart';

/// A reusable loading indicator widget following Material 3 design principles
class CommonLoading extends StatelessWidget {
  /// The size of the loading indicator
  final CommonLoadingSize size;
  
  /// Custom color for the loading indicator
  final Color? color;
  
  /// The stroke width of the circular progress indicator
  final double? strokeWidth;
  
  /// Optional message to display below the loading indicator
  final String? message;
  
  /// Whether to show a backdrop overlay
  final bool showBackdrop;
  
  /// The backdrop color
  final Color? backdropColor;

  const CommonLoading({
    super.key,
    this.size = CommonLoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
    this.showBackdrop = false,
    this.backdropColor,
  });

  /// Creates a small loading indicator
  const CommonLoading.small({
    super.key,
    this.color,
    this.strokeWidth,
    this.message,
    this.showBackdrop = false,
    this.backdropColor,
  }) : size = CommonLoadingSize.small;

  /// Creates a large loading indicator
  const CommonLoading.large({
    super.key,
    this.color,
    this.strokeWidth,
    this.message,
    this.showBackdrop = false,
    this.backdropColor,
  }) : size = CommonLoadingSize.large;

  /// Creates a loading indicator with backdrop overlay
  const CommonLoading.overlay({
    super.key,
    this.size = CommonLoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
    this.backdropColor,
  }) : showBackdrop = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final double indicatorSize = switch (size) {
      CommonLoadingSize.small => 20,
      CommonLoadingSize.medium => 32,
      CommonLoadingSize.large => 48,
    };
    
    final double strokeWidthValue = strokeWidth ?? switch (size) {
      CommonLoadingSize.small => 2.0,
      CommonLoadingSize.medium => 3.0,
      CommonLoadingSize.large => 4.0,
    };

    Widget loadingIndicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidthValue,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
      ),
    );

    Widget content = message != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loadingIndicator,
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color ?? theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : loadingIndicator;

    if (showBackdrop) {
      return Container(
        color: backdropColor ?? Colors.black.withOpacity(0.3),
        child: Center(child: content),
      );
    }

    return content;
  }
}

/// Loading size variants
enum CommonLoadingSize {
  small,
  medium,
  large,
}

/// A linear loading progress bar widget
class CommonLinearLoading extends StatelessWidget {
  /// The progress value between 0.0 and 1.0 (null for indeterminate)
  final double? value;
  
  /// Custom color for the progress bar
  final Color? color;
  
  /// Custom background color for the progress bar
  final Color? backgroundColor;
  
  /// The height of the progress bar
  final double height;
  
  /// Border radius for rounded corners
  final double borderRadius;
  
  /// Optional label to display above the progress bar
  final String? label;
  
  /// Whether to show percentage text
  final bool showPercentage;

  const CommonLinearLoading({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    this.borderRadius = 2.0,
    this.label,
    this.showPercentage = false,
  });

  /// Creates a determinate progress bar with value
  const CommonLinearLoading.determinate({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    this.borderRadius = 2.0,
    this.label,
    this.showPercentage = true,
  });

  /// Creates an indeterminate progress bar
  const CommonLinearLoading.indeterminate({
    super.key,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    this.borderRadius = 2.0,
    this.label,
  }) : value = null, showPercentage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget progressBar = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? theme.colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
      ),
    );

    List<Widget> children = [];

    // Add label if provided
    if (label != null) {
      children.add(
        Text(
          label!,
          style: theme.textTheme.bodySmall,
        ),
      );
      children.add(const SizedBox(height: 8));
    }

    // Add progress bar
    children.add(progressBar);

    // Add percentage if enabled and value is provided
    if (showPercentage && value != null) {
      children.add(const SizedBox(height: 4));
      children.add(
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(value! * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// A skeleton loading widget for content placeholders
class CommonSkeletonLoading extends StatefulWidget {
  /// The width of the skeleton
  final double? width;
  
  /// The height of the skeleton
  final double height;
  
  /// Border radius for rounded corners
  final double borderRadius;
  
  /// Whether the skeleton should have a shimmer effect
  final bool shimmer;
  
  /// Base color of the skeleton
  final Color? baseColor;
  
  /// Highlight color for shimmer effect
  final Color? highlightColor;

  const CommonSkeletonLoading({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4.0,
    this.shimmer = true,
    this.baseColor,
    this.highlightColor,
  });

  /// Creates a text line skeleton
  const CommonSkeletonLoading.text({
    super.key,
    this.width,
    this.borderRadius = 4.0,
    this.shimmer = true,
    this.baseColor,
    this.highlightColor,
  }) : height = 16.0;

  /// Creates a circular avatar skeleton
  const CommonSkeletonLoading.avatar({
    super.key,
    required double size,
    this.shimmer = true,
    this.baseColor,
    this.highlightColor,
  }) : width = size, height = size, borderRadius = size / 2;

  /// Creates a rectangular card skeleton
  const CommonSkeletonLoading.card({
    super.key,
    this.width,
    this.height = 120.0,
    this.borderRadius = 12.0,
    this.shimmer = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<CommonSkeletonLoading> createState() => _CommonSkeletonLoadingState();
}

class _CommonSkeletonLoadingState extends State<CommonSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.shimmer) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceVariant;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surface;

    Widget skeleton = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    );

    if (!widget.shimmer) {
      return skeleton;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
