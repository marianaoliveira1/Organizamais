import 'package:flutter/material.dart';

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
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            widget.authController.updateDisplayName(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Salvar',
          ),
        ),
      ],
    );
  }
}
