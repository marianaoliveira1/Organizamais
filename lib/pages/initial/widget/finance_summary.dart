import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/ads_banner/ads_banner.dart';

import 'package:organizamais/controller/transaction_controller.dart';

import 'package:organizamais/utils/color.dart';

import '../pages/finance_details_page.dart';
import 'category_value.dart';

class FinanceSummaryWidget extends StatelessWidget {
  const FinanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => const FinanceDetailsPage());
      },
      child: Container(
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
            // AdsBanner(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DefaultColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(
              () {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatter.format(transactionController.totalReceita -
                          transactionController.totalDespesas),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        CategoryValue(
                          title: "Receita",
                          value: formatter
                              .format(transactionController.totalReceita),
                          color: DefaultColors.green,
                        ),
                        SizedBox(width: 24.w),
                        CategoryValue(
                          title: "Despesas",
                          value: formatter
                              .format(transactionController.totalDespesas),
                          color: DefaultColors.red,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
