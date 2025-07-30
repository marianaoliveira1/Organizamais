import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PaymentOption extends StatelessWidget {
  final String title;
  final String assetPath;
  final TextEditingController controller;

  const PaymentOption({
    super.key,
    required this.title,
    required this.assetPath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        color: theme.cardColor,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 2.h,
        horizontal: 6.w,
      ),
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 22.w,
          height: 22.h,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          controller.text = title;
          Get.back();
        },
      ),
    );
  }
}
