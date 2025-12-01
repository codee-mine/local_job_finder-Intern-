// SnackBar Utility
import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showSuccessMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle);
  }

  static void showErrorMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error);
  }

  static void showInfoMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info);
  }

  static void showWarningMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
