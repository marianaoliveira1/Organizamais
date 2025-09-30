// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/utils/color.dart';

import 'package:organizamais/pages/transaction/pages/category_page.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';

import '../initial/widget/custom_drawer.dart';
import 'widget/financial_summary_cards.dart';
import 'widget/monthly_financial_chart.dart';
import 'widget/widget_category_analise.dart';
import '../resume/widgtes/text_not_transaction.dart';
import 'widget/payment_type_analise_page.dart';
import 'package:organizamais/widgetes/info_card.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  const MonthlyAnalysisPage({super.key});

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
              final hasAnyData = controller.transactionsAno.isNotEmpty;
              if (!hasAnyData) {
                return Expanded(
                  child: Center(
                    child: DefaultTextNotTransaction(),
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
                        FinancialSummaryCards(),
                        MonthlyFinancialChart(),
                        Obx(
                          () {
                            var filteredTransactions = controller
                                .transactionsAno
                                .where((e) => e.type == TransactionType.despesa)
                                .toList();
                            var categories = filteredTransactions
                                .map((e) => e.category)
                                .where((e) => e != null)
                                .toSet()
                                .toList()
                                .cast<int>();

                            var data = categories
                                .map(
                                  (e) => {
                                    "category": e,
                                    "value": filteredTransactions
                                        .where(
                                            (element) => element.category == e)
                                        .fold<double>(
                                      0.0,
                                      (previousValue, element) {
                                        // Remove os pontos e troca vírgula por ponto para corrigir o parse
                                        return previousValue +
                                            double.parse(element.value
                                                .replaceAll('.', '')
                                                .replaceAll(',', '.'));
                                      },
                                    ),
                                    "name": findCategoryById(e)?['name'],
                                    "color": findCategoryById(e)?['color'],
                                    "icon": findCategoryById(e)?[
                                        'icon'], // Adicionado para acessar o ícone
                                  },
                                )
                                .toList();

                            // Ordenar os dados por valor (decrescente)
                            data.sort((a, b) => (b['value'] as double)
                                .compareTo(a['value'] as double));

                            double totalValue = data.fold(
                              0.0,
                              (previousValue, element) =>
                                  previousValue + (element['value'] as double),
                            );

                            // Usaremos 'data' diretamente como fonte para o Syncfusion Pie

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
                                SizedBox(
                                  height: 30.h,
                                ),
                                InfoCard(
                                  title: 'Por categoria',
                                  onTap: () {
                                    Get.to(() => const CategoryPage());
                                  },
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
                                                dataSource: data,
                                                xValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['name'] ?? '')
                                                            .toString(),
                                                yValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['value'] as double),
                                                pointColorMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['color']
                                                            as Color?) ??
                                                        Colors.grey
                                                            .withOpacity(0.5),
                                                dataLabelMapper:
                                                    (Map<String, dynamic> e,
                                                        _) {
                                                  final double v =
                                                      (e['value'] as double);
                                                  final double pct =
                                                      totalValue > 0
                                                          ? (v / totalValue) *
                                                              100
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
                                                sortFieldValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
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
                                        currencyFormatter:
                                            NumberFormat.currency(
                                          locale: 'pt_BR',
                                          symbol: 'R\$',
                                          decimalDigits: 2,
                                        ),
                                        monthName: '',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                AdsBanner(),
                                SizedBox(
                                  height: 20.h,
                                ),
                                // Por tipo de pagamento (ANUAL)
                                Builder(
                                  builder: (context) {
                                    // Agrupar despesas anuais por tipo de pagamento
                                    final payTypes = filteredTransactions
                                        .map((e) => e.paymentType)
                                        .where((e) => e != null)
                                        .toSet()
                                        .toList()
                                        .cast<String>();

                                    final payData = payTypes
                                        .map(
                                          (pt) => {
                                            'paymentType': pt,
                                            'value': filteredTransactions
                                                .where(
                                                  (t) =>
                                                      t.paymentType != null &&
                                                      t.paymentType!
                                                              .trim()
                                                              .toLowerCase() ==
                                                          pt
                                                              .trim()
                                                              .toLowerCase(),
                                                )
                                                .fold<double>(
                                                  0.0,
                                                  (prev, t) =>
                                                      prev +
                                                      double.parse(
                                                        t.value
                                                            .replaceAll('.', '')
                                                            .replaceAll(
                                                                ',', '.'),
                                                      ),
                                                ),
                                            'color': _getPaymentTypeColor(pt),
                                          },
                                        )
                                        .toList();

                                    payData.sort(
                                      (a, b) => (b['value'] as double)
                                          .compareTo(a['value'] as double),
                                    );

                                    final payTotal = payData.fold<double>(
                                      0.0,
                                      (prev, e) =>
                                          prev + (e['value'] as double),
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
                                                legend:
                                                    Legend(isVisible: false),
                                                series: <CircularSeries<
                                                    Map<String, dynamic>,
                                                    String>>[
                                                  PieSeries<
                                                      Map<String, dynamic>,
                                                      String>(
                                                    dataSource: payData,
                                                    xValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['paymentType']
                                                                as String),
                                                    yValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['value']
                                                                as double),
                                                    pointColorMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['color']
                                                                as Color),
                                                    dataLabelMapper:
                                                        (Map<String, dynamic> e,
                                                            _) {
                                                      final double v =
                                                          (e['value']
                                                              as double);
                                                      final double pct =
                                                          payTotal > 0
                                                              ? (v / payTotal) *
                                                                  100
                                                              : 0;
                                                      return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                                                    },
                                                    dataLabelSettings:
                                                        const DataLabelSettings(
                                                            isVisible: false),
                                                    explode: true,
                                                    explodeIndex:
                                                        payData.isEmpty
                                                            ? null
                                                            : 0,
                                                    explodeOffset: '8%',
                                                    sortingOrder:
                                                        SortingOrder.descending,
                                                    sortFieldValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['value']
                                                                as double),
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
                                                      () =>
                                                          PaymentTypeAnalysisPage(
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: c,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                                    locale:
                                                                        'pt_BR',
                                                                    symbol:
                                                                        'R\$',
                                                                    decimalDigits:
                                                                        2,
                                                                  ).format(val),
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
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 6.h),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  '${perc.toStringAsFixed(0)}%',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
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
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        )
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
