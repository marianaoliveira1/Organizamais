// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';

import '../../../ads_banner/ads_banner.dart';

class SpendingShiftBalancePage extends StatefulWidget {
  final String selectedMonth;

  const SpendingShiftBalancePage({super.key, required this.selectedMonth});

  @override
  State<SpendingShiftBalancePage> createState() =>
      _SpendingShiftBalancePageState();
}

class _SpendingShiftBalancePageState extends State<SpendingShiftBalancePage> {
  // Todas as categorias do mês serão coletadas dinamicamente

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.put(TransactionController());

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final int currentYearMonth = _resolveYearMonth(widget.selectedMonth);
    final int previousYearMonth = _previousYearMonth(currentYearMonth);

    final _FoodShiftData data = _computeFoodShift(
      transactionController,
      currentYearMonth,
      previousYearMonth,
    );

    final double netDelta = data.totalCurrent - data.totalPrevious;
    final bool saved = netDelta < 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Balanço de Gastos por Categoria'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdsBanner(),
                SizedBox(height: 16.h),
                _buildSummaryCard(
                    theme, currencyFormatter, netDelta, saved, data),
                SizedBox(height: 16.h),
                _buildDetailsList(theme, currencyFormatter, data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, NumberFormat currencyFormatter,
      double netDelta, bool saved, _FoodShiftData data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balanço geral (mês atual vs anterior)',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            saved
                ? 'Você economizou ${currencyFormatter.format(netDelta.abs())} em alimentação.'
                : 'Você gastou ${currencyFormatter.format(netDelta)} a mais em alimentação.',
            style: TextStyle(
              fontSize: 12.sp,
              color: saved ? DefaultColors.green : DefaultColors.redDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryPill(
                theme,
                label: 'Mês anterior',
                value: currencyFormatter.format(data.totalPrevious),
                color: DefaultColors.grey.withOpacity(0.7),
              ),
              _buildSummaryPill(
                theme,
                label: 'Mês atual',
                value: currencyFormatter.format(data.totalCurrent),
                color: DefaultColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(ThemeData theme,
      {required String label, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              color: DefaultColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedBarChart(
      ThemeData theme, NumberFormat currencyFormatter, _FoodShiftData data) {
    final List<String> categoryNames = data.items.map((e) => e.name).toList();
    final double maxY = [
      ...data.items.map((e) => e.current),
      ...data.items.map((e) => e.previous),
    ].fold<double>(0.0, (prev, v) => v > prev ? v : prev);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativo por categoria',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 220.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: (data.items.length.toDouble() * 40.w) + 80.w,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY > 0 ? maxY * 1.2 : 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: DefaultColors.grey.withOpacity(0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            String label;
                            if (value >= 1000) {
                              label = '${(value / 1000).round()}k';
                            } else {
                              label = value.round().toString();
                            }
                            return Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Text(
                                label,
                                style: TextStyle(
                                    fontSize: 9.sp, color: DefaultColors.grey),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= categoryNames.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                categoryNames[idx],
                                style: TextStyle(
                                    fontSize: 10.sp, color: DefaultColors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(data.items.length, (i) {
                      final item = data.items[i];
                      final Color currentColor = item.color;
                      final Color previousColor =
                          DefaultColors.grey.withOpacity(0.6);
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 6.w,
                        barRods: [
                          BarChartRodData(
                            toY: item.previous,
                            color: previousColor,
                            borderRadius: BorderRadius.circular(4.r),
                            width: 12.w,
                          ),
                          BarChartRodData(
                            toY: item.current,
                            color: currentColor,
                            borderRadius: BorderRadius.circular(4.r),
                            width: 12.w,
                          ),
                        ],
                      );
                    }),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (grp) =>
                            DefaultColors.green.withOpacity(0.85),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label =
                              rodIndex == 0 ? 'Mês anterior' : 'Mês atual';
                          return BarTooltipItem(
                            '$label\n${currencyFormatter.format(rod.toY)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildLegend(
                  theme, DefaultColors.grey.withOpacity(0.6), 'Mês anterior'),
              SizedBox(width: 12.w),
              _buildLegend(theme, DefaultColors.green, 'Mês atual'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3.r)),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
              fontSize: 11.sp,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailsList(
      ThemeData theme, NumberFormat currencyFormatter, _FoodShiftData data) {
    // Mapeia macrocategorias do modelo -> cabeçalhos com emojis
    final Map<String, String> macroToHeader = {
      'Moradia e Casa': '🏠 Moradia',
      'Alimentação': '🍎 Alimentação',
      'Transporte': '🚗 Transporte',
      'Saúde e Bem-estar': '🏥 Saúde & Bem-estar',
      'Educação': '📚 Educação',
      'Lazer e Entretenimento': '🎭 Lazer & Entretenimento',
      'Compras': '🛍️ Compras & Estilo',
      'Pets': '🐾 Pets',
      'Finanças': '💰 Finanças & Impostos',
      'Impostos': '💰 Finanças & Impostos',
      'Família': '👨‍👩‍👧‍👦 Família & Social',
      'Trabalho': '💼 Trabalho',
      'Imprevistos': '🚨 Imprevistos',
      'Outros': '❓ Outros',
    };

    final List<String> headerOrder = [
      '🏠 Moradia',
      '🍎 Alimentação',
      '🚗 Transporte',
      '🏥 Saúde & Bem-estar',
      '📚 Educação',
      '🎭 Lazer & Entretenimento',
      '🛍️ Compras & Estilo',
      '🐾 Pets',
      '💰 Finanças & Impostos',
      '👨‍👩‍👧‍👦 Família & Social',
      '💼 Trabalho',
      '🚨 Imprevistos',
      '❓ Outros',
    ];

    // Agrupa itens por cabeçalho
    final Map<String, List<_FoodItemShift>> groups = {};
    for (final item in data.items) {
      final info = findCategoryById(item.id);
      final String macro = (info?['macrocategoria'] as String?) ?? 'Outros';
      final String header = macroToHeader[macro] ?? macro;
      groups.putIfAbsent(header, () => <_FoodItemShift>[]).add(item);
    }

    // Determina ordem final, incluindo grupos não mapeados
    final List<String> finalHeaders = [
      ...headerOrder.where((h) => groups.containsKey(h)),
      ...groups.keys.where((k) => !headerOrder.contains(k)).toList()..sort(),
    ];

    List<Widget> children = [
      Text(
        'Detalhes por categoria',
        style: TextStyle(
          fontSize: 16.sp,
          color: theme.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 10.h),
    ];

    for (final header in finalHeaders) {
      final items = groups[header]!;
      final Color macroColor = items.first.color;
      children.add(
        Container(
          margin: EdgeInsets.only(top: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: macroColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: macroColor.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              ...items.map((item) {
                final double delta = item.current - item.previous;
                final bool saved = delta < 0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(4.r)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${currencyFormatter.format(item.previous)} → ${currencyFormatter.format(item.current)}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: DefaultColors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        saved
                            ? 'Economizou\n${currencyFormatter.format(delta.abs())}'
                            : 'Gastou a mais\n${currencyFormatter.format(delta)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: saved
                              ? DefaultColors.green
                              : DefaultColors.redDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 6.h),
              Builder(builder: (_) {
                final List<_FoodItemShift> decreased = items
                    .where((i) => i.current < i.previous)
                    .toList()
                  ..sort((a, b) => (a.previous - a.current)
                      .compareTo(b.previous - b.current));
                final List<_FoodItemShift> increased = items
                    .where((i) => i.current > i.previous)
                    .toList()
                  ..sort((a, b) => (b.current - b.previous)
                      .compareTo(a.current - a.previous));
                final List<_FoodItemShift> unchanged = items
                    .where((i) => i.current == i.previous)
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

                String fmtDiff(_FoodItemShift it) {
                  final double diff = (it.current - it.previous).abs();
                  final double? pct =
                      it.previous > 0 ? (diff / it.previous) * 100.0 : null;
                  return pct == null
                      ? '${currencyFormatter.format(diff)} (novo)'
                      : '${currencyFormatter.format(diff)} (+${pct.toStringAsFixed(1)}%)';
                }

                List<Widget> lines = [];
                if (decreased.isNotEmpty) {
                  lines.add(Text(
                    'Você economizou nas categorias:',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DefaultColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ));
                  lines.addAll(decreased.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}: -${currencyFormatter.format((it.previous - it.current).abs())}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }
                if (increased.isNotEmpty) {
                  lines.add(Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'Você gastou mais nas categorias:',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ));
                  lines.addAll(increased.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}: +${fmtDiff(it)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }
                if (unchanged.isNotEmpty) {
                  lines.add(Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'Mantiveram o mesmo valor:',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ));
                  lines.addAll(unchanged.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }

                if (lines.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines,
                );
              }),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  int _resolveYearMonth(String selectedMonth) {
    int month;
    if (selectedMonth.isEmpty) {
      month = DateTime.now().month;
    } else {
      final months = _months();
      final idx = months.indexOf(selectedMonth);
      month = idx >= 0 ? idx + 1 : DateTime.now().month;
    }
    final int year = DateTime.now().year;
    return year * 100 + month;
  }

  int _previousYearMonth(int yearMonth) {
    final int year = yearMonth ~/ 100;
    final int month = yearMonth % 100;
    if (month == 1) return (year - 1) * 100 + 12;
    return year * 100 + (month - 1);
  }

  _FoodShiftData _computeFoodShift(
      TransactionController controller, int currentYm, int previousYm) {
    final List<TransactionModel> expenses = controller.transaction
        .where((e) => e.type == TransactionType.despesa)
        .toList();

    double sumFor(int ym, int categoryId) {
      final int year = ym ~/ 100;
      final int month = ym % 100;
      double total = 0.0;
      for (final t in expenses) {
        if (t.paymentDay == null) continue;
        if (t.category != categoryId) continue;
        final DateTime date = DateTime.parse(t.paymentDay!);
        if (date.year == year && date.month == month) {
          total +=
              double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
        }
      }
      return total;
    }

    final int year = currentYm ~/ 100;
    final int month = currentYm % 100;
    final Set<int> usedIds = <int>{};
    for (final t in expenses) {
      if (t.paymentDay == null) continue;
      if (t.category == null) continue;
      final DateTime d = DateTime.parse(t.paymentDay!);
      if (d.year == year && d.month == month) {
        usedIds.add(t.category!);
      }
    }

    final List<_FoodItemShift> items = [];
    for (final id in usedIds) {
      final info = findCategoryById(id);
      final String name = (info?['name'] as String?) ?? 'Categoria';
      final Color color = (info?['color'] as Color?) ?? DefaultColors.green;
      final double previous = sumFor(previousYm, id);
      final double current = sumFor(currentYm, id);
      items.add(_FoodItemShift(
          id: id,
          name: name,
          color: color,
          previous: previous,
          current: current));
    }

    items.sort((a, b) => b.current.compareTo(a.current));

    final double totalPrevious = items.fold(0.0, (s, e) => s + e.previous);
    final double totalCurrent = items.fold(0.0, (s, e) => s + e.current);

    return _FoodShiftData(
        items: items, totalPrevious: totalPrevious, totalCurrent: totalCurrent);
  }

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
        'Dezembro',
      ];
}

class _FoodShiftData {
  final List<_FoodItemShift> items;
  final double totalPrevious;
  final double totalCurrent;

  _FoodShiftData(
      {required this.items,
      required this.totalPrevious,
      required this.totalCurrent});
}

class _FoodItemShift {
  final int id;
  final String name;
  final Color color;
  final double previous;
  final double current;

  _FoodItemShift({
    required this.id,
    required this.name,
    required this.color,
    required this.previous,
    required this.current,
  });
}
