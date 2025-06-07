// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/pages/monthy_analsis/widgtes/monthly_financial_chart.dart'
    show MonthlyFinancialChart;

import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';

import 'widgtes/financial_summary_cards.dart';
import 'widgtes/widget_category_analise.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.h,
            ),
            child: Column(
              children: [
                FinancialSummaryCards(),
                MonthlyFinancialChart(),
                Obx(() {
                  var filteredTransactions = controller.transactionsAno
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
                              .where((element) => element.category == e)
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
                          "icon": findCategoryById(
                              e)?['icon'], // Adicionado para acessar o ícone
                        },
                      )
                      .toList();

                  // Ordenar os dados por valor (decrescente)
                  data.sort((a, b) =>
                      (b['value'] as double).compareTo(a['value'] as double));

                  double totalValue = data.fold(
                    0.0,
                    (previousValue, element) =>
                        previousValue + (element['value'] as double),
                  );

                  // Criar as seções do gráfico sem ícones (apenas cores)
                  var chartData = data
                      .map(
                        (e) => PieChartSectionData(
                          value: e['value'] as double,
                          color: e['color'] as Color,
                          title: '', // Sem título
                          radius: 50,
                          showTitle: false,
                          badgePositionPercentageOffset: 0.9,
                        ),
                      )
                      .toList();

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma despesa registrada para exibir o gráfico.",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DefaultTextGraphic(
                              text: "Por categoria",
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: SizedBox(
                                height: 180.h,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 26,
                                    centerSpaceColor: theme.cardColor,
                                    sections: chartData,
                                  ),
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
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
