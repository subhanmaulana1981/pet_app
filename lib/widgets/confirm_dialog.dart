
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  /* properti */
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /* konstruksi */
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'delete',
    this.cancelLabel = 'cancel',
    this.isDestructive = true,
  });

  /* methods */
  // convenient static helper to show the dialog
  static Future<bool> show(BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'delete',
    String cancelLabel = 'cancel',
    bool isDestructive = true
  }) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          isDestructive: isDestructive,
        );
      },
    );

    // return false if user tapped outside
    // or dismissed with back button
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmColor = isDestructive
      ? theme.colorScheme.error
      : theme.colorScheme.primary;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancelLabel)
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(confirmLabel)
        ),
      ],
    );
  }
}
