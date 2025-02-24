import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        color: theme.scaffoldBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 10,
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 22,
          height: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          controller.text = title;
          Navigator.pop(context);
        },
      ),
    );
  }
}
