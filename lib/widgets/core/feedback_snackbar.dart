import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class FeedbackSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green.shade700, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Theme.of(context).colorScheme.error, Icons.error_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.orange.shade700, Icons.warning_amber_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, Theme.of(context).colorScheme.primary, Icons.info_outline);
  }

  static void _showSnackbar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body(Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
