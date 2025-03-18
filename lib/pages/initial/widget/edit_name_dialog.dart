import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

class EditNameDialog extends StatelessWidget {
  final AuthController authController;
  const EditNameDialog({required this.authController});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: authController.firebaseUser.value?.displayName);
    return AlertDialog(
      title: const Text('Editar Nome'),
      content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Novo nome')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            authController.updateDisplayName(controller.text);
            Get.back();
          },
          child: const Text(
            'Salvar',
          ),
        ),
      ],
    );
  }
}
