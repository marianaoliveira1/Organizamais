import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/color.dart';

import 'payment_type_page.dart';

class PaymentTypeField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: theme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.grey20,
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.payment,
          color: DefaultColors.grey20,
          size: 24.w,
        ),
      ),
      onTap: () => Get.to(() => PaymentTypePage(controller: controller)),
    );
  }
}
