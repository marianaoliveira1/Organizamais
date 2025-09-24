import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../transaction/pages/category_page.dart';

class InvoiceCategoriesBreakdownPage extends StatelessWidget {
  const InvoiceCategoriesBreakdownPage({
    super.key,
    required this.cardName,
    required this.periodStart,
    required this.periodEnd,
  });

  final String cardName;
  final DateTime periodStart;
  final DateTime periodEnd;

  double _parseAmount(String raw) {
    String s = raw.replaceAll('R\$', '').trim();
    if (s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(s) ?? 0.0;
    }
    s = s.replaceAll(' ', '');
    return double.tryParse(s) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final TransactionController txController =
        Get.find<TransactionController>();

    // Filtra transações do cartão e período
    final List<TransactionModel> txs = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      if ((t.paymentType ?? '') != cardName) return false;
      DateTime d;
      try {
        d = DateTime.parse(t.paymentDay!);
      } catch (_) {
        return false;
      }
      return !d.isBefore(periodStart) && !d.isAfter(periodEnd);
    }).toList();

    // Agrega por categoria
    final Map<int, double> totalsByCategory = <int, double>{};
    for (final t in txs) {
      final int? catId = t.category;
      if (catId == null) continue;
      totalsByCategory.update(catId, (v) => v + _parseAmount(t.value),
          ifAbsent: () => _parseAmount(t.value));
    }

    // Monta dados para gráfico e lista
    final List<_CategorySlice> slices = totalsByCategory.entries.map((e) {
      final info = findCategoryById(e.key);
      final Color color = (info != null && info['color'] is Color)
          ? info['color'] as Color
          : theme.primaryColor;
      final String name =
          (info != null ? (info['name'] as String? ?? '') : '').toString();
      return _CategorySlice(
        categoryId: e.key,
        name: name.isEmpty ? 'Categoria ${e.key}' : name,
        value: e.value,
        color: color,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final double total =
        slices.fold(0.0, (prev, s) => prev + (s.value.isFinite ? s.value : 0));

    final List<PieChartSectionData> sections = slices
        .map(
          (s) => PieChartSectionData(
            value: s.value,
            color: s.color,
            title: '',
            radius: 52,
            showTitle: false,
          ),
        )
        .toList();

    // Comparativo com mês anterior (mesmo cartão)
    final DateTime prevMonthStart =
        DateTime(periodStart.year, periodStart.month - 1, 1);
    final DateTime prevMonthEnd =
        DateTime(prevMonthStart.year, prevMonthStart.month + 1, 0, 23, 59, 59);
    final double prevTotal = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      if ((t.paymentType ?? '') != cardName) return false;
      DateTime d;
      try {
        d = DateTime.parse(t.paymentDay!);
      } catch (_) {
        return false;
      }
      return !d.isBefore(prevMonthStart) && !d.isAfter(prevMonthEnd);
    }).fold<double>(0.0, (s, t) => s + _parseAmount(t.value));
    String prevMonthName = DateFormat('MMMM', 'pt_BR').format(prevMonthStart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias do cartão'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdsBanner(),
              SizedBox(height: 12.h),
              // Cabeçalho
              Text(
                cardName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              // Bloco informativo ANTES do gráfico
              Builder(builder: (context) {
                final double diff = total - prevTotal;
                final bool increased = diff > 0;
                final String verb = increased
                    ? 'aumentou'
                    : (diff < 0 ? 'diminuiu' : 'manteve');
                final Color color = diff > 0
                    ? DefaultColors.redDark
                    : (diff < 0 ? DefaultColors.greenDark : DefaultColors.grey);
                final String prevMonthName =
                    DateFormat('MMMM', 'pt_BR').format(prevMonthStart);
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'No mês anterior você gastou ${currency.format(prevTotal)}, e neste mês foram ${currency.format(total)}; houve ${verb} de ${currency.format(diff.abs())}.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 28,
                          centerSpaceColor: theme.cardColor,
                          sections: sections,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ' + currency.format(total),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Lista de categorias
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slices.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final s = slices[index];
                  final double pct = total > 0 ? (s.value / total * 100) : 0.0;
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                pct.toStringAsFixed(1) + '%',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DefaultColors.grey20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(s.value),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              AdsBanner(),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySlice {
  _CategorySlice({
    required this.categoryId,
    required this.name,
    required this.value,
    required this.color,
  });

  final int categoryId;
  final String name;
  final double value;
  final Color color;
}
