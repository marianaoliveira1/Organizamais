import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: DefaultColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionSection(transactionController, TransactionType.receita, 'Entradas', Colors.green),
            const SizedBox(height: 20),
            _buildTransactionSection(transactionController, TransactionType.despesa, 'Saídas', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection(TransactionController controller, TransactionType type, String title, Color color) {
    return Obx(
      () {
        var transactions = controller.transaction.where((t) => t.type == type).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            transactions.isEmpty
                ? Text(
                    'Nenhuma transação registrada.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    spacing: 16.h,
                    children: transactions.map((t) => _buildTransactionCard(t, color)).toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, Color color) {
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
            'R\$ ${transaction.value}',
            style: TextStyle(
              color: DefaultColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
