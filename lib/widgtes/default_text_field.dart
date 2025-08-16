import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

class DefaultTextField extends StatefulWidget {
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
  State<DefaultTextField> createState() => _DefaultTextFieldState();
}

class _DefaultTextFieldState extends State<DefaultTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    // Se for senha, começa obscurecido
    _obscureText = widget.hintText.toLowerCase().contains('senha');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: DefaultColors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.hintText.toLowerCase().contains('senha')
            ? IconButton(
                icon: Icon(
                  _obscureText ? Iconsax.eye : Iconsax.eye_slash,
                  color: DefaultColors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: DefaultColors.grey,
        ),
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
