import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class FinanceSummaryWidget extends StatelessWidget {
  const FinanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Total",
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "R\$ ${total.toStringAsFixed(2)}",
              style: TextStyle(
                color: DefaultColors.black,
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                _buildCategory("Receita", "R\$ ${totalReceita.toStringAsFixed(2)}", DefaultColors.green),
                SizedBox(width: 50.w),
                _buildCategory("Despesas", "R\$ ${totalDespesas.toStringAsFixed(2)}", DefaultColors.red),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategory(String title, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 38.h,
          width: 2.w,
          color: color,
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
