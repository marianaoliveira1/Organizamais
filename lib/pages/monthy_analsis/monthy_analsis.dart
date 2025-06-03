// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.h,
            ),
            child: Column(
              children: [
                AnnualSummaryCards(),
                SizedBox(
                  height: 50.h,
                ),
                SportAnalysisChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SportAnalysisChart extends StatelessWidget {
  final List<double> monthlyExpenses = [
    100,
    284.54,
    200,
    150,
    240,
    80,
    60,
    130
  ];

  SportAnalysisChart({super.key});

  @override
  Widget build(BuildContext context) {
    final maxValue = monthlyExpenses.reduce((a, b) => a > b ? a : b);
    final maxIndex = monthlyExpenses.indexOf(maxValue);

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug'
                    ];
                    if (value < 0 || value >= months.length) return SizedBox();
                    return Text(
                      months[value.toInt()],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            barGroups: List.generate(monthlyExpenses.length, (index) {
              final isMax = index == maxIndex;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: monthlyExpenses[index],
                    color: isMax ? Colors.red : Colors.pink[200],
                    borderRadius: BorderRadius.circular(8),
                    width: 16,
                    rodStackItems: [],
                    backDrawRodData: BackgroundBarChartRodData(show: false),
                  ),
                ],
                showingTooltipIndicators: isMax ? [0] : [],
              );
            }),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '-\$${rod.toY.toStringAsFixed(2)}',
                    TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        FinanceCard(
          title: 'Receita',
          amount: -00,
        ),
        FinanceCard(
          title: 'Despesas',
          amount: -284.54,
        ),
      ],
    );
  }
}

class FinanceCard extends StatelessWidget {
  final String title;
  final double amount;

  const FinanceCard({
    super.key,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: DefaultColors.grey20,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '00',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnualSummaryCards extends StatelessWidget {
  final controller = Get.find<TransactionController>();
  final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

  AnnualSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final receita = controller.totalReceitaAno;
      final despesa = controller.totalDespesasAno;

      return Column(
        children: [
          _buildCard(
            title: 'Receita Anual',
            value: currencyFormat.format(receita),
            color: Colors.green.shade100,
            textColor: Colors.green.shade900,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Despesa Anual',
            value: currencyFormat.format(despesa),
            color: Colors.red.shade100,
            textColor: Colors.red.shade900,
            icon: Icons.trending_down,
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16)),
                Text(value,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
