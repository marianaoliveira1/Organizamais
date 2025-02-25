// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
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
              var categories = filteredTransactions.map((e) => e.category).toSet().toList();

              var data = categories
                  .map(
                    (e) => {
                      "chart": PieChartSectionData(
                        value: filteredTransactions.where((element) => element.category == e).fold(
                          0,
                          (previousValue, element) {
                            // Remove os pontos e troca vírgula por ponto para corrigir o parse
                            return (previousValue ?? 0) + double.parse(element.value.replaceAll('.', '').replaceAll(',', '.'));
                          },
                        ),
                        color: findCategoryById(e)?['color'],
                        title: '${findCategoryById(e)?['name']}',
                        radius: 50,
                        showTitle: false,
                      ),
                      "icon": findCategoryById(e)?['icon'],
                    },
                  )
                  .toList();

              double totalValue = data.fold(
                0,
                (previousValue, element) => previousValue + (element['chart']?.value ?? 0),
              );

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
                  SizedBox(
                    height: 180.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 26,
                              centerSpaceColor: theme.scaffoldBackgroundColor,
                              sections: data.map((e) => e['chart']).toList().cast<PieChartSectionData>(),
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
                                          color: item['chart']?.color,
                                          borderRadius: BorderRadius.circular(2.r),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          item['chart']?.title ?? '',
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
                  ),
                  SizedBox(height: 20.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var item = data[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Row(
                          children: [
                            Image.asset(
                              item['icon'] ?? '',
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['chart']?.title ?? '',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "${((item['chart']?.value ?? 0) / totalValue * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: DefaultColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "R\$${item['chart']?.value.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
