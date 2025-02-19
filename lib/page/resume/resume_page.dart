import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';

import 'package:intl/intl.dart';
import 'package:organizamais/utils/color.dart';

import '../transaction/pages/ category.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    }

    String formatValue(dynamic value) {
      if (value is String) {
        return 'R\$ ${double.tryParse(value)?.toStringAsFixed(2) ?? '0.00'}';
      } else if (value is num) {
        return 'R\$ ${value.toStringAsFixed(2)}';
      }
      return "R\$ 0.00";
    }

    Map<String, List<dynamic>> groupTransactionsByDate(List transactions) {
      Map<String, List<dynamic>> grouped = {};

      for (var transaction in transactions) {
        String formattedDate = formatDate(transaction.paymentDay);
        if (!grouped.containsKey(formattedDate)) {
          grouped[formattedDate] = [];
        }
        grouped[formattedDate]!.add(transaction);
      }

      grouped.forEach((date, transactions) {
        transactions.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a.paymentDay);
          DateTime dateTimeB = DateTime.parse(b.paymentDay);
          return dateTimeB.compareTo(dateTimeA); // Ordem decrescente
        });
      });

      return Map.fromEntries(grouped.entries.toList()
        ..sort((a, b) {
          DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        }));
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
              Obx(() {
                if (transactionController.transaction.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma transação encontrada",
                      style: TextStyle(
                        color: DefaultColors.black,
                        fontSize: 16.sp,
                      ),
                    ),
                  );
                }

                final groupedTransactions = groupTransactionsByDate(transactionController.transaction);

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
                            final DateTime transactionTime = DateTime.parse(transaction.paymentDay);
                            DateFormat('HH:mm').format(transactionTime);

                            return Container(
                              decoration: BoxDecoration(
                                color: DefaultColors.white,
                                borderRadius: BorderRadius.circular(
                                  24.r,
                                ),
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
              })
            ],
          ),
        ),
      ),
    );
  }
}
