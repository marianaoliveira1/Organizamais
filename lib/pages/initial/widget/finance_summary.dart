import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/widgetes/percentage_display_widget.dart';
import 'package:organizamais/widgetes/percentage_explanation_dialog.dart';

import 'package:organizamais/utils/color.dart';

import '../pages/finance_details_page.dart';
import 'category_value_with_percentage.dart';

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

    String mesAtual = DateFormat.MMMM('pt_BR').format(DateTime.now());

    return Obx(() {
      if (transactionController.isLoading) {
        return _buildShimmerSkeleton(theme);
      }

      return GestureDetector(
        onTap: () {
          Get.to(() => const FinanceDetailsPage());
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 14.w,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saldo do mês de ${mesAtual[0].toUpperCase()}${mesAtual.substring(1)}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DefaultColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 8.sp,
                    color: DefaultColors.grey,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formatter.format(transactionController.totalReceita -
                            transactionController.totalDespesas),
                        style: TextStyle(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      PercentageDisplayWidget(
                        result:
                            transactionController.monthlyPercentageComparison,
                        explanationType: PercentageExplanationType.balance,
                        currentValue: transactionController.totalReceita -
                            transactionController.totalDespesas,
                        previousValue:
                            _getPreviousMonthBalance(transactionController),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      CategoryValueWithPercentage(
                        title: "Receita",
                        value: formatter
                            .format(transactionController.totalReceita),
                        color: DefaultColors.green,
                        percentageResult:
                            transactionController.incomePercentageComparison,
                        explanationType: PercentageExplanationType.income,
                        currentValue: transactionController.totalReceita,
                        previousValue:
                            _getPreviousMonthIncome(transactionController),
                      ),
                      SizedBox(width: 24.w),
                      CategoryValueWithPercentage(
                        title: "Despesas",
                        value: formatter
                            .format(transactionController.totalDespesas),
                        color: DefaultColors.red,
                        percentageResult:
                            transactionController.expensePercentageComparison,
                        explanationType: PercentageExplanationType.expense,
                        currentValue: transactionController.totalDespesas,
                        previousValue:
                            _getPreviousMonthExpenses(transactionController),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  double _getPreviousMonthBalance(TransactionController controller) {
    final now = DateTime.now();
    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;

    final startDate = DateTime(previousYear, previousMonth, 1);
    final daysInPreviousMonth =
        DateTime(previousYear, previousMonth + 1, 0).day;
    final endDay =
        now.day > daysInPreviousMonth ? daysInPreviousMonth : now.day;
    final endDate = DateTime(previousYear, previousMonth, endDay, 23, 59, 59);

    return controller.getBalanceForDateRange(startDate, endDate);
  }

  double _getPreviousMonthIncome(TransactionController controller) {
    final now = DateTime.now();
    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;

    final startDate = DateTime(previousYear, previousMonth, 1);
    final daysInPreviousMonth =
        DateTime(previousYear, previousMonth + 1, 0).day;
    final endDay =
        now.day > daysInPreviousMonth ? daysInPreviousMonth : now.day;
    final endDate = DateTime(previousYear, previousMonth, endDay, 23, 59, 59);

    return controller
        .getTransactionsForDateRange(startDate, endDate)
        .where((t) => t.type == TransactionType.receita)
        .fold<double>(0.0, (sum, t) {
      try {
        return sum +
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      } catch (e) {
        return sum;
      }
    });
  }

  double _getPreviousMonthExpenses(TransactionController controller) {
    final now = DateTime.now();
    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;

    final startDate = DateTime(previousYear, previousMonth, 1);
    final daysInPreviousMonth =
        DateTime(previousYear, previousMonth + 1, 0).day;
    final endDay =
        now.day > daysInPreviousMonth ? daysInPreviousMonth : now.day;
    final endDate = DateTime(previousYear, previousMonth, endDay, 23, 59, 59);

    return controller
        .getTransactionsForDateRange(startDate, endDate)
        .where((t) => t.type == TransactionType.despesa)
        .fold<double>(0.0, (sum, t) {
      try {
        return sum +
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      } catch (e) {
        return sum;
      }
    });
  }

  Widget _buildShimmerSkeleton(ThemeData theme) {
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
          // Shimmer for title
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              height: 12.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Shimmer for main balance with percentage indicator
          Row(
            children: [
              Shimmer(
                duration: const Duration(milliseconds: 1400),
                color: Colors.white.withValues(alpha: 0.6),
                child: Container(
                  height: 32.h,
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Shimmer(
                duration: const Duration(milliseconds: 1400),
                color: Colors.white.withValues(alpha: 0.6),
                child: Container(
                  height: 20.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Shimmer for income and expenses with percentage indicators
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withValues(alpha: 0.6),
                        child: Container(
                          height: 12.h,
                          width: 50.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withValues(alpha: 0.6),
                        child: Container(
                          height: 16.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Shimmer(
                    duration: const Duration(milliseconds: 1400),
                    color: Colors.white.withValues(alpha: 0.6),
                    child: Container(
                      height: 16.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 24.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withValues(alpha: 0.6),
                        child: Container(
                          height: 12.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withValues(alpha: 0.6),
                        child: Container(
                          height: 16.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Shimmer(
                    duration: const Duration(milliseconds: 1400),
                    color: Colors.white.withValues(alpha: 0.6),
                    child: Container(
                      height: 16.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
