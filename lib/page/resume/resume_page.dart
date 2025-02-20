import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/utils/color.dart';

import '../transaction/pages/ category.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());
    final selectedMonth = ''.obs;

    // Lista fixa de todos os meses do ano atual
    List<String> getAllMonths() {
      List<String> months = [];
      DateTime now = DateTime.now();
      for (int i = 0; i < 12; i++) {
        DateTime month = DateTime(now.year, i + 1);
        String monthYear = DateFormat('MMMM/yyyy', 'pt_BR').format(month);
        months.add(monthYear);
      }
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
        return 'R\$ ${double.tryParse(value)?.toStringAsFixed(2) ?? '0.00'}';
      } else if (value is num) {
        return 'R\$ ${value.toStringAsFixed(2)}';
      }
      return "R\$ 0.00";
    }

    Map<String, List<dynamic>> groupTransactionsByDate(List transactions, String selectedMonth) {
      Map<String, List<dynamic>> grouped = {};

      for (var transaction in transactions) {
        DateTime transactionDate = DateTime.parse(transaction.paymentDay);
        String transactionMonth = DateFormat('MMMM/yyyy', 'pt_BR').format(transactionDate);

        if (selectedMonth.isNotEmpty && transactionMonth != selectedMonth) {
          continue;
        }

        String relativeDate = getRelativeDate(transaction.paymentDay);
        if (!grouped.containsKey(relativeDate)) {
          grouped[relativeDate] = [];
        }
        grouped[relativeDate]!.add(transaction);
      }

      grouped.forEach((date, transactions) {
        transactions.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a.paymentDay);
          DateTime dateTimeB = DateTime.parse(b.paymentDay);
          return dateTimeB.compareTo(dateTimeA);
        });
      });

      return grouped;
    }

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Mês buttons in a horizontal scrollable list
              SizedBox(
                height: 40.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: getAllMonths().length,
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final month = getAllMonths()[index];
                    return Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedMonth.value == month ? DefaultColors.green : DefaultColors.white,
                            foregroundColor: selectedMonth.value == month ? DefaultColors.white : DefaultColors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () {
                            if (selectedMonth.value == month) {
                              selectedMonth.value = '';
                            } else {
                              selectedMonth.value = month;
                            }
                          },
                          child: Text(
                            month.split('/')[0].capitalize!, // Apenas o nome do mês com primeira letra maiúscula
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ));
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // Transactions list
              Obx(() {
                if (transactionController.transaction.isEmpty) {
                  return const DefaultTextNotTransaction();
                }

                final groupedTransactions = groupTransactionsByDate(transactionController.transaction, selectedMonth.value);

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
                  separatorBuilder: (context, index) => SizedBox(height: 20.h),
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
                                    categories_expenses.firstWhere((element) => element['id'] == transaction.category)['icon'],
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            categories_expenses.firstWhere((element) => element['id'] == transaction.category)['name'],
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
                                          color: transaction.type == 'receita' ? DefaultColors.green : DefaultColors.red,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
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

class DefaultTextNotTransaction extends StatelessWidget {
  const DefaultTextNotTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Nenhum lançamento no período",
          style: TextStyle(
            color: DefaultColors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Toque em ",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DefaultColors.green,
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: EdgeInsets.all(5.w),
              child: Icon(
                Iconsax.add,
                color: DefaultColors.white,
                size: 16.sp,
              ),
            ),
          ],
        ),
        Text(
          " para adicionar um lancamento ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: DefaultColors.grey,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
