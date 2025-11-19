import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/widgetes/percentage_display_widget.dart';
import 'package:organizamais/widgetes/percentage_explanation_dialog.dart';
import 'package:organizamais/model/percentage_result.dart';

import 'package:organizamais/utils/color.dart';

import '../../../widgetes/info_card.dart';
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

    final String mesAtual = DateFormat.MMMM('pt_BR').format(DateTime.now());

    return RepaintBoundary(
      child: Obx(() {
        if (transactionController.isLoading) {
          return _buildShimmerSkeleton(theme);
        }

        // Calcular valores uma única vez para evitar chamadas duplicadas
        final currentBalance = _getCurrentMonthBalance(transactionController);
        final previousBalance = _getPreviousMonthBalance(transactionController);
        final currentIncome = _getCurrentMonthIncome(transactionController);
        final previousIncome = _getPreviousMonthIncome(transactionController);
        final currentExpenses = _getCurrentMonthExpenses(transactionController);
        final previousExpenses =
            _getPreviousMonthExpenses(transactionController);

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => const FinanceDetailsPage());
              },
              child: InfoCard(
                title:
                    'Saldo do mês de ${mesAtual[0].toUpperCase()}${mesAtual.substring(1)}',
                icon: Iconsax.arrow_right_3,
                onTap: () {
                  Get.to(() => const FinanceDetailsPage());
                },
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MonthlyBalanceHeader(
                      saldo: currentBalance,
                      previousSaldo: previousBalance,
                      percentageResult:
                          transactionController.monthlyPercentageComparison,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        CategoryValueWithPercentage(
                          title: "Receita",
                          value: formatter.format(currentIncome),
                          color: DefaultColors.green,
                          percentageResult:
                              transactionController.incomePercentageComparison,
                          explanationType: PercentageExplanationType.income,
                          currentValue: currentIncome,
                          previousValue: previousIncome,
                        ),
                        SizedBox(width: 24.w),
                        CategoryValueWithPercentage(
                          title: "Despesas",
                          value: formatter.format(currentExpenses),
                          color: DefaultColors.red,
                          percentageResult:
                              transactionController.expensePercentageComparison,
                          explanationType: PercentageExplanationType.expense,
                          currentValue: currentExpenses,
                          previousValue: previousExpenses,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  double _getCurrentMonthBalance(TransactionController controller) {
    final now = DateTime.now();
    // Comparar período equivalente: do dia 1 até o dia atual
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return controller.getBalanceForDateRange(startDate, endDate);
  }

  double _getCurrentMonthIncome(TransactionController controller) {
    final now = DateTime.now();
    // Comparar período equivalente: do dia 1 até o dia atual
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final transactions =
        controller.getTransactionsForDateRange(startDate, endDate);
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.receita) {
        try {
          total += _parseValue(t.value);
        } catch (_) {
          // Ignora valores inválidos
        }
      }
    }
    return total;
  }

  // Helper para parsing otimizado de valores
  double _parseValue(String value) {
    final cleaned = value.replaceAll('R\$', '').trim();
    if (cleaned.contains(',')) {
      return double.parse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.parse(cleaned.replaceAll(' ', ''));
  }

  double _getCurrentMonthExpenses(TransactionController controller) {
    final now = DateTime.now();
    // Comparar período equivalente: do dia 1 até o dia atual
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final transactions =
        controller.getTransactionsForDateRange(startDate, endDate);
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.despesa) {
        try {
          total += _parseValue(t.value);
        } catch (_) {
          // Ignora valores inválidos
        }
      }
    }
    return total;
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

    final transactions =
        controller.getTransactionsForDateRange(startDate, endDate);
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.receita) {
        try {
          total += _parseValue(t.value);
        } catch (_) {
          // Ignora valores inválidos
        }
      }
    }
    return total;
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

    final transactions =
        controller.getTransactionsForDateRange(startDate, endDate);
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.despesa) {
        try {
          total += _parseValue(t.value);
        } catch (_) {
          // Ignora valores inválidos
        }
      }
    }
    return total;
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

class _MonthlyBalanceHeader extends StatelessWidget {
  final double saldo;
  final double previousSaldo;
  final PercentageResult percentageResult;

  const _MonthlyBalanceHeader({
    required this.saldo,
    required this.previousSaldo,
    required this.percentageResult,
  });

  @override
  Widget build(BuildContext context) {
    // mesAtual não é utilizado diretamente aqui, mantido no escopo superior
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 1: Valor em R$
          AutoSizeText(
            formatter.format(saldo),
            maxLines: 1,
            minFontSize: 16,
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          // Linha 2: Percentual abaixo
          PercentageDisplayWidget(
            result: percentageResult,
            explanationType: PercentageExplanationType.balance,
            currentValue: saldo,
            previousValue: previousSaldo,
            textFontSizeSp: 14.sp,
          ),
        ],
      ),
    );
  }
}
