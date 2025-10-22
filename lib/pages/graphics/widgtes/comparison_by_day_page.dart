import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

class ComparisonByDayPage extends StatelessWidget {
  final int categoryId;
  final String title;

  const ComparisonByDayPage(
      {super.key, required this.categoryId, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final tx = Get.find<TransactionController>();

    final int targetDay = DateTime.now().day;

    DateTime? firstDate;
    for (final t in tx.transaction) {
      if (t.category == categoryId && t.paymentDay != null) {
        final d = DateTime.tryParse(t.paymentDay!);
        if (d != null) {
          firstDate =
              (firstDate == null || d.isBefore(firstDate!)) ? d : firstDate;
        }
      }
    }
    final DateTime start = firstDate == null
        ? DateTime(DateTime.now().year, DateTime.now().month - 1, 1)
        : DateTime(firstDate!.year, firstDate!.month - 1, 1);
    final DateTime end = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final List<_MonthRow> rows = [];

    DateTime cursor = DateTime(end.year, end.month, 1);
    while (!cursor.isBefore(start)) {
      final DateTime monthStart = DateTime(cursor.year, cursor.month, 1);
      final int lastDay = DateTime(cursor.year, cursor.month + 1, 0).day;
      final int cut = targetDay.clamp(1, lastDay);
      final DateTime monthCutoff =
          DateTime(cursor.year, cursor.month, cut, 23, 59, 59);

      final double current = tx.transaction.where((t) {
        if (t.paymentDay == null) return false;
        if (t.category != categoryId) return false;
        final d = DateTime.parse(t.paymentDay!);
        return !d.isBefore(monthStart) && !d.isAfter(monthCutoff);
      }).fold(0.0, (p, t) => p + _parseValue(t.value));

      final DateTime prevStart = DateTime(cursor.year, cursor.month - 1, 1);
      final int prevLastDay = DateTime(cursor.year, cursor.month, 0).day;
      final DateTime prevCutoff = DateTime(prevStart.year, prevStart.month,
          targetDay.clamp(1, prevLastDay), 23, 59, 59);

      final double previous = tx.transaction.where((t) {
        if (t.paymentDay == null) return false;
        if (t.category != categoryId) return false;
        final d = DateTime.parse(t.paymentDay!);
        return !d.isBefore(prevStart) && !d.isAfter(prevCutoff);
      }).fold(0.0, (p, t) => p + _parseValue(t.value));

      rows.add(_MonthRow(
        label:
            '1–${cut.toString().padLeft(2, '0')} de ${_monthNamePt(cursor.month)} de ${cursor.year}',
        amount: current,
        diffAmount: (current - previous).abs(),
        pct: previous > 0
            ? ((current - previous) / previous) * 100.0
            : (current > 0 ? 100.0 : 0.0),
        increased: current > previous,
        isNeutral: (current - previous).abs() < 0.0001,
      ));

      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Comparação por dia'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemBuilder: (_, i) {
          final r = rows[i];
          final Color tagColor = r.isNeutral
              ? DefaultColors.grey
              : (r.increased ? DefaultColors.red : DefaultColors.green);
          final Color tagBg = tagColor.withOpacity(.12);
          final String pctText = r.isNeutral
              ? '0.0%'
              : '${r.increased ? '+' : '-'}${r.pct.abs().toStringAsFixed(1)}%';
          final String diffText = r.isNeutral
              ? '(R\$ 0,00)'
              : '(${r.increased ? '+' : '-'}${currency.format(r.diffAmount)})';

          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: DefaultColors.grey20.withOpacity(.25)),
            ),
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.label,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(currency.format(r.amount),
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor)),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          r.isNeutral
                              ? Icons.circle
                              : (r.increased
                                  ? Icons.trending_up
                                  : Icons.trending_down),
                          size: 14.sp,
                          color: tagColor),
                      SizedBox(width: 6.w),
                      Text('$pctText  $diffText',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: tagColor)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemCount: rows.length,
      ),
    );
  }

  static double _parseValue(String v) {
    return double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
  }

  static String _monthNamePt(int m) {
    const ms = [
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
    return ms[(m - 1).clamp(0, 11)];
  }
}

class _MonthRow {
  final String label;
  final double amount;
  final double diffAmount;
  final double pct;
  final bool increased;
  final bool isNeutral;

  _MonthRow({
    required this.label,
    required this.amount,
    required this.diffAmount,
    required this.pct,
    required this.increased,
    required this.isNeutral,
  });
}
