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

    // Verificar se é uma transação futura
    final transactionDate = DateTime.parse(transaction.paymentDay!);
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(transactionDate, today);
    final isFuture = transactionDate.isAfter(today) && !isToday;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onLongPress: () =>
              _showDeleteConfirmationDialog(context, transaction),
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
              horizontal: 14.w,
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
                      opacity:
                          isFuture ? const AlwaysStoppedAnimation(0.4) : null,
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
                              color: isFuture
                                  ? DefaultColors.grey
                                  : theme.primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: isFuture ? 80.w : 120.w,
                              child: Text(
                                category?['name'] ?? 'Categoria não encontrada',
                                style: TextStyle(
                                  color: isFuture
                                      ? DefaultColors.grey.withOpacity(0.6)
                                      : DefaultColors.grey20,
                                  fontSize: 10.sp,
                                ),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isFuture) ...[
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: DefaultColors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Em breve',
                                  style: TextStyle(
                                    color: DefaultColors.grey,
                                    fontSize: 7.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                          color: isFuture
                              ? DefaultColors.grey
                              : theme.primaryColor,
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
                          color: isFuture
                              ? DefaultColors.grey.withOpacity(0.6)
                              : DefaultColors.grey20,
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

  void _showDeleteConfirmationDialog(
      BuildContext context, dynamic transaction) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        content: Text(
            'Tem certeza que deseja excluir o cartão ${transaction.title}?'),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12.sp,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              'Excluir',
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 12.sp,
              ),
            ),
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
      return doubleValue != null
          ? formatter.format(doubleValue)
          : formatter.format(0);
    } else if (value is num) {
      return formatter.format(value);
    }
    return formatter.format(0);
  }
}
