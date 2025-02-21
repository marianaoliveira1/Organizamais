import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class DefaultTextFieldTransaction extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Icon? icon;

  const DefaultTextFieldTransaction({
    super.key,
    required this.controller,
    this.icon,
    required this.hintText,
    required this.keyboardType,
  });

  @override
  State<DefaultTextFieldTransaction> createState() => _DefaultTextFieldTransactionState();
}

class _DefaultTextFieldTransactionState extends State<DefaultTextFieldTransaction> {
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    // Adiciona listener para detectar mudança de foco
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      cursorColor: DefaultColors.black,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: DefaultColors.black,
      ),
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      decoration: InputDecoration(
        fillColor: isFocused ? DefaultColors.backgroundIght : DefaultColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        prefixIcon: widget.icon,
        prefixIconColor: DefaultColors.grey,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        focusColor: DefaultColors.black,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: DefaultColors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
