import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final AuthController authController;
  const LogoutConfirmationDialog({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(
        'Deseja sair?',
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Não',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            authController.logout();
            Get.back();
          },
          child: Text(
            'Sim',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
