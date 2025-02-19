import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          spacing: 20.h,
          children: [
            DefaultCardResume(
              text: "Entradas",
              color: DefaultColors.green,
            ),
            DefaultCardResume(
              text: "Saídas",
              color: DefaultColors.red,
            ),
            DefaultCardResume(
              text: "Transfrencias",
              color: DefaultColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultCardResume extends StatelessWidget {
  final String text;
  final Color color;
  const DefaultCardResume({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              color: DefaultColors.grey,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Salario",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: DefaultColors.black,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                "R\$ 10.000,00",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: DefaultColors.black,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "R\$ 10.000,00",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
