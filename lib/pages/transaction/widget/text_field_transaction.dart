// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      cursorColor: theme.primaryColor,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: theme.primaryColor,
      ),
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(.5),
          ),
        ),
        prefixIcon: widget.icon,
        prefixIconColor: DefaultColors.grey,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(.5),
          ),
        ),
        focusColor: theme.primaryColor,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: theme.primaryColor.withOpacity(.5),
        ),
      ),
    );
  }
}
