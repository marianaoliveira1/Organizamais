// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

                // Gráficos
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
                          title: '${e['name']}',
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 180.h,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 26,
                                  centerSpaceColor: theme.scaffoldBackgroundColor,
                                  sections: chartData,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 26.w),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var item in data)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(
                                            color: item['color'] as Color,
                                            borderRadius: BorderRadius.circular(2.r),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            item['name'] as String,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Lista de categorias
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];
                          var categoryId = item['category'] as int;
                          var valor = item['value'] as double;
                          var percentual = (valor / totalValue * 100);

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
                                      color: selectedCategoryId.value == categoryId ? (item['color'] as Color).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          item['icon'] as String,
                                          width: 30.w,
                                          height: 30.h,
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
