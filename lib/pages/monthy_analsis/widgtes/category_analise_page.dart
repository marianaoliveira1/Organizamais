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
import '../../graphics/widgtes/default_text_graphic.dart';

class CategoryMonthlyChart extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryMonthlyChart({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final monthlyData = _calculateMonthlyData(controller.transaction);

      return Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextGraphic(
              text: "Evolução Mensal da Categoria",
            ),
            SizedBox(height: 8.h),
            Text(
              'Ano ${DateTime.now().year} (até hoje)',
              style: TextStyle(
                fontSize: 14.sp,
                color: DefaultColors.grey,
              ),
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final int monthCount = 12;
                final double minBarWidth = 8.0;
                final double minBarSpacing = 8.0;

                double barWidth = ((availableWidth - (monthCount - 1) * minBarSpacing) / monthCount)
                    .clamp(minBarWidth, 24.0);

                return SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      maxY: _getMaxValue(monthlyData) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              Colors.blueGrey.withOpacity(0.8),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final month = _getMonthName(group.x.toInt());
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$month\n${_formatCurrency(value)}',
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
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Transform.rotate(
                                angle: -0.5,
                                child: SizedBox(
                                  width: barWidth * 3,
                                  child: Text(
                                    _getMonthAbbr(value.toInt()),
                                    style: TextStyle(
                                      color: DefaultColors.grey,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 45,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: _getMaxValue(monthlyData) / 4,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatCurrencyShort(value),
                                style: TextStyle(
                                  color: DefaultColors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _createBarGroups(monthlyData, barWidth: barWidth),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxValue(monthlyData) / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: DefaultColors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Map<int, double> _calculateMonthlyData(List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, double>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    // Calcular totais por mês para a categoria específica
    for (final transaction in transactions) {
      if (transaction.paymentDay != null && 
          transaction.category == categoryId &&
          transaction.type == TransactionType.despesa) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(
      Map<int, double> monthlyData, {required double barWidth}) {
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: categoryColor,
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barWidth * 0.25),
              topRight: Radius.circular(barWidth * 0.25),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxValue(Map<int, double> monthlyData) {
    double maxValue = monthlyData.values.fold(0, (max, value) => value > max ? value : max);
    return maxValue == 0 ? 1000 : maxValue;
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }
}

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
          SizedBox(height: 20.h),
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
                  
                  // Gráfico mensal da categoria
                  CategoryMonthlyChart(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    categoryColor: categoryColor,
                  ),
                  
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
}
