import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text('Deseja sair?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Não')),
        TextButton(
            onPressed: () {
              authController.logout();
              Get.back();
            },
            child: const Text('Sim')),
      ],
    );
  }
}
