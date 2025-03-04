// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

import '../transaction/pages/category_page.dart';
import 'widgtes/text_not_transaction.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
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

    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    String getRelativeDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();

      if (DateUtils.isSameDay(date, now)) {
        return 'Hoje';
      } else if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
        return 'Ontem';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }

    String formatValue(dynamic value) {
      if (value is String) {
        // Remove separadores de milhar e troca vírgula por ponto
        double? doubleValue = double.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
        return doubleValue != null ? formatter.format(doubleValue) : formatter.format(0);
      } else if (value is num) {
        return formatter.format(value);
      }
      return formatter.format(0);
    }

    Map<String, List<dynamic>> groupTransactionsByDate(List transactions) {
      Map<String, List<dynamic>> grouped = {};

      for (var transaction in transactions) {
        DateTime transactionDate = DateTime.parse(transaction.paymentDay!);

        // Filtrar por mês selecionado
        if (selectedMonth.value.isNotEmpty) {
          String monthName = getAllMonths()[transactionDate.month - 1];
          if (monthName != selectedMonth.value) {
            continue;
          }
        }

        String relativeDate = getRelativeDate(transaction.paymentDay!);
        if (!grouped.containsKey(relativeDate)) {
          grouped[relativeDate] = [];
        }
        grouped[relativeDate]!.add(transaction);
      }

      grouped.forEach((date, transactions) {
        transactions.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a.paymentDay!);
          DateTime dateTimeB = DateTime.parse(b.paymentDay!);
          return dateTimeB.compareTo(dateTimeA);
        });
      });

      return grouped;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
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

                // Lista de transações
                Obx(() {
                  if (transactionController.transaction.isEmpty) {
                    return const DefaultTextNotTransaction();
                  }

                  final groupedTransactions = groupTransactionsByDate(
                    transactionController.transaction,
                  );

                  if (groupedTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma transação encontrada para este período",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 10.h),
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      String date = groupedTransactions.keys.elementAt(index);
                      List transactions = groupedTransactions[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: DefaultColors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => SizedBox(height: 14.h),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];

                              return Material(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24.r),
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TransactionPage(
                                                transaction: transaction,
                                                overrideTransactionSalvar: (transaction) => {
                                                  transactionController.updateTransaction(transaction)
                                                },
                                              )),
                                    ),
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                      horizontal: 16.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          categories_expenses.firstWhere(
                                            (element) => element['id'] == transaction.category,
                                          )['icon'],
                                          width: 24.w,
                                          height: 24.h,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction.title,
                                                  style: TextStyle(
                                                    color: theme.primaryColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  categories_expenses.firstWhere(
                                                    (element) => element['id'] == transaction.category,
                                                  )['name'],
                                                  style: TextStyle(
                                                    color: DefaultColors.grey20,
                                                    fontSize: 11.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatValue(transaction.value),
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              transaction.paymentType.toString(),
                                              style: TextStyle(
                                                color: DefaultColors.grey20,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
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
