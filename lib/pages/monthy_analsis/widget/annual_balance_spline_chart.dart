import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import 'package:organizamais/widgetes/info_card.dart';

class AnnualBalanceSplineChart extends StatelessWidget {
  final int selectedYear;

  const AnnualBalanceSplineChart({super.key, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    final List<_Point> points = _buildAnnualBalance(controller, selectedYear);

    return InfoCard(
      title: 'Saldo acumulado ao longo do ano',
      onTap: null,
      content: SizedBox(
        height: 220.h,
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: r'R$ {point.y}',
          ),
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
            axisLine: const AxisLine(width: 0),
            interval: 1,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            labelRotation: 0,
            labelStyle: TextStyle(
              color: DefaultColors.grey,
              fontSize: 10.sp,
            ),
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: MajorGridLines(
              width: 1,
              color: theme.primaryColor.withOpacity(0.08),
            ),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
            labelStyle: TextStyle(
              color: DefaultColors.grey,
              fontSize: 10.sp,
            ),
            numberFormat: NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
              decimalDigits: 2,
            ),
          ),
          series: <CartesianSeries<_Point, String>>[
            ColumnSeries<_Point, String>(
              dataSource: points,
              xValueMapper: (p, _) => p.m,
              yValueMapper: (p, _) => p.y,
              pointColorMapper: (p, _) =>
                  p.y >= 0 ? DefaultColors.greenDark : DefaultColors.redDark,
              borderRadius: BorderRadius.circular(6.r),
              width: 0.6,
              enableTooltip: true,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
      ),
    );
  }

  List<_Point> _buildAnnualBalance(TransactionController c, int year) {
    final List<_Point> out = [];
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final bool isCurrentYear = year == now.year;
    final months = const [
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

    for (int m = 1; m <= 12; m++) {
      double income = 0.0;
      double expense = 0.0;
      for (final t in c.transaction) {
        if (t.paymentDay == null) continue;
        final d = DateTime.parse(t.paymentDay!);
        final DateTime dOnly = DateTime(d.year, d.month, d.day);
        if (d.year != year || d.month != m) continue;
        // Se for o ano atual, filtrar apenas até hoje; se for ano passado, mostrar todos os meses
        if (isCurrentYear && dOnly.isAfter(today)) continue;
        final v =
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
        if (t.type == TransactionType.receita) {
          income += v;
        } else if (t.type == TransactionType.despesa) {
          expense += v;
        }
      }
      out.add(_Point(months[m - 1], income - expense));
    }
    return out;
  }
}

class _Point {
  final String m;
  final double y;
  _Point(this.m, this.y);
}
