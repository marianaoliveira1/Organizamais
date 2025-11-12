import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

class InsightsForecastPage extends StatelessWidget {
  final int categoryId;
  final String monthName; // e.g. "Março/2025" ou "Março"
  final String? categoryName;
  final Color? categoryColor;

  const InsightsForecastPage({
    super.key,
    required this.categoryId,
    required this.monthName,
    this.categoryName,
    this.categoryColor,
  });

  List<String> _months() => const [
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TransactionController tx = Get.find<TransactionController>();
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Parse selected month/year
    final String raw = monthName.trim();
    final List<String> parts = raw.split('/');
    final String selMonthName = parts.isNotEmpty ? parts[0].trim() : raw;
    final int selYear = parts.length >= 2
        ? int.tryParse(parts[1].trim()) ?? DateTime.now().year
        : DateTime.now().year;
    final int selMonthIndex = _months().indexOf(selMonthName);
    final int selMonth =
        selMonthIndex >= 0 ? selMonthIndex + 1 : DateTime.now().month;

    final DateTime monthStart = DateTime(selYear, selMonth, 1);
    final int daysInSelected = DateTime(selYear, selMonth + 1, 0).day;
    final DateTime monthEnd =
        DateTime(selYear, selMonth, daysInSelected, 23, 59, 59);
    final bool isCurrentMonth =
        selYear == DateTime.now().year && selMonth == DateTime.now().month;
    final DateTime cutoff = isCurrentMonth ? DateTime.now() : monthEnd;

    // Gather daily totals for the category in the month
    final List<TransactionModel> monthTxs = tx.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.category != categoryId) return false;
      final d = DateTime.parse(t.paymentDay!);
      return !d.isBefore(monthStart) && !d.isAfter(cutoff);
    }).toList();

    final Map<int, double> dailyTotals = {
      for (int d = 1; d <= daysInSelected; d++) d: 0.0
    };
    for (final t in monthTxs) {
      final d = DateTime.parse(t.paymentDay!);
      final double v =
          double.tryParse(t.value.replaceAll('.', '').replaceAll(',', '.')) ??
              0.0;
      if (d.month == selMonth && d.year == selYear) {
        dailyTotals[d.day] = (dailyTotals[d.day] ?? 0.0) + v;
      }
    }

    final int daysElapsed =
        isCurrentMonth ? DateTime.now().day : daysInSelected;
    final int remainingDays =
        (daysInSelected - daysElapsed).clamp(0, daysInSelected);

    // Cumulative actual spent so far
    double spentSoFar = 0.0;
    for (int day = 1; day <= daysElapsed; day++) {
      spentSoFar += dailyTotals[day] ?? 0.0;
    }

    final double dailyAvg = daysElapsed > 0 ? (spentSoFar / daysElapsed) : 0.0;
    final double weeklyAvg = dailyAvg * 7;
    final double forecastRemaining = dailyAvg * remainingDays;
    final double totalForecast = spentSoFar + forecastRemaining;
    // Simple range (+/- 15%)
    final double low = totalForecast * 0.85;
    final double high = totalForecast * 1.15;

    // Previous month total for comparison
    final DateTime prevStart = DateTime(selYear, selMonth - 1, 1);
    final DateTime prevEnd = DateTime(selYear, selMonth, 0, 23, 59, 59);
    final double previousMonthTotal = tx.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.category != categoryId) return false;
      final d = DateTime.parse(t.paymentDay!);
      return !d.isBefore(prevStart) && !d.isAfter(prevEnd);
    }).fold(0.0, (p, t) {
      final v =
          double.tryParse(t.value.replaceAll('.', '').replaceAll(',', '.')) ??
              0.0;
      return p + v;
    });
    final double diffPct = previousMonthTotal > 0
        ? ((totalForecast - previousMonthTotal) / previousMonthTotal) * 100.0
        : 100.0;

    // Build cumulative series for chart
    final List<MapEntry<int, double>> actualCumulative = [];
    double acc = 0.0;
    for (int day = 1; day <= daysElapsed; day++) {
      acc += dailyTotals[day] ?? 0.0;
      actualCumulative.add(MapEntry(day, acc));
    }
    final List<MapEntry<int, double>> projectedCumulative = [];
    double accProj = acc;
    for (int day = daysElapsed + 1; day <= daysInSelected; day++) {
      accProj += dailyAvg;
      projectedCumulative.add(MapEntry(day, accProj));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? 'Insights e previsão'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdsBanner(),
            SizedBox(height: 16.h),
            // Headline numbers
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    theme: theme,
                    label: 'Média diária',
                    value: currency.format(dailyAvg),
                    trailingIcon: Iconsax.dollar_square,
                    trailingIconColor: DefaultColors.grey20,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _metricCard(
                    theme: theme,
                    label: 'Média semanal',
                    value: currency.format(weeklyAvg),
                    trailingIcon: Iconsax.calendar_1,
                    trailingIconColor: DefaultColors.grey20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    theme: theme,
                    label: 'Próx. 7 dias',
                    value: currency.format(remainingDays > 0
                        ? dailyAvg * (remainingDays >= 7 ? 7 : remainingDays)
                        : 0.0),
                    trailingIcon: Iconsax.trend_up,
                    trailingIconColor: DefaultColors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _metricCard(
                    theme: theme,
                    label: 'Até fim do mês',
                    value: currency.format(forecastRemaining),
                    trailingIcon: Iconsax.gps,
                    trailingIconColor: DefaultColors.yellow,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            _metricCard(
              theme: theme,
              label: 'Total até agora',
              value: currency.format(spentSoFar),
              highlight: true,
              trailingIcon: Iconsax.dollar_circle,
              trailingIconColor: DefaultColors.grey20,
            ),
            SizedBox(height: 8.h),
            _metricCard(
              theme: theme,
              label: 'Total estimado do mês',
              value: currency.format(totalForecast),
              highlight: false,
              trailingIcon: Iconsax.status_up,
              trailingIconColor: DefaultColors.purple,
              extra: Text(
                previousMonthTotal > 0
                    ? '${diffPct >= 0 ? "+" : "-"}${diffPct.abs().toStringAsFixed(1)}% vs mês anterior'
                    : 'Sem base do mês anterior',
                style: TextStyle(
                  color: diffPct >= 0 ? DefaultColors.red : DefaultColors.green,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 12.h),
            AdsBanner(),
            SizedBox(height: 16.h),
            SizedBox(
              height: 220.h,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle:
                      TextStyle(fontSize: 8.sp, color: DefaultColors.grey),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle:
                      TextStyle(fontSize: 8.sp, color: DefaultColors.grey),
                  majorGridLines: MajorGridLines(
                      color: DefaultColors.grey.withOpacity(0.12), width: 0.6),
                ),
                series: <CartesianSeries<MapEntry<int, double>, String>>[
                  LineSeries<MapEntry<int, double>, String>(
                    dataSource: actualCumulative,
                    xValueMapper: (e, _) => e.key.toString(),
                    yValueMapper: (e, _) => e.value,
                    color: categoryColor ?? Get.theme.primaryColor,
                    width: 2,
                  ),
                  LineSeries<MapEntry<int, double>, String>(
                    dataSource: projectedCumulative,
                    xValueMapper: (e, _) => e.key.toString(),
                    yValueMapper: (e, _) => e.value,
                    color: DefaultColors.grey,
                    dashArray: const <double>[6, 4],
                    width: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            _infoBox(
              theme: theme,
              color: const Color(0xFF7C3AED),
              title: 'Previsão simples',
              body:
                  'Se você continuar neste ritmo, o total do mês deve ficar entre ${currency.format(low)} e ${currency.format(high)}.',
            ),
            SizedBox(height: 8.h),
            _infoBox(
              theme: theme,
              color: const Color(0xFFFFC107),
              title: 'Orçamento do mês (exemplo)',
              body:
                  'Some o que já gastou neste mês (${currency.format(spentSoFar)}), calcule a média diária (${currency.format(dailyAvg)}), multiplique pelos dias restantes ($remainingDays), e ajuste +/−15% para ter um intervalo realista.',
            ),
            SizedBox(height: 12.h),
            AdsBanner(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(
      {required ThemeData theme,
      required String label,
      required String value,
      bool highlight = false,
      IconData? trailingIcon,
      Color? trailingIconColor,
      Widget? extra}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DefaultColors.grey20.withOpacity(.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: DefaultColors.grey,
                      fontWeight: FontWeight.w600)),
              if (trailingIcon != null)
                Icon(trailingIcon,
                    size: 14.sp, color: trailingIconColor ?? DefaultColors.grey)
            ],
          ),
          SizedBox(height: 4.h),
          Text(value,
              style: TextStyle(
                  fontSize: highlight ? 18.sp : 16.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryColor)),
          if (extra != null) ...[SizedBox(height: 4.h), extra],
        ],
      ),
    );
  }

  Widget _infoBox({
    required ThemeData theme,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: color.withOpacity(.6)),
            ),
            child: Center(
              child: Icon(Iconsax.info_circle, size: 12.sp, color: color),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.primaryColor)),
                SizedBox(height: 6.h),
                Text(body,
                    style:
                        TextStyle(fontSize: 12.sp, color: DefaultColors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
