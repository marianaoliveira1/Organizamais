import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

class EditNameDialog extends StatefulWidget {
  final AuthController authController;
  const EditNameDialog({super.key, required this.authController});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: widget.authController.firebaseUser.value?.displayName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nome'),
      content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Novo nome')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            widget.authController.updateDisplayName(controller.text);
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
