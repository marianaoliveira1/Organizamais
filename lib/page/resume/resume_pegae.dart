import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../../utils/color.dart';
import '../transaction_page.dart/transaction_page.dart';

class ResumePage extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumo'),
        centerTitle: true,
        backgroundColor: DefaultColors.background,
      ),
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.all(16.h),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.transactions[index];
              return Dismissible(
                key: Key(transaction.id),
                background: Container(
                  decoration: BoxDecoration(
                    color: DefaultColors.red,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 16.w),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => controller.deleteTransaction(transaction.id),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    leading: _getTransactionIcon(transaction.type),
                    title: Text(
                      transaction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(transaction.date),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'R\$ ${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _getAmountColor(transaction.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            controller.loadTransactionForEdit(transaction.id);
                            Get.to(() => TransactionPage(
                                  transactionType: transaction.type,
                                  isEditing: true,
                                  transactionId: transaction.id,
                                ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionBottomSheet,
        child: Icon(Icons.add),
        backgroundColor: DefaultColors.red,
      ),
    );
  }

  Widget _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.receita:
        return CircleAvatar(
          backgroundColor: DefaultColors.green.withOpacity(0.2),
          child: Icon(Icons.add, color: DefaultColors.green),
        );
      case TransactionType.despesa:
        return CircleAvatar(
          backgroundColor: DefaultColors.red.withOpacity(0.2),
          child: Icon(Icons.remove, color: DefaultColors.red),
        );
      case TransactionType.transferencia:
        return CircleAvatar(
          backgroundColor: DefaultColors.grey.withOpacity(0.2),
          child: Icon(Icons.swap_horiz, color: DefaultColors.grey),
        );
    }
  }

  Color _getAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.receita:
        return DefaultColors.green;
      case TransactionType.despesa:
        return DefaultColors.red;
      case TransactionType.transferencia:
        return DefaultColors.grey;
    }
  }

  void _showTransactionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "O que você quer adicionar?",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionButton(
              "Receita",
              DefaultColors.green,
              Icons.add,
              () => Get.to(() => TransactionPage(transactionType: TransactionType.receita)),
            ),
            SizedBox(height: 10.h),
            _buildOptionButton(
              "Despesa",
              DefaultColors.red,
              Icons.remove,
              () => Get.to(() => TransactionPage(transactionType: TransactionType.despesa)),
            ),
            SizedBox(height: 10.h),
            _buildOptionButton(
              "Transferência",
              DefaultColors.grey,
              Icons.swap_horiz,
              () => Get.to(() => TransactionPage(transactionType: TransactionType.transferencia)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionButton(String title, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
