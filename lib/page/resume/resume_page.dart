import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/utils/color.dart';
import 'package:intl/intl.dart';

import '../transaction/pages/ category.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());
    final Color primaryColor = Colors.blue;

    // Função para formatar a data
    String formatDate(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    }

    // Função para formatar o valor monetário
    String formatValue(dynamic value) {
      if (value is String) {
        return 'R\$ ${double.parse(value).toStringAsFixed(2)}';
      } else if (value is num) {
        return 'R\$ ${value.toStringAsFixed(2)}';
      }
      return 'R\$ 0.00';
    }

    // Função para agrupar e ordenar transações por data
    Map<String, List<dynamic>> groupTransactionsByDate(List transactions) {
      Map<String, List<dynamic>> grouped = {};

      // Primeiro, agrupa as transações por data
      for (var transaction in transactions) {
        String formattedDate = formatDate(transaction.paymentDay);
        if (!grouped.containsKey(formattedDate)) {
          grouped[formattedDate] = [];
        }
        grouped[formattedDate]!.add(transaction);
      }

      // Ordena as transações dentro de cada grupo por data/hora (mais recente primeiro)
      grouped.forEach((date, transactions) {
        transactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.paymentDay);
          DateTime dateB = DateTime.parse(b.paymentDay);
          return dateB.compareTo(dateA);
        });
      });

      // Ordena os grupos de data (dias mais recentes primeiro)
      return Map.fromEntries(grouped.entries.toList()
        ..sort((a, b) {
          DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        }));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                        color: primaryColor,
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
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
                            // Formata a hora para exibição
                            final DateTime transactionTime = DateTime.parse(transaction.paymentDay);
                            final String timeStr = DateFormat('HH:mm').format(transactionTime);

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 16.w,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    categories_expenses.firstWhere((element) => element['id'] == transaction.category)['icon'],
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
                                              color: primaryColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 8.w),
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
                                    ),
                                  ),
                                  Text(
                                    formatValue(transaction.value),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
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
              })
            ],
          ),
        ),
      ),
    );
  }
}
