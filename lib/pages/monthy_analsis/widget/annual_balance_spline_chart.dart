import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

class AnnualBalanceSplineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    final int year = DateTime.now().year;
    final List<_Point> points = _buildAnnualBalance(controller, year);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo do ano (${year})',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 220.h,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'R\$ {point.y}',
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
                  pointColorMapper: (p, _) => p.y >= 0
                      ? DefaultColors.greenDark
                      : DefaultColors.redDark,
                  borderRadius: BorderRadius.circular(6.r),
                  width: 0.6,
                  enableTooltip: true,
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_Point> _buildAnnualBalance(TransactionController c, int year) {
    final List<_Point> out = [];
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
        if (d.year != year || d.month != m) continue;
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
