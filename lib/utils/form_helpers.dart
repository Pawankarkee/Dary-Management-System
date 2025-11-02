import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for managing form field focus and keyboard navigation
/// 
/// This provides smart keyboard behavior:
/// - Desktop: Enter key moves to next field (like Tab) or submits if last field
/// - Mobile: Next button moves to next field, Done button submits form
class FormFieldHelper {
  /// Creates a TextFormField with smart keyboard navigation
  /// 
  /// [controller] - TextEditingController for the field
  /// [focusNode] - FocusNode for this field
  /// [nextFocusNode] - FocusNode for the next field (null if this is the last field)
  /// [onSubmit] - Callback when form should be submitted (on last field)
  /// [validator] - Validation function for the field
  /// [decoration] - InputDecoration for the field
  /// [keyboardType] - Type of keyboard to show
  /// [textCapitalization] - Text capitalization behavior
  /// [maxLines] - Maximum number of lines
  /// [inputFormatters] - Input formatters for the field
  /// [obscureText] - Whether to obscure text (for passwords)
  /// [enabled] - Whether field is enabled
  /// [readOnly] - Whether field is read-only
  /// [autofocus] - Whether to autofocus this field
  static Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    VoidCallback? onSubmit,
    String? Function(String?)? validator,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    void Function(String)? onChanged,
  }) {
    // Determine if this is the last field (no next focus node)
    final isLastField = nextFocusNode == null;
    
    // Set appropriate text input action
    final textInputAction = isLastField 
        ? TextInputAction.done 
        : TextInputAction.next;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      
      // Handle Enter/Done key press
      onFieldSubmitted: (value) {
        // Validate the current field before moving
        if (validator != null) {
          final error = validator(value);
          if (error != null) {
            // Validation failed, stay on current field
            focusNode.requestFocus();
            return;
          }
        }
        
        if (isLastField) {
          // This is the last field - submit the form
          if (onSubmit != null) {
            onSubmit();
          }
        } else {
          // Move to next field
          nextFocusNode?.requestFocus();
        }
      },
    );
  }

  /// Moves focus to the next field
  /// Used for custom navigation logic
  static void moveToNextField(BuildContext context, FocusNode? nextFocusNode) {
    if (nextFocusNode != null) {
      FocusScope.of(context).requestFocus(nextFocusNode);
    }
  }

  /// Unfocus all fields (dismiss keyboard)
  static void unfocusAll(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Create a FocusNode with automatic disposal
  static FocusNode createFocusNode() {
    return FocusNode();
  }
}

/// Mixin for StatefulWidget to easily manage form focus nodes
/// 
/// Usage:
/// ```dart
/// class _MyFormState extends State<MyForm> with FormFocusManagement {
///   @override
///   void initState() {
///     super.initState();
///     initializeFocusNodes(5); // 5 fields in the form
///   }
/// }
/// ```
mixin FormFocusManagement<T extends StatefulWidget> on State<T> {
  List<FocusNode> _focusNodes = [];

  /// Initialize focus nodes for the form
  /// [count] - Number of fields in the form
  void initializeFocusNodes(int count) {
    _focusNodes = List.generate(count, (_) => FocusNode());
  }

  /// Get focus node at index
  FocusNode getFocusNode(int index) {
    if (index < 0 || index >= _focusNodes.length) {
      throw RangeError('Focus node index out of range');
    }
    return _focusNodes[index];
  }

  /// Get next focus node (null if last)
  FocusNode? getNextFocusNode(int currentIndex) {
    if (currentIndex < _focusNodes.length - 1) {
      return _focusNodes[currentIndex + 1];
    }
    return null;
  }

  /// Check if this is the last field
  bool isLastField(int index) {
    return index == _focusNodes.length - 1;
  }

  /// Dispose all focus nodes
  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
