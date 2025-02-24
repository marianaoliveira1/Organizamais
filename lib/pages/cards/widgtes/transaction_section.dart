import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import 'transaction_card.dart';

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
