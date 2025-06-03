// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          FinanceSummaryCard(),
          SportAnalysisChart(),
        ],
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
  final double savedAmount = -284.54;
  final double savedChange = -0.05;

  final double spentAmount = -284.54;
  final double spentChange = 0.039;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard(
          title: 'Saved',
          amount: savedAmount,
          change: savedChange,
          subtitle: 'Economies from this account',
          changeColor: Colors.red,
          changeIcon: Iconsax.trend_down,
        ),
        _buildCard(
          title: 'Spent',
          amount: spentAmount,
          change: spentChange,
          subtitle: 'Expenses in this account',
          changeColor: Colors.green,
          changeIcon: Iconsax.trend_up,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required double amount,
    required double change,
    required String subtitle,
    required Color changeColor,
    required IconData changeIcon,
  }) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              )),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                '-\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 6),
              Row(
                children: [
                  Text(
                    '${(change.abs() * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    changeIcon,
                    size: 16,
                    color: changeColor,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
