// ——— IMPORTS ——————————————————————————————
import 'package:flutter/material.dart';
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

// ——— WIDGET PRINCIPAL ——————————————————————————————
class FinanceSummaryWidget extends StatelessWidget {
  const FinanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Proporções responsivas
    final double spacing = height * 0.02;
    final double bigFont = width * 0.10;
    final double cardSpacing = width * 0.06;

    final formatter = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");
    final mesAtual = DateFormat.MMMM('pt_BR').format(DateTime.now());

    return RepaintBoundary(
      child: Obx(() {
        if (controller.isLoading) {
          return _buildShimmer(theme, width, height);
        }

        // ——— Cálculos apenas 1 vez ——————————
        final currentBalance = _getCurrentMonthBalance(controller);
        final previousBalance = _getPreviousMonthBalance(controller);
        final currentIncome = _getCurrentMonthIncome(controller);
        final previousIncome = _getPreviousMonthIncome(controller);
        final currentExpenses = _getCurrentMonthExpensesToDate(controller);
        final previousExpenses = _getPreviousMonthExpensesToDate(controller);
        final committedExpenses = _getCommittedMonthExpenses(controller);

        return Column(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => const FinanceDetailsPage()),
              child: InfoCard(
                title:
                    'Saldo do mês de ${mesAtual[0].toUpperCase()}${mesAtual.substring(1)}',
                icon: Iconsax.arrow_right_3,
                onTap: () => Get.to(() => const FinanceDetailsPage()),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ——— Cabeçalho (saldo + %) ——————————
                    _MonthlyBalanceHeader(
                      saldo: currentBalance,
                      previousSaldo: previousBalance,
                      percentageResult: controller.monthlyPercentageComparison,
                      bigFont: bigFont,
                      spacing: spacing,
                    ),

                    SizedBox(height: spacing * 1.2),

                    /// ——— Receita & Despesa ——————————
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CategoryValueWithPercentage(
                            title: "Receita",
                            value: formatter.format(currentIncome),
                            color: DefaultColors.green,
                            percentageResult:
                                controller.incomePercentageComparison,
                            explanationType: PercentageExplanationType.income,
                            currentValue: currentIncome,
                            previousValue: previousIncome,
                          ),
                        ),
                        SizedBox(width: cardSpacing),
                        Expanded(
                          child: CategoryValueWithPercentage(
                            title: "Despesas",
                            value: formatter.format(committedExpenses),
                            color: DefaultColors.red,
                            percentageResult:
                                controller.expensePercentageComparison,
                            explanationType: PercentageExplanationType.expense,
                            currentValue: currentExpenses,
                            previousValue: previousExpenses,
                          ),
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

  // ——— FUNÇÕES DE CÁLCULO (mantidas iguais) ——————————————————
  double _getCurrentMonthBalance(TransactionController controller) {
    final now = DateTime.now();
    return controller.getBalanceForDateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day, 23, 59),
    );
  }

  double _getCurrentMonthIncome(TransactionController controller) {
    final now = DateTime.now();
    final transactions = controller.getTransactionsForDateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day, 23, 59),
    );
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.receita) total += _parseValue(t.value);
    }
    return total;
  }

  double _getCommittedMonthExpenses(TransactionController controller) {
    final now = DateTime.now();
    return _sumExpensesForRange(
      controller,
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
  }

  double _getCurrentMonthExpensesToDate(TransactionController controller) {
    final now = DateTime.now();
    return _sumExpensesForRange(
      controller,
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day, 23, 59),
    );
  }

  double _getPreviousMonthBalance(TransactionController controller) {
    final now = DateTime.now();
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final days = DateTime(prevYear, prevMonth + 1, 0).day;
    final endDay = now.day > days ? days : now.day;
    return controller.getBalanceForDateRange(
      DateTime(prevYear, prevMonth, 1),
      DateTime(prevYear, prevMonth, endDay, 23, 59),
    );
  }

  double _getPreviousMonthIncome(TransactionController controller) {
    final now = DateTime.now();
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final days = DateTime(prevYear, prevMonth + 1, 0).day;
    final endDay = now.day > days ? days : now.day;

    final transactions = controller.getTransactionsForDateRange(
      DateTime(prevYear, prevMonth, 1),
      DateTime(prevYear, prevMonth, endDay),
    );

    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.receita) total += _parseValue(t.value);
    }
    return total;
  }

  double _getPreviousMonthExpensesToDate(TransactionController controller) {
    final now = DateTime.now();
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final days = DateTime(prevYear, prevMonth + 1, 0).day;
    final endDay = now.day > days ? days : now.day;

    return _sumExpensesForRange(
      controller,
      DateTime(prevYear, prevMonth, 1),
      DateTime(prevYear, prevMonth, endDay),
    );
  }

  double _sumExpensesForRange(
    TransactionController controller,
    DateTime start,
    DateTime end,
  ) {
    final transactions = controller.getTransactionsForDateRange(start, end);
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.despesa) {
        total += _parseValue(t.value);
      }
    }
    return total;
  }

  double _parseValue(String value) {
    return double.parse(
      value
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim(),
    );
  }

  // ——— SHIMMER RESPONSIVO ————————————————————————————————
  Widget _buildShimmer(ThemeData theme, double width, double height) {
    final boxHeight = height * 0.018;
    final boxWidth = width * 0.25;

    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            child: Container(
              height: boxHeight,
              width: width * 0.40,
              decoration: _shimmerBoxDecoration(),
            ),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              Shimmer(
                child: Container(
                  height: height * 0.03,
                  width: width * 0.35,
                  decoration: _shimmerBoxDecoration(),
                ),
              ),
              SizedBox(width: width * 0.02),
              Shimmer(
                child: Container(
                  height: height * 0.022,
                  width: width * 0.12,
                  decoration: _shimmerBoxDecoration(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _shimmerBoxDecoration() {
    return BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.circular(8),
    );
  }
}

// ——— CABEÇALHO (saldo + porcentagem) ——————————————————————————
class _MonthlyBalanceHeader extends StatelessWidget {
  final double saldo;
  final double previousSaldo;
  final PercentageResult percentageResult;

  final double bigFont;
  final double spacing;

  const _MonthlyBalanceHeader({
    required this.saldo,
    required this.previousSaldo,
    required this.percentageResult,
    required this.bigFont,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          formatter.format(saldo),
          maxLines: 1,
          minFontSize: 16,
          style: TextStyle(
            fontSize: bigFont,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        SizedBox(height: spacing * 0.5),
        PercentageDisplayWidget(
          result: percentageResult,
          explanationType: PercentageExplanationType.balance,
          currentValue: saldo,
          previousValue: previousSaldo,
        ),
      ],
    );
  }
}
