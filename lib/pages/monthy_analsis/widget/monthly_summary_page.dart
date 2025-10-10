import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../controller/goal_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../transaction/pages/category_page.dart';

class MonthlySummaryPage extends StatefulWidget {
  final int? initialMonth;
  final int? initialYear;
  const MonthlySummaryPage({super.key, this.initialMonth, this.initialYear});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  late int _selectedMonth;
  late int _selectedYear;

  static const List<String> _monthsPt = [
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

  static const List<Color> _customCardColors = [
    DefaultColors.pastelBlue,
    DefaultColors.pastelGreen,
    DefaultColors.pastelPurple,
    DefaultColors.pastelOrange,
    DefaultColors.pastelPink,
    DefaultColors.pastelTeal,
    DefaultColors.pastelCyan,
    DefaultColors.pastelLime,
    DefaultColors.lavender,
    DefaultColors.peach,
    DefaultColors.mint,
    DefaultColors.plum,
    DefaultColors.turquoise,
    DefaultColors.salmon,
    DefaultColors.lightBlue,
  ];

  static Color _getPaymentTypeColor(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'crédito':
        return DefaultColors.deepPurple;
      case 'débito':
        return DefaultColors.darkBlue;
      case 'dinheiro':
        return DefaultColors.orangeDark;
      case 'pix':
        return DefaultColors.greenDark;
      case 'boleto':
        return DefaultColors.brown;
      case 'transferência':
        return DefaultColors.blueGrey;
      case 'cheque':
        return DefaultColors.gold;
      case 'vale':
        return DefaultColors.lime;
      case 'criptomoeda':
        return DefaultColors.slateGrey;
      case 'cupom':
        return DefaultColors.hotPink;
      default:
        int colorIndex = paymentType.hashCode.abs() % _customCardColors.length;
        return _customCardColors[colorIndex];
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = widget.initialMonth ?? now.month;
    _selectedYear = widget.initialYear ?? now.year;
  }

  List<TransactionModel> _filterMonth(List<TransactionModel> all) {
    return all.where((t) {
      if (t.paymentDay == null) return false;
      final d = DateTime.parse(t.paymentDay!);
      return d.month == _selectedMonth && d.year == _selectedYear;
    }).toList();
  }

  double _sumByType(List<TransactionModel> txs, TransactionType type) {
    return txs.where((t) => t.type == type).fold(
        0.0,
        (s, t) =>
            s + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    final txs = _filterMonth(controller.transaction);
    final receitas = _sumByType(txs, TransactionType.receita);
    final despesas = _sumByType(txs, TransactionType.despesa);
    final saldo = receitas - despesas;

    final categorias = <int, double>{};
    for (final t in txs.where(
        (t) => t.type == TransactionType.despesa && t.category != null)) {
      final id = t.category!;
      final v = double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      categorias[id] = (categorias[id] ?? 0.0) + v;
    }
    // Análise por categoria com dia da semana preferido
    final catData = categorias.entries.map((e) {
      final categoryId = e.key;
      final categoryTxs = txs
          .where((t) =>
              t.type == TransactionType.despesa &&
              t.category == categoryId &&
              t.paymentDay != null)
          .toList();

      // Calcular dia da semana mais comum para esta categoria
      final weekdayMap = <int, double>{};
      for (final t in categoryTxs) {
        final dt = DateTime.parse(t.paymentDay!);
        final weekday = dt.weekday;
        final val =
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
        weekdayMap[weekday] = (weekdayMap[weekday] ?? 0.0) + val;
      }

      String? weekdayPattern;
      if (weekdayMap.isNotEmpty && categoryTxs.length >= 2) {
        final maxWeekday =
            weekdayMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        const weekdayNames = [
          '',
          'segundas',
          'terças',
          'quartas',
          'quintas',
          'sextas',
          'sábados',
          'domingos'
        ];
        weekdayPattern = 'Você gasta mais nas ${weekdayNames[maxWeekday]}';
      }

      return {
        'category': e.key,
        'value': e.value,
        'name': findCategoryById(e.key)?['name'],
        'color': findCategoryById(e.key)?['color'],
        'weekdayPattern': weekdayPattern,
      };
    }).toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final totalCat =
        catData.fold<double>(0.0, (s, m) => s + (m['value'] as double));

    final parcelas = txs.where((t) => t.title.contains('Parcela')).toList();
    final totalParcelas = parcelas.fold<double>(
        0.0,
        (s, p) =>
            s + double.parse(p.value.replaceAll('.', '').replaceAll(',', '.')));

    final byType = <String, double>{};
    for (final t in txs.where((t) => t.type == TransactionType.despesa)) {
      final key = (t.paymentType ?? 'Outros').trim();
      final val =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      byType[key] = (byType[key] ?? 0.0) + val;
    }
    final payData = byType.entries
        .map((e) => {
              'paymentType': e.key,
              'value': e.value,
              'color': _getPaymentTypeColor(e.key),
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final payTotal =
        payData.fold<double>(0.0, (s, m) => s + (m['value'] as double));

    // Análise de pico de gastos por dia do mês
    final dayOfMonthMap = <int, double>{};
    for (final t in txs.where(
        (t) => t.type == TransactionType.despesa && t.paymentDay != null)) {
      final dt = DateTime.parse(t.paymentDay!);
      final day = dt.day;
      final val =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      dayOfMonthMap[day] = (dayOfMonthMap[day] ?? 0.0) + val;
    }

    String? peakDayMessage;
    if (dayOfMonthMap.isNotEmpty) {
      final peakDay =
          dayOfMonthMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final peakValue = dayOfMonthMap[peakDay]!;
      peakDayMessage =
          'Seu pico de gastos foi no dia $peakDay (${currency.format(peakValue)})';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Resumo Mensal',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 6.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: theme.primaryColor.withOpacity(.25)),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedMonth,
                      underline: const SizedBox.shrink(),
                      items: List.generate(
                          12,
                          (i) => DropdownMenuItem<int>(
                                value: i + 1,
                                child: Text(_monthsPt[i],
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12.sp)),
                              )),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedMonth = v);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(.25)),
                  ),
                  child: Text('$_selectedYear',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                _metricPill(theme,
                    label: 'Saldo',
                    value: saldo,
                    color: saldo >= 0
                        ? DefaultColors.greenDark
                        : DefaultColors.redDark,
                    currency: currency),
                SizedBox(width: 8.w),
                _metricPill(theme,
                    label: 'Receitas',
                    value: receitas,
                    color: DefaultColors.greenDark,
                    currency: currency),
                SizedBox(width: 8.w),
                _metricPill(theme,
                    label: 'Despesas',
                    value: despesas,
                    color: theme.primaryColor,
                    currency: currency),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            SizedBox(height: 8.h),
            if (peakDayMessage != null) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: DefaultColors.grey20.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights,
                        size: 16.sp,
                        color: theme.primaryColor.withOpacity(0.7)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        peakDayMessage,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            if (catData.isNotEmpty) ...[
              Text('Por categoria',
                  style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
              SizedBox(
                height: 180.h,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  legend: const Legend(isVisible: false),
                  series: <CircularSeries<Map<String, dynamic>, String>>[
                    PieSeries<Map<String, dynamic>, String>(
                      dataSource: catData,
                      xValueMapper: (e, _) => (e['name'] as String? ?? ''),
                      yValueMapper: (e, _) => (e['value'] as double),
                      pointColorMapper: (e, _) =>
                          (e['color'] as Color?) ??
                          theme.primaryColor.withOpacity(.3),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: false),
                      dataLabelMapper: (e, _) {
                        final v = (e['value'] as double);
                        final pct = totalCat > 0 ? (v / totalCat) * 100 : 0;
                        return '${(e['name'] as String? ?? '')}\n${pct.toStringAsFixed(0)}%';
                      },
                      explode: true,
                      explodeIndex: 0,
                      explodeOffset: '8%',
                      sortingOrder: SortingOrder.descending,
                      sortFieldValueMapper: (e, _) => (e['value'] as double),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: catData.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, color: DefaultColors.grey20.withOpacity(.5)),
                itemBuilder: (_, i) {
                  final e = catData[i];
                  final double v = e['value'] as double;
                  final double pct = totalCat > 0 ? (v / totalCat) * 100 : 0;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: (e['color'] as Color?) ??
                                theme.primaryColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (e['name'] as String? ?? ''),
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (e['weekdayPattern'] != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  e['weekdayPattern'] as String,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 10.sp, color: DefaultColors.grey)),
                        SizedBox(width: 8.w),
                        Text(currency.format(v),
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor)),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ] else ...[
              Text('Sem despesas categorizadas neste mês',
                  style: TextStyle(color: DefaultColors.grey, fontSize: 10.sp)),
              SizedBox(height: 12.h),
            ],
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            Text('Parcelas do mês (${parcelas.length})',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(parcelas.isEmpty ? 'Nenhuma parcela' : 'Total',
                    style:
                        TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
                Text(currency.format(totalParcelas),
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            if (parcelas.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parcelas.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, color: DefaultColors.grey20.withOpacity(.5)),
                itemBuilder: (_, i) {
                  final t = parcelas[i];
                  final v = double.parse(
                      t.value.replaceAll('.', '').replaceAll(',', '.'));
                  final String name = (() {
                    final m = RegExp(r'Parcela\s+(\d+)\s*:\s*(.+)')
                        .firstMatch(t.title);
                    if (m != null) {
                      final num = m.group(1);
                      final base = m.group(2);
                      return 'Parcela $num — $base';
                    }
                    return t.title;
                  })();
                  final String date = t.paymentDay != null
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(t.paymentDay!))
                      : '';
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              SizedBox(height: 4.h),
                              Text(date,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.grey)),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(currency.format(v),
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor)),
                      ],
                    ),
                  );
                },
              ),
            ],
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            if (payData.isNotEmpty) ...[
              Text('Por tipo de pagamento',
                  style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              SizedBox(
                height: 180.h,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  legend: const Legend(isVisible: false),
                  series: <CircularSeries<Map<String, dynamic>, String>>[
                    PieSeries<Map<String, dynamic>, String>(
                      dataSource: payData,
                      xValueMapper: (e, _) => (e['paymentType'] as String),
                      yValueMapper: (e, _) => (e['value'] as double),
                      pointColorMapper: (e, _) => (e['color'] as Color),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: false),
                      dataLabelMapper: (e, _) {
                        final v = (e['value'] as double);
                        final pct = payTotal > 0 ? (v / payTotal) * 100 : 0;
                        return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                      },
                      explode: true,
                      explodeIndex: 0,
                      explodeOffset: '8%',
                      sortingOrder: SortingOrder.descending,
                      sortFieldValueMapper: (e, _) => (e['value'] as double),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payData.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, color: DefaultColors.grey20.withOpacity(.5)),
                itemBuilder: (_, i) {
                  final e = payData[i];
                  final double v = e['value'] as double;
                  final double pct = payTotal > 0 ? (v / payTotal) * 100 : 0;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                              color: (e['color'] as Color),
                              shape: BoxShape.circle),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            (e['paymentType'] as String),
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 10.sp, color: DefaultColors.grey)),
                        SizedBox(width: 8.w),
                        Text(currency.format(v),
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor)),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              AdsBanner(),
              SizedBox(
                height: 10.h,
              ),
              // Contas fixas do mês
              Builder(builder: (context) {
                final fixedList = txs
                    .where((t) => t.title.startsWith('Conta fixa:'))
                    .toList()
                  ..sort((a, b) => DateTime.parse(a.paymentDay!)
                      .compareTo(DateTime.parse(b.paymentDay!)));
                if (fixedList.isEmpty) {
                  return Text('Sem contas fixas no mês',
                      style: TextStyle(
                          fontSize: 10.sp, color: DefaultColors.grey));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contas fixas do mês',
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 6.h),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: fixedList.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: DefaultColors.grey20.withOpacity(.5)),
                      itemBuilder: (_, i) {
                        final t = fixedList[i];
                        final v = double.parse(
                            t.value.replaceAll('.', '').replaceAll(',', '.'));
                        final date = t.paymentDay != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(t.paymentDay!))
                            : '';
                        final name = t.title.replaceFirst('Conta fixa: ', '');
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 4.h),
                                    Text(date,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: DefaultColors.grey)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(currency.format(v),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ] else ...[
              Text('Sem despesas por tipo neste mês',
                  style: TextStyle(color: DefaultColors.grey, fontSize: 10.sp)),
            ],
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPill(ThemeData theme,
      {required String label,
      required double value,
      required Color color,
      required NumberFormat currency}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
            SizedBox(height: 2.h),
            Text(currency.format(value),
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

extension on _MonthlySummaryPageState {
  Future<List<Map<String, dynamic>>> _fetchGoalDepositDetails() async {
    final goals = Get.find<GoalController>().goal;
    final DateTime start = DateTime(_selectedYear, _selectedMonth, 1);
    final DateTime end =
        DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    final List<Map<String, dynamic>> rows = [];
    for (final g in goals) {
      if (g.id == null) continue;
      try {
        final qs = await FirebaseFirestore.instance
            .collection('goals')
            .doc(g.id!)
            .collection('transactions')
            .where('isAddition', isEqualTo: true)
            .where('date', isGreaterThanOrEqualTo: start)
            .where('date', isLessThanOrEqualTo: end)
            .get();
        for (final d in qs.docs) {
          final data = d.data();
          final raw = data['date'];
          DateTime dt;
          if (raw is Timestamp) {
            dt = raw.toDate();
          } else if (raw is DateTime) {
            dt = raw;
          } else {
            continue;
          }
          rows.add({
            'goalId': g.id,
            'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'date': dt,
          });
        }
      } catch (_) {}
    }
    return rows;
  }
}
