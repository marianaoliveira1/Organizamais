// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

import 'package:organizamais/controller/transaction_controller.dart';
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

    // Função para gerar dados para o gráfico Sparkline
    Map<String, dynamic> getSparklineData() {
      var filteredTransactions = getFilteredTransactions();

      // Se não houver transações, retornar dados vazios
      if (filteredTransactions.isEmpty) {
        return {
          'data': <double>[],
          'labels': <String>[],
          'dates': <DateTime>[],
          'values': <double>[],
        };
      }

      // Ordenar as transações por data
      filteredTransactions.sort((a, b) {
        if (a.paymentDay == null || b.paymentDay == null) return 0;
        return DateTime.parse(a.paymentDay!).compareTo(DateTime.parse(b.paymentDay!));
      });

      // Agrupar transações por dia
      Map<String, double> dailyTotals = {};

      for (var transaction in filteredTransactions) {
        if (transaction.paymentDay != null) {
          DateTime date = DateTime.parse(transaction.paymentDay!);
          String dayKey = dayFormatter.format(date);
          double value = double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'));

          if (dailyTotals.containsKey(dayKey)) {
            dailyTotals[dayKey] = dailyTotals[dayKey]! + value;
          } else {
            dailyTotals[dayKey] = value;
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

        // Recuperar a data completa da primeira transação neste dia
        for (var transaction in filteredTransactions) {
          if (transaction.paymentDay != null) {
            DateTime date = DateTime.parse(transaction.paymentDay!);
            if (dayFormatter.format(date) == day) {
              dates.add(date);
              values.add(dailyTotals[day]!);
              break;
            }
          }
        }
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

                // Gráfico de linha Sparkline redesenhado com dias na horizontal
                Obx(() {
                  var sparklineData = getSparklineData();
                  List<double> data = sparklineData['data'];
                  List<String> labels = sparklineData['labels'];
                  List<DateTime> dates = sparklineData['dates'];
                  List<double> values = sparklineData['values'];

                  if (data.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20.h),
                      child: Center(
                        child: Text(
                          "Nenhuma despesa encontrada${selectedMonth.value.isNotEmpty ? ' para $selectedMonth' : ''}",
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
                        Text(
                          "Despesas Diárias - ${selectedMonth.value}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
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
                                        fontSize: 10.sp,
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
                                  // Gráfico Sparkline
                                  SizedBox(
                                    height: 120.h,
                                    child: Sparkline(
                                      data: data,
                                      lineWidth: 3.0,
                                      lineColor: DefaultColors.green,
                                      pointsMode: PointsMode.all,
                                      pointSize: 5.0,
                                      pointColor: DefaultColors.green,
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
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // Dias na parte inferior (horizontal)
                                  Container(
                                    height: 20.h,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          labels.length,
                                          (index) => Container(
                                            width: 40.w,
                                            alignment: Alignment.center,
                                            child: Text(
                                              labels[index],
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: DefaultColors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Lista de transações diárias
                        Container(
                          height: 120.h,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: dates.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormatter.format(dates[index]),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(values[index]),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Gráficos de categorias (modificado)
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
                          "icon": findCategoryById(e)?['icon'],
                        },
                      )
                      .toList();

                  // Ordenar os dados por valor (decrescente)
                  data.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

                  double totalValue = data.fold(
                    0.0,
                    (previousValue, element) => previousValue + (element['value'] as double),
                  );

                  // Criar as seções do gráfico após a ordenação
                  var chartData = data
                      .map(
                        (e) => PieChartSectionData(
                          value: e['value'] as double,
                          color: e['color'] as Color,
                          title: '',
                          radius: 50,
                          showTitle: false,
                        ),
                      )
                      .toList();

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma despesa encontrada${selectedMonth.value.isNotEmpty ? ' para $selectedMonth' : ''}",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 14.sp,
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
                            Text(
                              "Despesas por Categoria",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
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
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Lista de categorias com ícones coloridos
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];
                          var categoryId = item['category'] as int;
                          var valor = item['value'] as double;
                          var percentual = (valor / totalValue * 100);
                          var categoryColor = item['color'] as Color;

                          return Column(
                            children: [
                              // Item da categoria
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
                                        // Ícone colorido com a cor da categoria
                                        Container(
                                          width: 30.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                            color: categoryColor,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              item['icon'] as String,
                                              width: 20.w,
                                              height: 20.h,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 130.w,
                                                child: Text(
                                                  item['name'] as String,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
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
                                                  fontSize: 12.sp,
                                                  color: DefaultColors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          currencyFormatter.format(valor),
                                          style: TextStyle(
                                            fontSize: 14.sp,
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
                                  ),
                                ),
                              ),

                              // Lista de transações da categoria expandida
                              Obx(() {
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
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Detalhes das Transações",
                                        style: TextStyle(
                                          fontSize: 14.sp,
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
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        transaction.title,
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
                                                          fontWeight: FontWeight.w500,
                                                          color: theme.primaryColor,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 6.h,
                                                      ),
                                                      Text(
                                                        formattedDate,
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color: DefaultColors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    currencyFormatter.format(transactionValue),
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: theme.primaryColor,
                                                      letterSpacing: -0.5,
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
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
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
