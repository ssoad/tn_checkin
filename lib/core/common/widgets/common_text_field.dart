import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable text field widget following Material 3 design principles
/// and clean architecture patterns.
class CommonTextField extends StatelessWidget {
  /// The controller for the text field
  final TextEditingController? controller;
  
  /// The label text displayed above the field
  final String? labelText;
  
  /// The hint text displayed inside the field when empty
  final String? hintText;
  
  /// The help text displayed below the field
  final String? helperText;
  
  /// The error text displayed below the field
  final String? errorText;
  
  /// The prefix icon
  final Widget? prefixIcon;
  
  /// The suffix icon
  final Widget? suffixIcon;
  
  /// Whether the text field is obscured (for passwords)
  final bool obscureText;
  
  /// Whether the text field is enabled
  final bool enabled;
  
  /// Whether the text field is required
  final bool required;
  
  /// The keyboard type
  final TextInputType? keyboardType;
  
  /// The text input action
  final TextInputAction? textInputAction;
  
  /// The maximum number of lines
  final int? maxLines;
  
  /// The minimum number of lines
  final int? minLines;
  
  /// The maximum length of text
  final int? maxLength;
  
  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;
  
  /// Validation function
  final String? Function(String?)? validator;
  
  /// Called when the text changes
  final ValueChanged<String>? onChanged;
  
  /// Called when the user submits the field
  final ValueChanged<String>? onFieldSubmitted;
  
  /// Called when the field is tapped
  final VoidCallback? onTap;
  
  /// Whether the field should autofocus
  final bool autofocus;
  
  /// Whether to show a character counter
  final bool showCounter;
  
  const CommonTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.required = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.autofocus = false,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          RichText(
            text: TextSpan(
              text: labelText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: showCounter ? maxLength : null,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          autofocus: autofocus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled 
                ? theme.colorScheme.onSurface 
                : theme.colorScheme.onSurface.withOpacity(0.38),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled 
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.12),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            prefixIconColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.focused)) {
                return theme.colorScheme.primary;
              }
              if (states.contains(MaterialState.error)) {
                return theme.colorScheme.error;
              }
              return theme.colorScheme.onSurfaceVariant;
            }),
            suffixIconColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.focused)) {
                return theme.colorScheme.primary;
              }
              if (states.contains(MaterialState.error)) {
                return theme.colorScheme.error;
              }
              return theme.colorScheme.onSurfaceVariant;
            }),
          ),
        ),
      ],
    );
  }
}

/// A specialized text field for passwords with built-in visibility toggle
class CommonPasswordField extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController? controller;
  
  /// The label text displayed above the field
  final String? labelText;
  
  /// The hint text displayed inside the field when empty
  final String? hintText;
  
  /// The help text displayed below the field
  final String? helperText;
  
  /// The error text displayed below the field
  final String? errorText;
  
  /// Whether the text field is enabled
  final bool enabled;
  
  /// Whether the text field is required
  final bool required;
  
  /// Validation function
  final String? Function(String?)? validator;
  
  /// Called when the text changes
  final ValueChanged<String>? onChanged;
  
  /// Called when the user submits the field
  final ValueChanged<String>? onFieldSubmitted;
  
  /// Whether the field should autofocus
  final bool autofocus;
  
  const CommonPasswordField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  State<CommonPasswordField> createState() => _CommonPasswordFieldState();
}

class _CommonPasswordFieldState extends State<CommonPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      required: widget.required,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText 
              ? Icons.visibility_outlined 
              : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
