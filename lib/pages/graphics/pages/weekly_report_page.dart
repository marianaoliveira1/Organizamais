import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';
import '../../transaction/pages/category_page.dart';
import '../../../ads_banner/ads_banner.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key, required this.selectedMonth});

  final String selectedMonth;

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  late int _selYear;
  late int _selMonth; // 1..12
  int _selectedWeekIdx = 0; // index into _weeks

  late List<_WeekRange> _weeks;

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final parts = widget.selectedMonth.split('/');
    String mName = parts.isNotEmpty ? parts[0] : widget.selectedMonth;
    _selYear =
        parts.length == 2 ? int.tryParse(parts[1]) ?? now.year : now.year;
    final months = _getAllMonths();
    final idx = months.indexOf(mName);
    _selMonth = idx >= 0 ? idx + 1 : now.month;

    _weeks = _computeWeeks(_selYear, _selMonth);
    // Se estivermos no mês atual, seleciona a semana correspondente ao dia de hoje
    final isCurrent = _selYear == now.year && _selMonth == now.month;
    if (isCurrent) {
      for (int i = 0; i < _weeks.length; i++) {
        final w = _weeks[i];
        if (!now.isBefore(w.start) && !now.isAfter(w.end)) {
          _selectedWeekIdx = i;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.put(TransactionController());

    final _WeekRange week = _weeks[_selectedWeekIdx];
    final _WeeklyData data = _aggregateWeekly(controller, week);

    final double totalExpenses =
        data.byCategory.values.fold(0.0, (prev, v) => prev + v);

    final chartData = data.byCategory.entries.map((e) {
      final catId = e.key;
      final sum = e.value;
      final info = findCategoryById(catId);
      final name =
          info?['name'] ?? (catId == -1 ? 'Outros' : 'Categoria $catId');
      final color = info?['color'] as Color? ?? DefaultColors.grey;
      return {
        'id': catId,
        'name': name,
        'value': sum,
        'color': color,
        'icon': info?['icon'],
      };
    }).toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    final double maxVal = chartData.isEmpty
        ? 0
        : chartData
            .map((e) => e['value'] as double)
            .reduce((a, b) => a > b ? a : b);
    final int explodeIndex =
        chartData.indexWhere((e) => (e['value'] as double) == maxVal);

    final String weekLabel = _formatWeekLabel(week);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório semanal',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: DefaultColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedWeekIdx,
                          items: [
                            for (int i = 0; i < _weeks.length; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text(
                                  'Semana ${i + 1} (${_formatWeekLabel(_weeks[i])})',
                                  style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 12.sp),
                                ),
                              )
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedWeekIdx = v;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text('Resumo geral',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor)),
              SizedBox(height: 8.h),
              _buildSummaryCards(theme, data),
              SizedBox(height: 16.h),
              Text('Distribuição dos gastos',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor)),
              SizedBox(height: 10.h),
              if (chartData.isEmpty)
                Center(
                  child: Text(
                    'Sem despesas na $weekLabel',
                    style:
                        TextStyle(color: DefaultColors.grey, fontSize: 12.sp),
                  ),
                )
              else ...[
                Center(
                  child: SizedBox(
                    height: 200.h,
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      legend: const Legend(isVisible: false),
                      series: <CircularSeries<Map<String, dynamic>, String>>[
                        PieSeries<Map<String, dynamic>, String>(
                          dataSource: chartData,
                          xValueMapper: (e, _) => (e['name'] as String),
                          yValueMapper: (e, _) => (e['value'] as double),
                          pointColorMapper: (e, _) => (e['color'] as Color),
                          dataLabelMapper: (e, _) => '',
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: false),
                          explode: true,
                          explodeIndex: explodeIndex < 0 ? 0 : explodeIndex,
                          explodeOffset: '6%',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                ...chartData.map((e) {
                  final double v = e['value'] as double;
                  final double pct =
                      totalExpenses > 0 ? (v / totalExpenses) * 100 : 0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: (e['color'] as Color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (e['icon'] != null)
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Image.asset(
                              e['icon'] as String,
                              width: 16.w,
                              height: 16.h,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            e['name'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _currency.format(v),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, _WeeklyData data) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receitas',
                    style:
                        TextStyle(fontSize: 11.sp, color: DefaultColors.grey)),
                SizedBox(height: 2.h),
                Text(_currency.format(data.totalIncome),
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: DefaultColors.greenDark,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Despesas',
                    style:
                        TextStyle(fontSize: 11.sp, color: DefaultColors.grey)),
                SizedBox(height: 2.h),
                Text(_currency.format(data.totalExpense),
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: DefaultColors.redDark,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo',
                    style:
                        TextStyle(fontSize: 11.sp, color: DefaultColors.grey)),
                SizedBox(height: 2.h),
                Text(
                  _currency.format(data.totalIncome - data.totalExpense),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_WeekRange> _computeWeeks(int year, int month) {
    final int lastDay = DateTime(year, month + 1, 0).day;
    final List<_WeekRange> out = [];
    final ranges = [
      [1, 7],
      [8, 14],
      [15, 21],
      [22, 28],
      [29, lastDay],
    ];
    for (final r in ranges) {
      final int start = r[0];
      final int end = r[1];
      if (start > lastDay) break;
      final s = DateTime(year, month, start);
      final e = DateTime(year, month, end, 23, 59, 59);
      out.add(_WeekRange(start: s, end: e));
    }
    return out;
  }

  _WeeklyData _aggregateWeekly(TransactionController c, _WeekRange w) {
    double income = 0.0;
    double expense = 0.0;
    final Map<int, double> byCategory = {};

    for (final t in c.transaction) {
      if (t.paymentDay == null) continue;
      final d = DateTime.parse(t.paymentDay!);
      if (d.isBefore(w.start) || d.isAfter(w.end)) continue;

      final v = double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));

      if (t.type == TransactionType.receita) {
        income += v;
      } else if (t.type == TransactionType.despesa) {
        expense += v;
        final int key = t.category ?? -1;
        byCategory[key] = (byCategory[key] ?? 0.0) + v;
      }
    }

    return _WeeklyData(
        totalIncome: income, totalExpense: expense, byCategory: byCategory);
  }

  String _formatWeekLabel(_WeekRange w) {
    final d1 = w.start.day.toString().padLeft(2, '0');
    final d2 = w.end.day.toString().padLeft(2, '0');
    final months = _getAllMonths();
    final m = months[w.start.month - 1];
    return '$d1-$d2 $m';
  }

  List<String> _getAllMonths() {
    return const [
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

class _WeekRange {
  final DateTime start;
  final DateTime end;
  const _WeekRange({required this.start, required this.end});
}

class _WeeklyData {
  final double totalIncome;
  final double totalExpense;
  final Map<int, double> byCategory;
  const _WeeklyData(
      {required this.totalIncome,
      required this.totalExpense,
      required this.byCategory});
}
