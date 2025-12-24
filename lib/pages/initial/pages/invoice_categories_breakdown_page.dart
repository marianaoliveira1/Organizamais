// import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Removed generic Iconsax usage to show the actual card/bank logo

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
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
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

    // Syncfusion usa a própria série com 'slices' como dataSource

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
    // Nome do mês anterior (se necessário):
    // final String prevMonthName = DateFormat('MMMM', 'pt_BR').format(prevMonthStart);

    void showTransactionsModal(_CategorySlice slice) {
      final List<TransactionModel> list =
          txs.where((t) => t.category == slice.categoryId).toList()
            ..sort((a, b) {
              DateTime ad, bd;
              try {
                ad = DateTime.parse(a.paymentDay ?? '');
              } catch (_) {
                ad = DateTime.fromMillisecondsSinceEpoch(0);
              }
              try {
                bd = DateTime.parse(b.paymentDay ?? '');
              } catch (_) {
                bd = DateTime.fromMillisecondsSinceEpoch(0);
              }
              return bd.compareTo(ad);
            });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        builder: (_) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: DefaultColors.grey20,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AdsBanner(),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slice.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${list.length} transações',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: DefaultColors.grey20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currency.format(slice.value),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Total no período',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: DefaultColors.grey20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Transações',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Text(
                                'Sem transações para esta categoria.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: DefaultColors.grey20,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: DefaultColors.grey20),
                              itemBuilder: (_, i) {
                                final t = list[i];
                                String date = '';
                                try {
                                  if (t.paymentDay != null) {
                                    date = dateFormatter
                                        .format(DateTime.parse(t.paymentDay!));
                                  }
                                } catch (_) {}
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: theme.primaryColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            date,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: DefaultColors.grey20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      currency.format(_parseAmount(t.value)),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(cardName),
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

              // Bloco informativo ANTES do gráfico
              Builder(builder: (context) {
                final double diff = total - prevTotal;
                final bool increased = diff > 0;
                final String verb = increased
                    ? 'um aumento'
                    : (diff < 0 ? 'uma redução' : 'manutenção');
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
                    diff == 0
                        ? 'Seus gastos se mantiveram iguais em relação a $prevMonthName.'
                        : 'No mês passado, você gastou ${currency.format(prevTotal)}, e neste mês o total foi de ${currency.format(total)} — representando $verb de ${currency.format(diff.abs())}.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),

              SizedBox(height: 20.h),
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
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        legend: Legend(isVisible: false),
                        series: <CircularSeries<_CategorySlice, String>>[
                          PieSeries<_CategorySlice, String>(
                            dataSource: slices,
                            xValueMapper: (_CategorySlice s, _) => s.name,
                            yValueMapper: (_CategorySlice s, _) => s.value,
                            pointColorMapper: (_CategorySlice s, _) => s.color,
                            dataLabelMapper: (_CategorySlice s, _) {
                              final double pct =
                                  total > 0 ? (s.value / total) * 100 : 0;
                              return '${s.name}\n${pct.toStringAsFixed(0)}%';
                            },
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                            explode: true,
                            explodeIndex: slices.isEmpty ? null : 0,
                            explodeOffset: '8%',
                            sortingOrder: SortingOrder.descending,
                            sortFieldValueMapper: (_CategorySlice s, _) =>
                                s.value,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ${currency.format(total)}',
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
                  final int txCount =
                      txs.where((t) => t.category == s.categoryId).length;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => showTransactionsModal(s),
                    child: Container(
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
                                  '${pct.toStringAsFixed(1)}% do total',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                // Barra de progresso fina
                                LayoutBuilder(builder: (context, constraints) {
                                  final double widthFactor =
                                      (pct / 100.0).clamp(0, 1);
                                  return Container(
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: widthFactor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: s.color,
                                            borderRadius:
                                                BorderRadius.circular(999.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currency.format(s.value),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                txCount == 1
                                    ? '1 transação'
                                    : '$txCount transações',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12.h),
              // Cards de métricas rápidas
              Builder(builder: (context) {
                final int txCount = txs.length;
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total de transações',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20)),
                            SizedBox(height: 4.h),
                            Text(
                              '$txCount',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 20.h),
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
