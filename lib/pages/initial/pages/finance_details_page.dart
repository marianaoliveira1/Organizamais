import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../transaction/transaction_page.dart';

import '../../../widgetes/percentage_explanation_dialog.dart';
import '../../../utils/color.dart';

class FinanceDetailsPage extends StatelessWidget {
  const FinanceDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    // Pega o mês e o ano atuais
    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Obx(() {
        // Filtra transações de receita para o mês atual
        final receivedTransactions =
            transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.receita &&
                paymentDate.month == currentMonth &&
                paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Ordena por data mais recente primeiro
        receivedTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.paymentDay!);
          DateTime dateB = DateTime.parse(b.paymentDay!);
          return dateB.compareTo(
              dateA); // Ordenação decrescente (mais recente primeiro)
        });

        // Filtra transações de despesa para o mês atual
        final expenseTransactions =
            transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.despesa &&
                paymentDate.month == currentMonth &&
                paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Ordena por data mais recente primeiro
        expenseTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.paymentDay!);
          DateTime dateB = DateTime.parse(b.paymentDay!);
          return dateB.compareTo(
              dateA); // Ordenação decrescente (mais recente primeiro)
        });

        // Calcula valores para comparação
        final currentBalance = transactionController.totalReceita -
            transactionController.totalDespesas;
        final previousBalance = _getPreviousMonthBalance(transactionController);
        final previousIncome = _getPreviousMonthIncome(transactionController);
        final previousExpenses =
            _getPreviousMonthExpenses(transactionController);

        final today = DateTime.now();

        return Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção de comparação financeira
                    _buildComparisonSection(
                      theme,
                      formatter,
                      transactionController,
                      currentBalance,
                      previousBalance,
                      previousIncome,
                      previousExpenses,
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      "Receitas",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    receivedTransactions.isEmpty
                        ? _buildEmptyState(
                            "Nenhuma receita registrada neste mês")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: receivedTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = receivedTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                              );
                            },
                          ),

                    SizedBox(height: 24.h),

                    // Seção de despesas
                    Text(
                      "Despesas",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    expenseTransactions.isEmpty
                        ? _buildEmptyState(
                            "Nenhuma despesa registrada neste mês")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: expenseTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = expenseTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                              );
                            },
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

  Widget _buildComparisonItem(
    ThemeData theme,
    NumberFormat formatter,
    String title,
    double currentValue,
    double previousValue,
    dynamic percentageResult,
    PercentageExplanationType type,
  ) {
    final difference = currentValue - previousValue;
    final isPositive = difference >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            if (percentageResult.hasData)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    percentageResult.icon,
                    size: 14.sp,
                    color: percentageResult.color,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    percentageResult.formattedPercentage,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: percentageResult.color,
                    ),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mês anterior:',
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  formatter.format(previousValue),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Mês atual:',
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  formatter.format(currentValue),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(color: DefaultColors.grey.withValues(alpha: 0.3)),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Diferença:',
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${formatter.format(difference)}',
              style: TextStyle(
                color: isPositive ? DefaultColors.green : DefaultColors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
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

  Widget _buildComparisonSection(
    ThemeData theme,
    NumberFormat formatter,
    TransactionController controller,
    double currentBalance,
    double previousBalance,
    double previousIncome,
    double previousExpenses,
  ) {
    final today = DateTime.now();
    return Container(
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
          // Text(
          //   "Saldo Total",
          //   style: TextStyle(
          //     fontSize: 10.sp,
          //     color: DefaultColors.grey,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          // SizedBox(height: 6.h),

          _buildComparisonItem(
            theme,
            formatter,
            "Saldo",
            currentBalance,
            previousBalance,
            controller.monthlyPercentageComparison,
            PercentageExplanationType.balance,
          ),
          SizedBox(height: 12.h),
          _buildComparisonItem(
            theme,
            formatter,
            "Receitas",
            controller.totalReceita,
            previousIncome,
            controller.incomePercentageComparison,
            PercentageExplanationType.income,
          ),
          SizedBox(height: 12.h),
          _buildComparisonItem(
            theme,
            formatter,
            "Despesas",
            controller.totalDespesas,
            previousExpenses,
            controller.expensePercentageComparison,
            PercentageExplanationType.expense,
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: DefaultColors.grey20.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: DefaultColors.grey20,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'A comparação é feita entre o período de 1º até o dia ${today.day} do mês atual versus o mesmo período do mês anterior. Isso garante uma comparação justa entre períodos equivalentes.',
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      width: double.infinity,
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 40.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paymentDate = DateTime.parse(transaction.paymentDay!);
    final formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);
    final double value = double.parse(
        transaction.value.replaceAll('.', '').replaceAll(',', '.'));
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return InkWell(
      onTap: () => Get.to(
        () => TransactionPage(
          transaction: transaction,
          overrideTransactionSalvar: (updatedTransaction) {
            final controller = Get.find<TransactionController>();
            controller.updateTransaction(updatedTransaction);
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatter.format(value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    transaction.paymentType ?? "Não especificado",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
