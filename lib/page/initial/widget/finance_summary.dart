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
          color: DefaultColors.white,
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
                color: DefaultColors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildCategory(
                  "Receita",
                  formatter.format(totalReceita), // <-- formatter
                  DefaultColors.green,
                ),
                SizedBox(width: 24.w),
                _buildCategory(
                  "Despesas",
                  formatter.format(totalDespesas), // <-- formatter
                  DefaultColors.red,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategory(String title, String value, Color color) {
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
                color: DefaultColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
