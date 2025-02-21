// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});

  final List<String> months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final TransactionController transactionController = Get.put(TransactionController());

    // Adiciona uma variável observável para o mês selecionado
    final selectedMonth = 0.obs; // Janeiro como padrão (0-based index)

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meses ScrollView
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  return Obx(() => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Remove o background
                            elevation: 0, // Remove a sombra
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(
                                color: selectedMonth.value == index ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                          onPressed: () => selectedMonth.value = index,
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color: selectedMonth.value == index ? theme.primaryColor : DefaultColors.grey, // Alterado para cinza
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),

            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TransactionSection(
                          controller: transactionController,
                          type: TransactionType.receita,
                          title: 'Entradas',
                          color: Colors.green,
                          selectedMonth: selectedMonth.value,
                        ),
                        SizedBox(height: 20.h),
                        TransactionSection(
                          controller: transactionController,
                          type: TransactionType.despesa,
                          title: 'Saídas',
                          color: Colors.red,
                          selectedMonth: selectedMonth.value,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  final NumberFormat formatter = NumberFormat.currency(
    locale: "pt_BR",
    symbol: "R\$",
  );
}

class TransactionSection extends StatelessWidget {
  final TransactionController controller;
  final TransactionType type;
  final String title;
  final Color color;
  final int selectedMonth;

  const TransactionSection({
    super.key,
    required this.controller,
    required this.type,
    required this.title,
    required this.color,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Filtra as transações por tipo e mês
      var transactions = controller.transaction.where((t) {
        bool matchesType = t.type == type;
        DateTime transactionDate = DateTime.parse(t.paymentDay ?? '');
        bool matchesMonth = transactionDate.month == (selectedMonth + 1);
        return matchesType && matchesMonth;
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: DefaultColors.grey,
            ),
          ),
          SizedBox(height: 10.h),
          transactions.isEmpty
              ? Text(
                  'Nenhuma transação registrada neste mês.',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: transactions
                      .map((t) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: TransactionCard(
                              transaction: t,
                              color: color,
                            ),
                          ))
                      .toList(),
                ),
        ],
      );
    });
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Color color;
  // Supondo que o 'formatter' seja acessível globalmente ou seja passado por parâmetro,
  // caso contrário, ajuste conforme necessário.
  final NumberFormat formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  TransactionCard({
    super.key,
    required this.transaction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double valueDouble = double.tryParse(transaction.value) ?? 0.0;
    String formattedValue = formatter.format(valueDouble);

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 16.h,
        horizontal: 12.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            transaction.title,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formattedValue,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
