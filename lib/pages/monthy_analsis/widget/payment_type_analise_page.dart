import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';

class PaymentTypeAnalysisPage extends StatelessWidget {
  final String paymentType;
  final Color paymentColor;
  final double totalValue; // anual total for this type
  final double percentual; // percentual of total expenses

  const PaymentTypeAnalysisPage({
    super.key,
    required this.paymentType,
    required this.paymentColor,
    required this.totalValue,
    required this.percentual,
  });

  Widget _buildPercentBar(double percent, Color color, ThemeData theme) {
    final double clamped = percent.clamp(0, 100);
    final double widthFactor = clamped / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12.h,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '${clamped.toStringAsFixed(1).replaceAll('.', ',')}%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(List<TransactionModel> transactions,
      ThemeData theme, NumberFormat currencyFormatter) {
    // Estatísticas por mês (soma mensal), não por transação individual
    final int currentYear = DateTime.now().year;
    final Map<int, double> monthSum = {for (int m = 1; m <= 12; m++) m: 0.0};
    final Set<int> monthsWithData = {};
    for (final t in transactions) {
      if (t.paymentDay == null) continue;
      final dt = DateTime.parse(t.paymentDay!);
      if (dt.year != currentYear) continue;
      final double v =
          double.tryParse(t.value.replaceAll('.', '').replaceAll(',', '.')) ??
              0.0;
      monthSum[dt.month] = (monthSum[dt.month] ?? 0.0) + v;
      monthsWithData.add(dt.month);
    }

    final List<double> values =
        monthsWithData.map((m) => monthSum[m] ?? 0.0).toList();
    double minV = 0.0;
    double maxV = 0.0;
    double avg = 0.0;
    if (values.isNotEmpty) {
      minV = values.reduce((a, b) => a < b ? a : b);
      maxV = values.reduce((a, b) => a > b ? a : b);
      avg = values.reduce((a, b) => a + b) / values.length;
    }

    return Column(
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
          currencyFormatter.format(avg),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menor Gasto',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: DefaultColors.grey20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currencyFormatter.format(minV),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DefaultColors.green,
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
                      fontSize: 11.sp,
                      color: DefaultColors.grey20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currencyFormatter.format(maxV),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DefaultColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    final TransactionController controller = Get.find<TransactionController>();

    // Filter transactions by this payment type (expenses only), current year
    final List<TransactionModel> all = controller.transaction
        .where((t) => t.type == TransactionType.despesa)
        .toList();
    final int currentYear = DateTime.now().year;

    List<TransactionModel> transactions = all.where((t) {
      if (t.paymentType == null || t.paymentDay == null) return false;
      final String pt = t.paymentType!.trim().toLowerCase();
      final String selected = paymentType.trim().toLowerCase();
      final DateTime dt = DateTime.parse(t.paymentDay!);
      return pt == selected &&
          dt.year == currentYear &&
          dt.isBefore(DateTime.now());
    }).toList();

    // Sort by date desc
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    // Build monthly aggregated data for chart
    final Map<int, double> monthlyData = _calculateMonthlyData(transactions);
    final List<Map<String, dynamic>> analysis =
        _generateMonthlyAnalysis(monthlyData);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          paymentType,
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
                  // Summary
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
                          'Resumo Anual',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: DefaultColors.grey20,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              width: 16.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: paymentColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                paymentType,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(totalValue),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Representa ${percentual.toStringAsFixed(1)}% do total anual',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // progress percent bar instead of donut
                        _buildPercentBar(percentual, paymentColor, theme),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  AdsBanner(),
                  SizedBox(height: 24.h),
                  // Monthly summary stats (Avg / Min / Max)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _buildMonthlyStats(
                        transactions, theme, currencyFormatter),
                  ),
                  SizedBox(height: 24.h),
                  AdsBanner(),
                  SizedBox(height: 24.h),
                  // Monthly chart
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
                          'Evolução Mensal ($currentYear)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: DefaultColors.grey20,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Progress bar: this payment type over the year

                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 220.h,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.center,
                              maxY: _getOptimalMaxY(monthlyData),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) =>
                                      Colors.blueGrey.withOpacity(0.8),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final month =
                                        _getMonthName(group.x.toInt());
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
                                          width: 24.w * 3,
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
                                    reservedSize: 45.w,
                                    interval: _getOptimalInterval(
                                        _getMaxValue(monthlyData)),
                                    getTitlesWidget: (value, meta) {
                                      if (value < 0) {
                                        return const SizedBox.shrink();
                                      }
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
                              barGroups:
                                  _createBarGroups(monthlyData, barWidth: 14.w),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: _getOptimalInterval(
                                    _getMaxValue(monthlyData)),
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: DefaultColors.grey.withOpacity(0.2),
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
                  SizedBox(height: 20.h),
                  AdsBanner(),

                  if (analysis.isNotEmpty) ...[
                    SizedBox(height: 24.h),
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
                            'Análise Mensal',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: DefaultColors.grey20,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ...analysis
                              .map((item) => _buildAnalysisItem(item, theme)),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),

                  AdsBanner(),
                  SizedBox(height: 20.h),

                  // Transactions list
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
                          'Transações - $paymentType',
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
                                'Nenhuma transação encontrada',
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
                            final t = transactions[index];
                            final double value = double.parse(
                              t.value.replaceAll('.', '').replaceAll(',', '.'),
                            );
                            final String formattedDate = t.paymentDay != null
                                ? dateFormatter
                                    .format(DateTime.parse(t.paymentDay!))
                                : 'Data não informada';

                            return Padding(
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
                                          t.title,
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
                                        currencyFormatter.format(value),
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
                                          t.paymentType ?? 'N/A',
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
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                  AdsBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyData(List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, double>{};

    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    for (final t in transactions) {
      if (t.paymentDay != null) {
        final paymentDate = DateTime.parse(t.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            t.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(Map<int, double> monthlyData,
      {required double barWidth}) {
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: paymentColor,
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
    double maxValue =
        monthlyData.values.fold(0, (max, value) => value > max ? value : max);
    return maxValue == 0 ? 1000 : maxValue;
  }

  double _getOptimalInterval(double maxValue) {
    if (maxValue <= 0) return 100;
    double rawInterval = maxValue / 5;
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 25) return 25;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 250) return 250;
    if (rawInterval <= 500) return 500;
    if (rawInterval <= 1000) return 1000;
    if (rawInterval <= 2500) return 2500;
    if (rawInterval <= 5000) return 5000;
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
    double optimalMaxY = (maxValue / interval).ceil() * interval;
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
    final NumberFormat nf =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return nf.format(value);
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

  List<Map<String, dynamic>> _generateMonthlyAnalysis(
      Map<int, double> monthlyData) {
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
          percentChange = 100;
        }

        Color cardColor;
        IconData icon;
        String message;

        if (percentChange > 15) {
          cardColor = Colors.red;
          icon = Iconsax.arrow_circle_up;
          message = 'Alerta: aumento expressivo!';
        } else if (percentChange >= 5 && percentChange <= 15) {
          cardColor = Colors.orange;
          icon = Iconsax.arrow_circle_up;
          message = 'Aumento moderado';
        } else if (percentChange >= -5 && percentChange <= 5) {
          cardColor = Colors.grey;
          icon = Iconsax.arrow_right_2;
          message = 'Estável';
        } else if (percentChange >= -15 && percentChange <= -5) {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          message = 'Boa redução!';
        } else {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          message = 'Economia significativa!';
        }

        String valueText = difference >= 0
            ? 'Aumentou ${_formatCurrency(absoluteDifference)}'
            : 'Diminuiu ${_formatCurrency(absoluteDifference)}';

        analysis.add({
          'month': _getMonthName(month),
          'analysis': '$valueText (${percentChange.toStringAsFixed(1)}%)',
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

  Widget _buildAnalysisItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: (item['cardColor'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: (item['cardColor'] as Color).withOpacity(0.3),
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
}

class _DonutPercent extends StatelessWidget {
  final double percent; // 0..100
  final Color color;

  const _DonutPercent({
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double clamped = percent.clamp(0, 100);

    final double size = 60.w;
    final double outerRadius = (size / 2).w;
    // centerRadius não é mais usado com Syncfusion Pie

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfCircularChart(
            margin: EdgeInsets.zero,
            legend: Legend(isVisible: false),
            series: <CircularSeries<Map<String, dynamic>, String>>[
              PieSeries<Map<String, dynamic>, String>(
                dataSource: [
                  {
                    'name': 'Filled',
                    'value': clamped <= 0 ? 0.0001 : clamped,
                    'color': color
                  },
                  {
                    'name': 'Remain',
                    'value': (100 - clamped) <= 0 ? 0.0001 : (100 - clamped),
                    'color': DefaultColors.greyLight
                  },
                ],
                xValueMapper: (Map<String, dynamic> e, _) =>
                    (e['name'] as String),
                yValueMapper: (Map<String, dynamic> e, _) =>
                    (e['value'] as double),
                pointColorMapper: (Map<String, dynamic> e, _) =>
                    (e['color'] as Color),
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              )
            ],
          ),
          Text(
            '${clamped.toStringAsFixed(1).replaceAll('.', ',')}%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
