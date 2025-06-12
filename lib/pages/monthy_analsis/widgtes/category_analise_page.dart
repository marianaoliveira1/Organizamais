import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../graphics/graphics_page.dart';

class CategoryAnalysisPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;
  final String monthName;
  final double totalValue;
  final double percentual;

  const CategoryAnalysisPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.monthName,
    required this.totalValue,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    List<TransactionModel> transactions =
        _getTransactionsByCategoryAndMonth(categoryId, monthName);

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
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
                  // Resumo da categoria
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${percentual.toStringAsFixed(1)}% do total',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormatter.format(totalValue),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Gráfico de barras
                  if (transactions.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gastos por Dia em $monthName',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            height: 200.h,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxValue(transactions),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final value = rod.toY;
                                      return BarTooltipItem(
                                        currencyFormatter.format(value),
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: DefaultColors.grey,
                                            fontSize: 12.sp,
                                          ),
                                        );
                                      },
                                      reservedSize: 30.h,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0)
                                          return const SizedBox.shrink();
                                        return Text(
                                          'R\$${(value / 1000).toStringAsFixed(0)}k',
                                          style: TextStyle(
                                            color: DefaultColors.grey,
                                            fontSize: 10.sp,
                                          ),
                                        );
                                      },
                                      reservedSize: 40.w,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups: _getBarGroups(transactions),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                  horizontalInterval:
                                      _getMaxValue(transactions) / 5,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color:
                                          DefaultColors.grey20.withOpacity(0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Lista de transações
                  Text(
                    'Transações em $monthName',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: DefaultColors.grey20,
                    ),
                  ),

                  if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Text(
                          "Nenhuma transação encontrada",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => Divider(
                      // ignore: deprecated_member_use
                      color: DefaultColors.grey20.withOpacity(.5),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      var transactionValue = double.parse(
                        transaction.value
                            .replaceAll('.', '')
                            .replaceAll(',', '.'),
                      );

                      String formattedDate = transaction.paymentDay != null
                          ? dateFormatter.format(
                              DateTime.parse(transaction.paymentDay!),
                            )
                          : "Data não informada";

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 180.w,
                                    child: Text(
                                      transaction.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Get.theme.primaryColor,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: DefaultColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(transactionValue),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Get.theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  transaction.paymentType ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];
          return transactionMonthName == monthName;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  // Agrupa as transações por dia e soma os valores
  Map<int, double> _groupTransactionsByDay(
      List<TransactionModel> transactions) {
    Map<int, double> dailyTotals = {};

    for (var transaction in transactions) {
      if (transaction.paymentDay != null) {
        DateTime date = DateTime.parse(transaction.paymentDay!);
        int day = date.day;
        double value = double.parse(
          transaction.value.replaceAll('.', '').replaceAll(',', '.'),
        );

        dailyTotals[day] = (dailyTotals[day] ?? 0) + value;
      }
    }

    return dailyTotals;
  }

  // Cria os grupos de barras para o gráfico
  List<BarChartGroupData> _getBarGroups(List<TransactionModel> transactions) {
    Map<int, double> dailyTotals = _groupTransactionsByDay(transactions);

    return dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: categoryColor,
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x)); // Ordena por dia
  }

  // Calcula o valor máximo para o eixo Y
  double _getMaxValue(List<TransactionModel> transactions) {
    Map<int, double> dailyTotals = _groupTransactionsByDay(transactions);
    if (dailyTotals.isEmpty) return 100;

    double maxValue = dailyTotals.values.reduce((a, b) => a > b ? a : b);
    // Adiciona uma margem de 20% ao valor máximo
    return maxValue * 1.2;
  }
}
