import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/utils/color.dart';

import '../transaction/pages/category_page.dart';

import 'widgtes/text_not_transaction.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());
    final selectedMonth = ''.obs;

    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

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
        double? doubleValue = double.tryParse(value);
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

    return Scaffold(
      backgroundColor: DefaultColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Lista de meses com visual melhorado
              Container(
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
                            color: selectedMonth.value == month ? DefaultColors.green : DefaultColors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: selectedMonth.value == month ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            month,
                            style: TextStyle(
                              color: selectedMonth.value == month ? DefaultColors.white : DefaultColors.grey,
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
                  return Text(
                    "Nenhuma transação encontrada para este período",
                    style: TextStyle(
                      color: DefaultColors.grey,
                      fontSize: 14.sp,
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

                            return Container(
                              decoration: BoxDecoration(
                                color: DefaultColors.white,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 12.w,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    categories_expenses.firstWhere(
                                      (element) => element['id'] == transaction.category,
                                    )['icon'],
                                    width: 28.w,
                                    height: 28.h,
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
                                              color: DefaultColors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            categories_expenses.firstWhere(
                                              (element) => element['id'] == transaction.category,
                                            )['name'],
                                            style: TextStyle(
                                              color: DefaultColors.greyLight,
                                              fontSize: 12.sp,
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
                                          color: DefaultColors.black,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        transaction.paymentType.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
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
              }),
            ],
          ),
        ),
      ),
    );
  }
}
