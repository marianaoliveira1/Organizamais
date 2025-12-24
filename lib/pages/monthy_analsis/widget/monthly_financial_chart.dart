import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
// import '../../graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/widgetes/info_card.dart';
import 'chart_legend_item.dart';

class MonthlyFinancialChart extends StatelessWidget {
  final int selectedYear;

  const MonthlyFinancialChart({super.key, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    double sf(double mobile, double tablet) => isTablet ? tablet : mobile;

    return Obx(() {
      final monthlyData =
          _calculateMonthlyData(controller.transaction, selectedYear);

      return InfoCard(
        title: 'Receitas vs Despesas Mensais',
        onTap: () {},
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ano $selectedYear (até hoje)',
              style: TextStyle(
                fontSize: sf(12, 14),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChartLegendItem(label: 'Receitas', color: DefaultColors.green),
                SizedBox(width: 20.w),
                ChartLegendItem(label: 'Despesas', color: DefaultColors.red),
              ],
            ),
            SizedBox(height: 14.h),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal dimensions based on available width
                final double availableWidth = constraints.maxWidth;
                final int groupCount = 12; // number of months
                final int barsPerGroup = 2; // receitas and despesas

                // Define minimum spacing requirements
                final double minGroupSpacing =
                    48.0; // Significantly increased for more space between months
                final double minBarSpacing =
                    0.0; // No space between bars in same month
                final double minBarWidth = 8.0;

                // Calculate maximum possible bar width while maintaining minimum spacing
                double totalSpacingWidth = (groupCount - 1) * minGroupSpacing +
                    (groupCount * (barsPerGroup - 1)) * minBarSpacing;
                double maxPossibleBarWidth =
                    (availableWidth - totalSpacingWidth) /
                        (groupCount * barsPerGroup);

                // Clamp bar width between minimum and maximum values
                double barWidth = maxPossibleBarWidth.clamp(minBarWidth,
                    10.0); // Reduced max width to allow more spacing

                // Recalculate actual spacing based on final bar width
                double totalBarsWidth = barWidth * groupCount * barsPerGroup;
                double remainingSpace = availableWidth - totalBarsWidth;

                // Distribute remaining space between groups
                double groupSpacing = remainingSpace / (groupCount - 1);

                // If groupSpacing is too large, cap it and center the chart
                if (groupSpacing > 64.0) {
                  // Increased significantly
                  groupSpacing = 64.0;
                }

                // Compute nice Y-axis ticks to avoid duplicate rounded labels
                final double maxVal = _getMaxValue(monthlyData);
                final double step = _niceInterval(maxVal);
                final double niceMaxY = ((maxVal / step).ceil()) * step;

                return SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      maxY: niceMaxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              Colors.blueGrey.withOpacity(0.8),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final month = _getMonthName(group.x.toInt());
                            final value = rod.toY;
                            final type =
                                rodIndex == 0 ? 'Receitas' : 'Despesas';
                            return BarTooltipItem(
                              '$month\n$type: ${_formatCurrency(value)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      backgroundColor: theme.cardColor,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        checkToShowVerticalLine: (value) => true,
                        verticalInterval: 1,
                        getDrawingVerticalLine: (value) {
                          final isEven = value.toInt().isEven;
                          return FlLine(
                            color: isEven
                                ? Colors.grey.withOpacity(0.15)
                                : Colors.white,
                            strokeWidth: groupSpacing,
                          );
                        },
                        horizontalInterval: step,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        checkToShowHorizontalLine: (value) => true,
                      ),
                      extraLinesData: ExtraLinesData(
                        verticalLines: [],
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
                              return Text(
                                _getMonthAbbr(value.toInt()),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: sf(11, 13),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              );
                            },
                            interval: 1,
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: step,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatCurrencyShort(value),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: sf(11, 13),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups:
                          _createBarGroups(monthlyData, barWidth: barWidth),
                      groupsSpace: groupSpacing,
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

  Map<int, Map<String, double>> _calculateMonthlyData(
      List<TransactionModel> transactions, int year) {
    final currentDate = DateTime.now();
    final monthlyData = <int, Map<String, double>>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = {'receitas': 0.0, 'despesas': 0.0};
    }

    // Calcular totais por mês
    for (final transaction in transactions) {
      if (transaction.paymentDay != null) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        // Se o ano selecionado for o ano atual, filtrar apenas até hoje
        // Se for um ano passado, mostrar todos os meses
        final bool shouldInclude = year == DateTime.now().year
            ? paymentDate.year == year && paymentDate.isBefore(currentDate)
            : paymentDate.year == year;

        if (shouldInclude) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );

          if (transaction.type == TransactionType.receita) {
            monthlyData[month]!['receitas'] =
                monthlyData[month]!['receitas']! + value;
          } else if (transaction.type == TransactionType.despesa) {
            monthlyData[month]!['despesas'] =
                monthlyData[month]!['despesas']! + value;
          }
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(
      Map<int, Map<String, double>> monthlyData,
      {required double barWidth}) {
    return monthlyData.entries.map((entry) {
      final month = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: data['receitas']!,
            color: DefaultColors.green,
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barWidth * 0.25),
              topRight: Radius.circular(barWidth * 0.25),
            ),
          ),
          BarChartRodData(
            toY: data['despesas']!,
            color: DefaultColors.red,
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barWidth * 0.25),
              topRight: Radius.circular(barWidth * 0.25),
            ),
          ),
        ],
        barsSpace: 0, // No space between bars in same month
      );
    }).toList();
  }

  double _getMaxValue(Map<int, Map<String, double>> monthlyData) {
    double maxValue = 0;
    for (final data in monthlyData.values) {
      final maxMonth = [data['receitas']!, data['despesas']!]
          .reduce((a, b) => a > b ? a : b);
      if (maxMonth > maxValue) {
        maxValue = maxMonth;
      }
    }
    return maxValue == 0 ? 1000 : maxValue;
  }

  // Compute "nice" axis interval such as 250, 500, 1000, 2000, etc.
  double _niceInterval(double maxVal) {
    if (maxVal <= 0) return 250;
    // Target ~4 horizontal lines
    final double rough = maxVal / 4.0;
    final int exp = (math.log(rough) / math.log(10)).floor();
    final double pow10 = math.pow(10, exp).toDouble();
    final List<double> niceSteps = <double>[1, 2, 2.5, 5, 10];
    for (final double s in niceSteps) {
      final double candidate = s * pow10;
      if (rough <= candidate) return candidate;
    }
    return 10 * pow10;
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
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
