import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:organizamais/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/auth_controller.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/transaction_page.dart';

import '../../graphics/widgtes/default_text_graphic.dart';

class CategoryMonthlyChart extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryMonthlyChart({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryMonthlyChart> createState() => _CategoryMonthlyChartState();
}

enum _ChartMode { bar, line }

class _CategoryMonthlyChartState extends State<CategoryMonthlyChart> {
  _ChartMode _chartMode = _ChartMode.bar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final monthlyData = _calculateMonthlyData(controller.transaction);
      final user = Get.find<AuthController>().firebaseUser.value;
      final String? uid = user?.uid;

      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
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
                SizedBox(height: 4.h),
                Text(
                  'Ano ${DateTime.now().year} (até hoje)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DefaultColors.grey,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: widget.categoryColor,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Gasto',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: DefaultColors.grey,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Meta',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    final int monthCount = 12;
                    final double minBarWidth = 8.0;
                    final double minBarSpacing = 8.0;

                    double barWidth =
                        ((availableWidth - (monthCount - 1) * minBarSpacing) /
                                monthCount)
                            .clamp(minBarWidth, 24.0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Orçamento do usuário para esta categoria
                        if (uid != null)
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('categoryBudgets')
                                .doc(widget.categoryId.toString())
                                .snapshots(),
                            builder: (context, budgetSnap) {
                              // Apenas força rebuild quando o budget mudar
                              return const SizedBox.shrink();
                            },
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _ChartModeButton(
                              icon: Iconsax.chart_2,
                              selected: _chartMode == _ChartMode.bar,
                              onPressed: () {
                                if (_chartMode != _ChartMode.bar) {
                                  setState(() => _chartMode = _ChartMode.bar);
                                }
                              },
                            ),
                            SizedBox(width: 8.w),
                            _ChartModeButton(
                              icon: Iconsax.activity,
                              selected: _chartMode == _ChartMode.line,
                              onPressed: () {
                                if (_chartMode != _ChartMode.line) {
                                  setState(() => _chartMode = _ChartMode.line);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: uid == null
                                ? const Stream.empty()
                                : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .collection('categoryBudgets')
                                    .doc(widget.categoryId.toString())
                                    .snapshots(),
                            builder: (context, budgetSnap) {
                              final double budget =
                                  (budgetSnap.data?.data()?['amount'] as num?)
                                          ?.toDouble() ??
                                      0.0;
                              final bool hasBudget = budget > 0;
                              return _chartMode == _ChartMode.bar
                                  ? BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.center,
                                        groupsSpace: hasBudget ? 6 : 12,
                                        maxY: _getOptimalMaxY(monthlyData),
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor: (group) => Colors
                                                .blueGrey
                                                .withOpacity(0.8),
                                            tooltipRoundedRadius: 8,
                                            getTooltipItem: (group, groupIndex,
                                                rod, rodIndex) {
                                              final month = _getMonthName(
                                                  group.x.toInt());
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
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                final String label =
                                                    _getMonthAbbr(
                                                        value.toInt());
                                                if (hasBudget) {
                                                  return SizedBox(
                                                    width: 28.w,
                                                    child: Text(
                                                      label,
                                                      style: TextStyle(
                                                        color:
                                                            DefaultColors.grey,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                } else {
                                                  return Transform.rotate(
                                                    angle: -0.5,
                                                    child: SizedBox(
                                                      width: barWidth * 3,
                                                      child: Text(
                                                        label,
                                                        style: TextStyle(
                                                          color: DefaultColors
                                                              .grey,
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              reservedSize: hasBudget ? 32 : 45,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 45.w,
                                              interval: _getOptimalInterval(
                                                  _getMaxValue(monthlyData)),
                                              getTitlesWidget: (value, meta) {
                                                if (value < 0)
                                                  return const SizedBox
                                                      .shrink();
                                                return Text(
                                                  _formatCurrencyShort(value),
                                                  style: TextStyle(
                                                    color: DefaultColors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8.sp,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: _createBarGroups(monthlyData,
                                            barWidth: barWidth, budget: budget),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval:
                                              _getOptimalInterval(
                                                  _getMaxValue(monthlyData)),
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: DefaultColors.grey
                                                  .withOpacity(0.2),
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : LineChart(
                                      LineChartData(
                                        minX: 1,
                                        maxX: 12,
                                        maxY: _getOptimalMaxY(monthlyData),
                                        lineTouchData: LineTouchData(
                                          enabled: true,
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            tooltipRoundedRadius: 8,
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((spot) {
                                                final month = _getMonthName(
                                                    spot.x.toInt());
                                                return LineTooltipItem(
                                                  '$month\n${_formatCurrency(spot.y)}',
                                                  TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  child: SizedBox(
                                                    width: 24.w * 3,
                                                    child: Text(
                                                      _getMonthAbbr(
                                                          value.toInt()),
                                                      style: TextStyle(
                                                        color:
                                                            DefaultColors.grey,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                                              reservedSize: 45.w,
                                              interval: _getOptimalInterval(
                                                  _getMaxValue(monthlyData)),
                                              getTitlesWidget: (value, meta) {
                                                if (value < 0)
                                                  return const SizedBox
                                                      .shrink();
                                                return Text(
                                                  _formatCurrencyShort(value),
                                                  style: TextStyle(
                                                    color: DefaultColors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8.sp,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval:
                                              _getOptimalInterval(
                                                  _getMaxValue(monthlyData)),
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: DefaultColors.grey
                                                  .withOpacity(0.2),
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: List.generate(12, (i) {
                                              final month = i + 1;
                                              final y = monthlyData[month] ?? 0;
                                              return FlSpot(
                                                  month.toDouble(), y);
                                            }),
                                            isCurved: true,
                                            color: widget.categoryColor,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: widget.categoryColor
                                                  .withOpacity(0.10),
                                            ),
                                          ),
                                          if (budget > 0)
                                            LineChartBarData(
                                              spots: List.generate(12, (i) {
                                                final month = i + 1;
                                                final hasTxn =
                                                    (monthlyData[month] ?? 0) >
                                                        0;
                                                if (!hasTxn) return null;
                                                return FlSpot(
                                                    month.toDouble(), budget);
                                              }).whereType<FlSpot>().toList(),
                                              isCurved: false,
                                              color: DefaultColors.grey,
                                              barWidth: 2,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: false),
                                            ),
                                        ],
                                      ),
                                    );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Análise Mensal (com meta)
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: uid == null
                ? const Stream.empty()
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('categoryBudgets')
                    .doc(widget.categoryId.toString())
                    .snapshots(),
            builder: (context, snap) {
              final double budget =
                  (snap.data?.data()?['amount'] as num?)?.toDouble() ?? 0.0;
              final analysis = _generateMonthlyAnalysis(monthlyData, budget);
              if (analysis.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextGraphic(
                      text: "Análise Mensal",
                    ),
                    SizedBox(height: 16.h),
                    ...analysis.map((item) => _buildAnalysisItem(item, theme)),
                  ],
                ),
              );
            },
          ),
          AdsBanner(),
          SizedBox(
            height: 20.h,
          ),
          // Dicas Personalizadas
          // Container(
          //   padding: EdgeInsets.all(16.w),
          //   margin: EdgeInsets.only(bottom: 24.h),
          //   decoration: BoxDecoration(
          //     color: theme.cardColor,
          //     borderRadius: BorderRadius.circular(12.r),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       DefaultTextGraphic(
          //         text: "💡 Dicas Inteligentes",
          //       ),
          //       SizedBox(height: 16.h),
          //       ..._getCategoryTips(categoryName, monthlyData, theme),
          //     ],
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _buildAnalysisItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: item['cardColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: item['cardColor'].withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            item['icon'],
            color: item['cardColor'],
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['month'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['analysis'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: DefaultColors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['message'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: item['cardColor'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMonthlyAnalysis(
      Map<int, double> monthlyData,
      [double budget = 0.0]) {
    List<Map<String, dynamic>> analysis = [];
    final currentMonth = DateTime.now().month;

    for (int month = 2; month <= currentMonth; month++) {
      double currentValue = monthlyData[month] ?? 0;
      double previousValue = monthlyData[month - 1] ?? 0;
      double difference = currentValue - previousValue;
      double absoluteDifference = difference.abs();

      if (currentValue > 0 || previousValue > 0) {
        double percentChange = 0;
        if (previousValue > 0) {
          percentChange = (difference / previousValue) * 100;
        } else if (currentValue > 0) {
          percentChange = 100; // Primeira despesa na categoria
        }

        Color cardColor;
        IconData icon;
        String message;

        if (percentChange > 15) {
          cardColor = Colors.red;
          icon = Iconsax.arrow_circle_up;
          message = "Alerta: aumento expressivo!";
        } else if (percentChange >= 5 && percentChange <= 15) {
          cardColor = Colors.orange;
          icon = Iconsax.arrow_circle_up;
          message = "Aumento moderado";
        } else if (percentChange >= -5 && percentChange <= 5) {
          cardColor = Colors.grey;
          icon = Iconsax.arrow_right_2;
          message = "Estável";
        } else if (percentChange >= -15 && percentChange <= -5) {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          message = "Boa redução!";
        } else {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          message = "Economia significativa!";
        }

        String valueText = difference >= 0
            ? 'Aumentou ${_formatCurrency(absoluteDifference)}'
            : 'Diminuiu ${_formatCurrency(absoluteDifference)}';

        String budgetLine = '';
        if (budget > 0) {
          final double remaining = budget - currentValue;
          if (remaining >= 0) {
            budgetLine =
                ' Sua meta mensal foi R\$ ${_formatCurrency(budget)} e faltou R\$ ${_formatCurrency(remaining)} para atingir.';
          } else {
            budgetLine =
                ' Você ultrapassou R\$ ${_formatCurrency(remaining.abs())} da meta de orçamento.';
          }
        }

        analysis.add({
          'month': _getMonthName(month),
          'analysis':
              '$valueText (${percentChange.toStringAsFixed(1)}%)$budgetLine',
          'percentChange': percentChange,
          'isPositive': difference > 0,
          'currentValue': currentValue,
          'previousValue': previousValue,
          'cardColor': cardColor,
          'icon': icon,
          'message': message,
        });
      }
    }

    return analysis;
  }

  // _getCategoryTips removido (não utilizado)

  // _buildTipItem removido

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
          transaction.category == widget.categoryId &&
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

  List<BarChartGroupData> _createBarGroups(Map<int, double> monthlyData,
      {required double barWidth, double budget = 0.0}) {
    return monthlyData.entries.map((entry) {
      final double primaryWidth = (barWidth * 0.5).clamp(5.0, 16.0);
      final double budgetWidth = (barWidth * 0.5).clamp(5.0, 16.0);
      return BarChartGroupData(
        x: entry.key,
        barsSpace: 2,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: widget.categoryColor,
            width: primaryWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barWidth * 0.25),
              topRight: Radius.circular(barWidth * 0.25),
            ),
          ),
          if ((entry.value) > 0 && budget > 0)
            BarChartRodData(
              toY: budget,
              color: DefaultColors.grey,
              width: budgetWidth,
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
    double maxValue =
        monthlyData.values.fold(0, (max, value) => value > max ? value : max);
    return maxValue == 0 ? 1000 : maxValue;
  }

  double _getOptimalInterval(double maxValue) {
    if (maxValue <= 0) return 100;

    // Calcular um intervalo que resulte em aproximadamente 4-6 divisões
    double rawInterval = maxValue / 5;

    // Arredondar para um valor "limpo"
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 25) return 25;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 250) return 250;
    if (rawInterval <= 500) return 500;
    if (rawInterval <= 1000) return 1000;
    if (rawInterval <= 2500) return 2500;
    if (rawInterval <= 5000) return 5000;

    // Para valores maiores, usar potências de 10
    double magnitude = 1;
    while (rawInterval > magnitude * 10) {
      magnitude *= 10;
    }

    if (rawInterval <= magnitude * 2.5) return magnitude * 2.5;
    if (rawInterval <= magnitude * 5) return magnitude * 5;
    return magnitude * 10;
  }

  double _getOptimalMaxY(Map<int, double> monthlyData) {
    double maxValue = _getMaxValue(monthlyData);
    double interval = _getOptimalInterval(maxValue);

    // Calcula o próximo múltiplo do intervalo que seja maior que o valor máximo
    double optimalMaxY = (maxValue / interval).ceil() * interval;

    // Garante que temos pelo menos uma divisão acima do valor máximo
    if (optimalMaxY <= maxValue) {
      optimalMaxY += interval;
    }

    return optimalMaxY;
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
    if (value == 0) return 'R\$ 0';

    if (value >= 1000000) {
      double millions = value / 1000000;
      if (millions == millions.roundToDouble()) {
        return 'R\$ ${millions.toStringAsFixed(0)}M';
      } else {
        return 'R\$ ${millions.toStringAsFixed(1)}M';
      }
    } else if (value >= 1000) {
      double thousands = value / 1000;
      if (thousands == thousands.roundToDouble()) {
        return 'R\$ ${thousands.toStringAsFixed(0)}k';
      } else {
        return 'R\$ ${thousands.toStringAsFixed(1)}k';
      }
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }
}

class _ChartModeButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _ChartModeButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          // color:
          //     selected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : DefaultColors.grey20.withOpacity(.4),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: selected ? theme.primaryColor : DefaultColors.grey,
        ),
      ),
    );
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
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
          "Analise de $categoryName",
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(height: 5.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo da categoria
                  CategorySummaryAnalysisPage(
                    theme: theme,
                    categoryName: categoryName,
                    currencyFormatter: currencyFormatter,
                    totalValue: totalValue,
                    percentual: percentual,
                    categoryColor: categoryColor,
                  ),
                  SizedBox(height: 24.h),

                  // Card com média mensal
                  _buildMonthlyAverageCard(context, theme),
                  SizedBox(height: 24.h),
                  AdsBanner(),
                  SizedBox(height: 24.h),

                  // Gráfico mensal da categoria
                  CategoryMonthlyChart(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    categoryColor: categoryColor,
                  ),

                  // Lista de transações
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

                            String formattedDate =
                                transaction.paymentDay != null
                                    ? dateFormatter.format(
                                        DateTime.parse(transaction.paymentDay!),
                                      )
                                    : "Data não informada";

                            return InkWell(
                              onTap: () => Get.to(
                                () => TransactionPage(
                                  transaction: transaction,
                                  overrideTransactionSalvar:
                                      (updatedTransaction) {
                                    final controller =
                                        Get.find<TransactionController>();
                                    controller
                                        .updateTransaction(updatedTransaction);
                                  },
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150.w,
                                          child: Text(
                                            transaction.title,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Get.theme.primaryColor,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          currencyFormatter
                                              .format(transactionValue),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Get.theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: DefaultColors.grey20,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110.w,
                                          child: Text(
                                            transaction.paymentType ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: DefaultColors.grey20,
                                            ),
                                            textAlign: TextAlign.end,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyAverageCard(BuildContext context, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Calcular dados mensais para a categoria
    final monthlyData =
        _calculateMonthlyDataForCategory(transactionController.transaction);

    // Calcular média mensal
    final activeMonths =
        monthlyData.values.where((value) => value > 0).toList();
    final monthlyAverage = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a + b) / activeMonths.length
        : 0.0;

    // Calcular maior e menor gasto
    final maxSpending = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final minSpending = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a < b ? a : b)
        : 0.0;

    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Análise da Categoria',
          //   style: TextStyle(
          //     fontSize: 10.sp,
          //     fontWeight: FontWeight.w500,
          //     color: DefaultColors.grey20,
          //   ),
          // ),
          // SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média Mensal',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(monthlyAverage),
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor.withOpacity(.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menor Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(minSpending),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maior Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(maxSpending),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Meses Ativos',
              //         style: TextStyle(
              //           fontSize: 12.sp,
              //           fontWeight: FontWeight.w500,
              //           color: DefaultColors.grey20,
              //         ),
              //       ),
              //       SizedBox(height: 4.h),
              //       Text(
              //         '${activeMonths.length} de ${DateTime.now().month}',
              //         style: TextStyle(
              //           fontSize: 14.sp,
              //           fontWeight: FontWeight.bold,
              //           color: Get.theme.primaryColor,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyDataForCategory(
      List<TransactionModel> transactions) {
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

  List<TransactionModel> _getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final DateTime today = DateTime.now();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        final int currentYear = DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;

          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];

          return transactionMonthName == monthName &&
              transactionDate.year == currentYear &&
              transactionDate.isBefore(today.add(Duration(days: 1)));
        }).toList();
      }

      return despesas.where((transaction) {
        if (transaction.paymentDay == null) return false;
        DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
        return transactionDate.isBefore(today.add(Duration(days: 1)));
      }).toList();
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  List<String> getAllMonths() {
    return [
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
  }
}

class CategorySummaryAnalysisPage extends StatelessWidget {
  const CategorySummaryAnalysisPage({
    super.key,
    required this.theme,
    required this.categoryName,
    required this.currencyFormatter,
    required this.totalValue,
    required this.percentual,
    required this.categoryColor,
  });

  final ThemeData theme;
  final String categoryName;
  final NumberFormat currencyFormatter;
  final double totalValue;
  final double percentual;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey20,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: 'No ano de 2025, você gastou ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: currencyFormatter.format(totalValue),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: ' na categoria ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: categoryName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: ', que representa ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: '${percentual.toStringAsFixed(1)}% ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: 'do valor total.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              // Tamanho responsivo para o donut dentro de uma linha com textos à direita
              final double donutSize = maxWidth.isFinite
                  ? (maxWidth * 0.096).clamp(50.0, 100.0)
                  : 80.0;
              final double donutStroke = (donutSize * 0.10).clamp(4.0, 10.0);

              return Center(
                child: _CategoryDonutPercent(
                  percent: percentual,
                  color: categoryColor,
                  size: donutSize,
                  strokeWidth: donutStroke,
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _CategoryDonutPercent extends StatelessWidget {
  final double percent; // 0..100
  final Color color;
  final double size;
  final double strokeWidth;

  const _CategoryDonutPercent({
    required this.percent,
    required this.color,
    this.size = 54,
    this.strokeWidth = 7,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double clamped = percent.clamp(0, 100);

    final double outerRadius = (size / 2).w;
    final double centerRadius = ((size / 2) - strokeWidth).clamp(0, size / 2).w;

    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: centerRadius,
              sections: [
                PieChartSectionData(
                  value: clamped <= 0 ? 0.0001 : clamped,
                  color: color,
                  showTitle: false,
                  radius: outerRadius,
                ),
                PieChartSectionData(
                  value: (100 - clamped) <= 0 ? 0.0001 : (100 - clamped),
                  color: DefaultColors.greyLight,
                  showTitle: false,
                  radius: outerRadius,
                ),
              ],
            ),
          ),
          Text(
            '${clamped.toStringAsFixed(1).replaceAll('.', ',')}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
