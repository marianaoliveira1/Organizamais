import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class DefaultTextFieldTransaction extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: DefaultColors.black,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: DefaultColors.black,
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        prefixIcon: icon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: DefaultColors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
