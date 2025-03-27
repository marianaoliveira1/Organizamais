// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/graphics/graphics_page2.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController = Get.put(TransactionController());

    // Formatador de moeda brasileira
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Formatador de data
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dayFormatter = DateFormat('dd');

    // Variável observável para controlar a categoria selecionada
    final selectedCategoryId = RxnInt(null);

    // Lista de meses
    List<String> getAllMonths() {
      final months = [
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
      return months;
    }

    // Inicializa com o mês atual
    final selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();

      if (selectedMonth.value.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String monthName = getAllMonths()[transactionDate.month - 1];
          return monthName == selectedMonth.value;
        }).toList();
      }

      return despesas;
    }

    // Obter transações para uma categoria específica
    List<TransactionModel> getTransactionsByCategory(int categoryId) {
      var filteredTransactions = getFilteredTransactions();
      return filteredTransactions.where((transaction) => transaction.category == categoryId).toList();
    }

    // Função para gerar dados para o gráfico Sparkline com todos os dias do mês
    Map<String, dynamic> getSparklineData() {
      var filteredTransactions = getFilteredTransactions();

      // Determinar o mês e ano selecionados
      int selectedMonthIndex = selectedMonth.value.isEmpty ? DateTime.now().month - 1 : getAllMonths().indexOf(selectedMonth.value);
      int selectedYear = DateTime.now().year;

      // Obter o número de dias no mês selecionado
      int daysInMonth = DateTime(selectedYear, selectedMonthIndex + 1 + 1, 0).day;

      // Criar um mapa para todos os dias do mês, inicializados com zero
      Map<String, double> dailyTotals = {};
      for (int i = 1; i <= daysInMonth; i++) {
        String day = i.toString().padLeft(2, '0');
        dailyTotals[day] = 0;
      }

      // Preencher com dados reais das transações
      for (var transaction in filteredTransactions) {
        if (transaction.paymentDay != null) {
          DateTime date = DateTime.parse(transaction.paymentDay!);
          String dayKey = dayFormatter.format(date);
          double value = double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'));

          if (dailyTotals.containsKey(dayKey)) {
            dailyTotals[dayKey] = dailyTotals[dayKey]! + value;
          }
        }
      }

      // Ordenar as chaves (dias) numericamente
      List<String> sortedKeys = dailyTotals.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      // Criar listas para o gráfico sparkline
      List<double> sparklineData = [];
      List<String> labels = [];
      List<DateTime> dates = [];
      List<double> values = [];

      for (var day in sortedKeys) {
        sparklineData.add(dailyTotals[day]!);
        labels.add(day);

        // Criar uma data completa para cada dia
        dates.add(DateTime(selectedYear, selectedMonthIndex + 1, int.parse(day)));
        values.add(dailyTotals[day]!);
      }

      return {
        'data': sparklineData,
        'labels': labels,
        'dates': dates,
        'values': values,
      };
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Lista de meses
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: getAllMonths().length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final month = getAllMonths()[index];

                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            if (selectedMonth.value == month) {
                              selectedMonth.value = '';
                            } else {
                              selectedMonth.value = month;
                            }
                            // Resetar a categoria selecionada quando mudar de mês
                            selectedCategoryId.value = null;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: selectedMonth.value == month ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              month,
                              style: TextStyle(
                                color: selectedMonth.value == month ? theme.primaryColor : DefaultColors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Gráfico de linha Sparkline com smoothing
                Obx(() {
                  var sparklineData = getSparklineData();
                  List<double> data = sparklineData['data'];
                  List<String> labels = sparklineData['labels'];

                  if (data.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20.h),
                      child: Center(
                        child: Text(
                          "",
                          style: TextStyle(
                            color: DefaultColors.grey,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextGraphic(
                          text: "Despesas diárias",
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Coluna com os valores (vertical)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                5,
                                (index) {
                                  double maxValue = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0;
                                  double stepValue = maxValue / 4;
                                  double value = maxValue - (stepValue * index);

                                  return Container(
                                    height: 24.h,
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(bottom: index == 4 ? 0 : 4.h),
                                    child: Text(
                                      currencyFormatter.format(value),
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: DefaultColors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(width: 8.w),

                            // Área principal do gráfico
                            Expanded(
                              child: Column(
                                children: [
                                  // Gráfico Sparkline com smoothing habilitado
                                  SizedBox(
                                    height: 120.h,
                                    child: Sparkline(
                                      data: data,
                                      lineWidth: 3.0,
                                      lineColor: DefaultColors.green,
                                      enableThreshold: false,
                                      sharpCorners: false, // Desativa cantos afiados para um efeito mais suave
                                      kLine: [
                                        2.0
                                      ], // Aumenta o fator de suavização
                                      fillMode: FillMode.below,
                                      fillGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          DefaultColors.green.withOpacity(0.3),
                                          DefaultColors.green.withOpacity(0.1),
                                        ],
                                      ),
                                      enableGridLines: true,
                                      gridLineColor: DefaultColors.grey.withOpacity(0.2),
                                      gridLineAmount: 4,
                                      gridLineLabelPrecision: 0,
                                      max: data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) * 1.2 : 100,
                                      averageLine: false,
                                      useCubicSmoothing: true, // Usa suavização cúbica
                                      cubicSmoothingFactor: 0.2, // Fator de suavização cúbica
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // Mostra todos os dias do mês de 1 até o último dia
                                  SizedBox(
                                    height: 1.h,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: labels.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: 30.w,
                                          alignment: Alignment.center,
                                          child: Text(
                                            labels[index],
                                            style: TextStyle(
                                              fontSize: 0.sp,
                                              color: DefaultColors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                          labels.length,
                                          (index) => Text(
                                            labels[index],
                                            style: TextStyle(
                                              fontSize: 5.sp,
                                              color: DefaultColors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Gráficos de categorias (modificado para adicionar ícones)
                Obx(() {
                  var filteredTransactions = getFilteredTransactions();
                  var categories = filteredTransactions.map((e) => e.category).where((e) => e != null).toSet().toList().cast<int>();

                  var data = categories
                      .map(
                        (e) => {
                          "category": e,
                          "value": filteredTransactions.where((element) => element.category == e).fold<double>(
                            0.0,
                            (previousValue, element) {
                              // Remove os pontos e troca vírgula por ponto para corrigir o parse
                              return previousValue + double.parse(element.value.replaceAll('.', '').replaceAll(',', '.'));
                            },
                          ),
                          "name": findCategoryById(e)?['name'],
                          "color": findCategoryById(e)?['color'],
                          "icon": findCategoryById(e)?['icon'], // Adicionado para acessar o ícone
                        },
                      )
                      .toList();

                  // Ordenar os dados por valor (decrescente)
                  data.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

                  double totalValue = data.fold(
                    0.0,
                    (previousValue, element) => previousValue + (element['value'] as double),
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
                              text: "Despesas por Categoria",
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
                            WidgetListCategoryGraphics(
                              data: data,
                              totalValue: totalValue,
                              selectedCategoryId: selectedCategoryId,
                              theme: theme,
                              currencyFormatter: currencyFormatter,
                              dateFormatter: dateFormatter,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                GraphicsPage2(
                  selectedMonth: selectedMonth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultTextGraphic extends StatelessWidget {
  final String text;
  const DefaultTextGraphic({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: theme.primaryColor,
      ),
    );
  }
}

class WidgetListCategoryGraphics extends StatelessWidget {
  const WidgetListCategoryGraphics({
    super.key,
    required this.data,
    required this.totalValue,
    required this.selectedCategoryId,
    required this.theme,
    required this.currencyFormatter,
    required this.dateFormatter,
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final RxnInt selectedCategoryId;
  final ThemeData theme;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        var categoryId = item['category'] as int;
        var valor = item['value'] as double;
        var percentual = (valor / totalValue * 100);
        var categoryColor = item['color'] as Color;
        var categoryIcon = item['icon'] as String?; // Obtém o ícone da categoria

        return Column(
          children: [
            // Item da categoria - Adicionado ícone
            GestureDetector(
              onTap: () {
                if (selectedCategoryId.value == categoryId) {
                  selectedCategoryId.value = null;
                } else {
                  selectedCategoryId.value = categoryId;
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: selectedCategoryId.value == categoryId ? categoryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // ALTERAÇÃO: Adiciona ícone da categoria
                      Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            categoryIcon ?? 'assets/icons/category.png',
                            width: 20.w,
                            height: 20.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Text(
                              "${percentual.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(valor),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            selectedCategoryId.value == categoryId ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: DefaultColors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de transações da categoria expandida
            Obx(
              () {
                if (selectedCategoryId.value != categoryId) {
                  return const SizedBox();
                }

                var categoryTransactions = getTransactionsByCategory(categoryId);
                categoryTransactions.sort((a, b) {
                  if (a.paymentDay == null || b.paymentDay == null) return 0;
                  return DateTime.parse(b.paymentDay!).compareTo(DateTime.parse(a.paymentDay!));
                });

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.h,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detalhes das Transações",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryTransactions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: DefaultColors.grey20.withOpacity(.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          var transaction = categoryTransactions[index];
                          var transactionValue = double.parse(
                            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
                          );

                          String formattedDate = transaction.paymentDay != null
                              ? dateFormatter.format(
                                  DateTime.parse(transaction.paymentDay!),
                                )
                              : "Data não informada";

                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 130.w,
                                      child: Text(
                                        transaction.title,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: theme.primaryColor,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6.h,
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DefaultColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormatter.format(transactionValue),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColor,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    SizedBox(
                                      width: 120.w,
                                      child: Text(
                                        transaction.paymentType ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: DefaultColors.grey,
                                          letterSpacing: -0.5,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      if (categoryTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Text(
                              "Nenhuma transação encontrada",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Reimplementação da função getTransactionsByCategory para uso na classe WidgetListCategoryGraphics
  List<TransactionModel> getTransactionsByCategory(int categoryId) {
    final TransactionController transactionController = Get.find<TransactionController>();
    List<String> getAllMonths() {
      final months = [
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
      return months;
    }

    final selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();

      if (selectedMonth.value.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String monthName = getAllMonths()[transactionDate.month - 1];
          return monthName == selectedMonth.value;
        }).toList();
      }
      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions.where((transaction) => transaction.category == categoryId).toList();
  }
}
