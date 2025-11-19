import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper function to safely show snackbars using GetX
/// This prevents LateInitializationError when GetMaterialApp is not ready
class SnackbarHelper {
  /// Shows a snackbar safely, checking if GetX is available
  static void showSnackbar(
    String title,
    String message, {
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    try {
      // Check if GetX context is available
      final context = Get.context;
      if (context == null) {
        debugPrint('Snackbar: $title - $message');
        return;
      }

      // Check if Overlay is available
      try {
        Overlay.of(context);
      } catch (_) {
        // Overlay not available, schedule snackbar for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackbarInternal(
            title,
            message,
            snackPosition: snackPosition,
            backgroundColor: backgroundColor,
            colorText: colorText,
            duration: duration,
          );
        });
        return;
      }

      // Show snackbar immediately if overlay is available
      _showSnackbarInternal(
        title,
        message,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration,
      );
    } catch (e) {
      // If Get.snackbar fails, log to console instead of crashing
      debugPrint('Error showing snackbar: $e');
      debugPrint('Snackbar: $title - $message');
    }
  }

  /// Internal method to show snackbar
  static void _showSnackbarInternal(
    String title,
    String message, {
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    try {
      final context = Get.context;
      if (context == null) {
        debugPrint('Snackbar: $title - $message');
        return;
      }

      // Verify overlay is still available
      try {
        Overlay.of(context);
      } catch (_) {
        debugPrint('Snackbar: $title - $message (Overlay not available)');
        return;
      }

      Get.snackbar(
        title,
        message,
        snackPosition: snackPosition ?? SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration ?? const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
      debugPrint('Snackbar: $title - $message');
    }
  }

  /// Shows a success snackbar
  static void showSuccess(String message) {
    showSnackbar(
      'Sucesso',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Shows an error snackbar
  static void showError(String message, {String? title}) {
    showSnackbar(
      title ?? 'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Shows an info snackbar
  static void showInfo(String message, {String? title}) {
    showSnackbar(
      title ?? 'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
