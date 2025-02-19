import 'package:flutter/material.dart';
import 'package:organizamais/utils/color.dart';

class DefaultTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget prefixIcon;

  const DefaultTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: hintText == "Senha" ? true : false,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        filled: true,
        fillColor: DefaultColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            24.0,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
