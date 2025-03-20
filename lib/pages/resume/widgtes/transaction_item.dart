import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../transaction/pages/category_page.dart';

class TransactionItem extends StatelessWidget {
  final dynamic transaction;
  final NumberFormat formatter;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final category = findCategoryById(transaction.category);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onLongPress: () => _showDeleteConfirmationDialog(context, transaction),
          onTap: () => Get.to(
            () => TransactionPage(
              transaction: transaction,
              overrideTransactionSalvar: (transaction) {
                final controller = Get.find<TransactionController>();
                controller.updateTransaction(transaction);
              },
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 12.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      category?['icon'] ?? 'assets/icon-category/default.png',
                      width: 28.w,
                      height: 28.h,
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120.w,
                          child: Text(
                            transaction.title,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 120.w,
                          child: Text(
                            category?['name'] ?? 'Categoria não encontrada',
                            style: TextStyle(
                              color: DefaultColors.grey20,
                              fontSize: 10.sp,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: Text(
                        _formatValue(transaction.value),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        transaction.paymentType,
                        style: TextStyle(
                          color: DefaultColors.grey20,
                          fontSize: 10.sp,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir o cartão ${transaction.title}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () {
              final controller = Get.find<TransactionController>();
              controller.deleteTransaction(transaction.id!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      double? doubleValue = double.tryParse(
        value.replaceAll('.', '').replaceAll(',', '.'),
      );
      return doubleValue != null ? formatter.format(doubleValue) : formatter.format(0);
    } else if (value is num) {
      return formatter.format(value);
    }
    return formatter.format(0);
  }
}
