import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class FinanceSummaryWidget extends StatelessWidget {
  const FinanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    final theme = Theme.of(context);

    return Obx(() {
      double totalReceita = transactionController.transaction.where((t) => t.type == TransactionType.receita).fold(0, (sum, t) => sum + double.parse(t.value));

      double totalDespesas = transactionController.transaction.where((t) => t.type == TransactionType.despesa).fold(0, (sum, t) => sum + double.parse(t.value));

      double total = totalReceita - totalDespesas;

      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 16.w,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total",
              style: TextStyle(
                fontSize: 12.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              formatter.format(total),
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                CategoryValue(
                  title: "Receita",
                  value: formatter.format(totalReceita),
                  color: DefaultColors.green,
                ),
                SizedBox(width: 24.w),
                CategoryValue(
                  title: "Despesas",
                  value: formatter.format(totalDespesas),
                  color: DefaultColors.red,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class CategoryValue extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const CategoryValue({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barrinha colorida à esquerda
        Container(
          height: 44.h,
          width: 2.w,
          color: color,
        ),
        SizedBox(width: 8.w),
        // Título e valor
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da categoria
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            // Valor da categoria
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
