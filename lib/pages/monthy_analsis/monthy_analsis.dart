// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/utils/color.dart';

import 'package:organizamais/pages/transaction/pages/category_page.dart';

// import '../../ads_banner/ads_banner.dart';
import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';

import '../initial/widget/custom_drawer.dart';
import 'widget/financial_summary_cards.dart';
import 'widget/monthly_financial_chart.dart';
import 'widget/annual_balance_spline_chart.dart';
import 'widget/widget_category_analise.dart';
import '../resume/widgtes/text_not_transaction.dart';
import 'widget/payment_type_analise_page.dart';
import 'package:organizamais/widgetes/info_card.dart';
import 'widget/monthly_summary_page.dart';
import '../../ads_banner/ads_banner.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  // Dropdown: mês/ano
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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

  // Paleta auxiliar para tipos de pagamento (fallback)
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

  List<TransactionModel> _filterMonth(List<TransactionModel> all) {
    return all.where((t) {
      if (t.paymentDay == null) return false;
      final d = DateTime.parse(t.paymentDay!);
      return d.month == _selectedMonth && d.year == _selectedYear;
    }).toList();
  }

  List<TransactionModel> _filterYear(List<TransactionModel> all, int year) {
    final now = DateTime.now();
    return all.where((t) {
      if (t.paymentDay == null) return false;
      final d = DateTime.parse(t.paymentDay!);
      return d.year == year && d.isBefore(now);
    }).toList();
  }

  double _sumByType(List<TransactionModel> txs, TransactionType type) {
    return txs.where((t) => t.type == type).fold(
        0.0,
        (s, t) =>
            s + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
  }

  Future<double> _fetchGoalDepositsForMonth() async {
    final goals = Get.find<GoalController>().goal;
    if (goals.isEmpty) return 0.0;
    final DateTime start = DateTime(_selectedYear, _selectedMonth, 1);
    final DateTime end =
        DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    double total = 0.0;
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
          total += (d.data()['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {}
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Análise Anual',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Obx(() {
              final yearTransactions =
                  _filterYear(controller.transaction, _selectedYear);
              if (yearTransactions.isEmpty) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final List<int> years = [
                                2025,
                                2026,
                                2027,
                                2028,
                                2029,
                                2030
                              ];
                              final int year = years[index];
                              final bool selected = _selectedYear == year;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _selectedYear = year),
                                borderRadius: BorderRadius.circular(999.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 50.w),
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(999.r),
                                    border: Border.all(
                                      color: selected
                                          ? DefaultColors.greenDark
                                          : theme.primaryColor.withOpacity(.35),
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$year',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: Center(
                            child: DefaultTextNotTransaction(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                    ),
                    child: Column(
                      children: [
                        // Year selector (2025 / 2030) moved inside scroll
                        SizedBox(
                          height: 40.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final List<int> years = [
                                2025,
                                2026,
                                2027,
                                2028,
                                2029,
                                2030
                              ];
                              final int year = years[index];
                              final bool selected = _selectedYear == year;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _selectedYear = year),
                                borderRadius: BorderRadius.circular(999.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 50.w),
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(999.r),
                                    border: Border.all(
                                      color: selected
                                          ? DefaultColors.greenDark
                                          : theme.primaryColor.withOpacity(.35),
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$year',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Nova seção: Análise Mensal

                        FinancialSummaryCards(),

                        // Botão de acesso ao resumo mensal
                        InfoCard(
                          title: 'Resumo Mensal',
                          onTap: () async {
                            // Exibe anúncio de tela cheia e depois navega
                            try {
                              await AdsInterstitial.show();
                            } catch (_) {}
                            Get.to(() => MonthlySummaryPage(
                                  initialMonth: _selectedMonth,
                                  initialYear: _selectedYear,
                                ));
                          },
                          content: Row(
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Iconsax.calendar_1,
                                    color: theme.primaryColor, size: 18.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Veja receitas, despesas, parcelas e gráficos do mês',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: theme.primaryColor),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        MonthlyFinancialChart(),
                        SizedBox(height: 16.h),
                        AnnualBalanceSplineChart(),
                        SizedBox(height: 10.h),
                        // Por categoria e tipo (por ANO selecionado)
                        Builder(builder: (context) {
                          final filteredTransactions = yearTransactions
                              .where((e) => e.type == TransactionType.despesa)
                              .toList();
                          final categories = filteredTransactions
                              .map((e) => e.category)
                              .where((e) => e != null)
                              .toSet()
                              .toList()
                              .cast<int>();

                          var data = categories
                              .map(
                                (e) => {
                                  'category': e,
                                  'value': filteredTransactions
                                      .where((t) => t.category == e)
                                      .fold<double>(
                                        0.0,
                                        (prev, t) =>
                                            prev +
                                            double.parse(t.value
                                                .replaceAll('.', '')
                                                .replaceAll(',', '.')),
                                      ),
                                  'name': findCategoryById(e)?['name'],
                                  'color': findCategoryById(e)?['color'],
                                  'icon': findCategoryById(e)?['icon'],
                                },
                              )
                              .toList();

                          data.sort((a, b) => (b['value'] as double)
                              .compareTo(a['value'] as double));

                          final double totalValue = data.fold(
                            0.0,
                            (sum, m) => sum + (m['value'] as double),
                          );

                          if (data.isEmpty) {
                            final vh = MediaQuery.of(context).size.height;
                            return SizedBox(
                              height: vh * 0.7,
                              child: const Center(
                                child: DefaultTextNotTransaction(),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              SizedBox(height: 30.h),
                              InfoCard(
                                title: 'Por categoria',
                                onTap: () {
                                  Get.to(() => const CategoryPage());
                                },
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 180.h,
                                        child: SfCircularChart(
                                          margin: EdgeInsets.zero,
                                          legend: Legend(isVisible: false),
                                          series: <CircularSeries<
                                              Map<String, dynamic>, String>>[
                                            PieSeries<Map<String, dynamic>,
                                                String>(
                                              dataSource: data,
                                              xValueMapper: (e, _) =>
                                                  (e['name'] ?? '').toString(),
                                              yValueMapper: (e, _) =>
                                                  (e['value'] as double),
                                              pointColorMapper: (e, _) =>
                                                  (e['color'] as Color?) ??
                                                  Colors.grey.withOpacity(0.5),
                                              dataLabelMapper: (e, _) {
                                                final v =
                                                    (e['value'] as double);
                                                final pct = totalValue > 0
                                                    ? (v / totalValue) * 100
                                                    : 0;
                                                return '${(e['name'] ?? '').toString()}\n${pct.toStringAsFixed(0)}%';
                                              },
                                              dataLabelSettings:
                                                  const DataLabelSettings(
                                                      isVisible: false),
                                              explode: true,
                                              explodeIndex:
                                                  data.isEmpty ? null : 0,
                                              explodeOffset: '8%',
                                              sortingOrder:
                                                  SortingOrder.descending,
                                              sortFieldValueMapper: (e, _) =>
                                                  (e['value'] as double),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    WidgetCategoryAnalise(
                                      data: data,
                                      totalValue: totalValue,
                                      theme: theme,
                                      currencyFormatter: NumberFormat.currency(
                                        locale: 'pt_BR',
                                        symbol: 'R\$',
                                        decimalDigits: 2,
                                      ),
                                      monthName: '',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Por tipo de pagamento (ANUAL)
                              Builder(builder: (context) {
                                final payTypes = filteredTransactions
                                    .map((e) => e.paymentType)
                                    .where((e) => e != null)
                                    .toSet()
                                    .toList()
                                    .cast<String>();

                                final payData = payTypes
                                    .map((pt) => {
                                          'paymentType': pt,
                                          'value': filteredTransactions
                                              .where((t) =>
                                                  t.paymentType != null &&
                                                  t.paymentType!
                                                          .trim()
                                                          .toLowerCase() ==
                                                      pt.trim().toLowerCase())
                                              .fold<double>(
                                                0.0,
                                                (prev, t) =>
                                                    prev +
                                                    double.parse(
                                                      t.value
                                                          .replaceAll('.', '')
                                                          .replaceAll(',', '.'),
                                                    ),
                                              ),
                                          'color': _getPaymentTypeColor(pt),
                                        })
                                    .toList();

                                payData.sort((a, b) => (b['value'] as double)
                                    .compareTo(a['value'] as double));

                                final payTotal = payData.fold<double>(
                                  0.0,
                                  (prev, e) => prev + (e['value'] as double),
                                );

                                if (payData.isEmpty || payTotal <= 0) {
                                  return const SizedBox.shrink();
                                }

                                return InfoCard(
                                  title: 'Por tipo de pagamento',
                                  onTap: () {},
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          height: 180.h,
                                          child: SfCircularChart(
                                            margin: EdgeInsets.zero,
                                            legend: Legend(isVisible: false),
                                            series: <CircularSeries<
                                                Map<String, dynamic>, String>>[
                                              PieSeries<Map<String, dynamic>,
                                                  String>(
                                                dataSource: payData,
                                                xValueMapper: (e, _) =>
                                                    (e['paymentType']
                                                        as String),
                                                yValueMapper: (e, _) =>
                                                    (e['value'] as double),
                                                pointColorMapper: (e, _) =>
                                                    (e['color'] as Color),
                                                dataLabelMapper: (e, _) {
                                                  final v =
                                                      (e['value'] as double);
                                                  final pct = payTotal > 0
                                                      ? (v / payTotal) * 100
                                                      : 0;
                                                  return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                                                },
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: false),
                                                explode: true,
                                                explodeIndex:
                                                    payData.isEmpty ? null : 0,
                                                explodeOffset: '8%',
                                                sortingOrder:
                                                    SortingOrder.descending,
                                                sortFieldValueMapper: (e, _) =>
                                                    (e['value'] as double),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: payData.length,
                                        itemBuilder: (context, index) {
                                          final item = payData[index];
                                          final String pt =
                                              item['paymentType'] as String;
                                          final double val =
                                              item['value'] as double;
                                          final Color c =
                                              item['color'] as Color;
                                          final double perc =
                                              (val / payTotal) * 100;

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6.h,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Get.to(
                                                  () => PaymentTypeAnalysisPage(
                                                    paymentType: pt,
                                                    paymentColor: c,
                                                    totalValue: val,
                                                    percentual: perc,
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 20.w,
                                                    height: 20.h,
                                                    decoration: BoxDecoration(
                                                      color: c,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              9.r),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                pt,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: theme
                                                                      .primaryColor,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 8.w),
                                                            Text(
                                                              NumberFormat
                                                                  .currency(
                                                                locale: 'pt_BR',
                                                                symbol: 'R\$',
                                                                decimalDigits:
                                                                    2,
                                                              ).format(val),
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: theme
                                                                    .primaryColor,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 6.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '${perc.toStringAsFixed(0)}%',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    DefaultColors
                                                                        .grey,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 6.w),
                                                            Icon(
                                                              Iconsax
                                                                  .arrow_right_3,
                                                              size: 12.sp,
                                                              color:
                                                                  DefaultColors
                                                                      .grey,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                        SizedBox(
                          height: 20.h,
                        ),

                        AdsBanner(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
