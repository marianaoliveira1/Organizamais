import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // <-- Import do intl
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionSection(
              transactionController,
              TransactionType.receita,
              'Entradas',
              Colors.green,
            ),
            SizedBox(
              height: 20.h,
            ),
            _buildTransactionSection(
              transactionController,
              TransactionType.despesa,
              'Saídas',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    TransactionController controller,
    TransactionType type,
    String title,
    Color color,
  ) {
    return Obx(
      () {
        var transactions = controller.transaction.where((t) => t.type == type).toList();
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
                    'Nenhuma transação registrada.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    // O 'spacing' não existe diretamente em Column, use SizedBox ou outra abordagem
                    children: transactions
                        .map((t) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _buildTransactionCard(t, color),
                            ))
                        .toList(),
                  ),
          ],
        );
      },
    );
  }

  // Formatter para valores em real com pontuação de milhar
  final NumberFormat formatter = NumberFormat.currency(
    locale: "pt_BR",
    symbol: "R\$",
  );

  Widget _buildTransactionCard(TransactionModel transaction, Color color) {
    // Converte o valor string para double e formata
    double valueDouble = double.tryParse(transaction.value) ?? 0.0;
    String formattedValue = formatter.format(valueDouble);

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
          Text(
            transaction.title,
            style: TextStyle(
              color: DefaultColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formattedValue, // Exibe o valor formatado, ex.: "R$ 1.000,00"
            style: TextStyle(
              color: DefaultColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
