import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../model/transaction_model.dart';
import '../../../controller/transaction_controller.dart';
import '../../transaction/transaction_page.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Color color;
  final NumberFormat formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  TransactionCard({
    super.key,
    required this.transaction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Corrige o parse removendo separadores de milhar e trocando vírgula por ponto
    double valueDouble = double.tryParse(
          transaction.value.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
    String formattedValue = formatter.format(valueDouble);

    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Get.to(
        () => TransactionPage(
          transaction: transaction,
          overrideTransactionSalvar: (transaction) {
            final controller = Get.find<TransactionController>();
            controller.updateTransaction(transaction);
          },
        ),
      ),
      child: Container(
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
      ),
    );
  }
}
