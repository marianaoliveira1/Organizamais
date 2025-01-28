import 'package:flutter/material.dart';

class DefaultContinueCom extends StatelessWidget {
  const DefaultContinueCom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey, // Cor da linha
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "ou continue com",
            style: TextStyle(color: Colors.grey), // Cor do texto
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey, // Cor da linha
          ),
        ),
      ],
    );
  }
}
