import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/color.dart';
import '../../transaction/transaction_page.dart';

class TextFieldValueFixedAccotuns extends StatelessWidget {
  const TextFieldValueFixedAccotuns({
    super.key,
    required this.valueController,
    required this.theme,
  });

  final TextEditingController valueController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: valueController,
      cursorColor: theme.primaryColor,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: theme.primaryColor,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        fillColor: theme.primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        prefixIcon: Icon(
          Icons.attach_money,
        ),
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
        hintText: "0,00",
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: theme.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
