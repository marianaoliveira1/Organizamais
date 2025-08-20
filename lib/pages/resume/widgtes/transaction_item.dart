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
    final controller = Get.find<TransactionController>();

    // Verificar se é uma transação futura
    final transactionDate = DateTime.parse(transaction.paymentDay!);
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(transactionDate, today);
    final isFuture = transactionDate.isAfter(today) && !isToday;

    final String? installmentLabel = _computeInstallmentLabel(
      controller.transaction,
      transaction.title,
    );

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
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone circular
                Center(
                  child: Image.asset(
                    category?['icon'] ?? 'assets/icon-category/default.png',
                    width: 24.w,
                    height: 24.h,
                    opacity:
                        isFuture ? const AlwaysStoppedAnimation(0.4) : null,
                  ),
                ),

                SizedBox(width: 12.w),

                // Título + Categoria/descrição (+ Em breve)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // título
                      Text(
                        _titleWithInstallment(
                            transaction.title, controller.transaction),
                        style: TextStyle(
                          color: isFuture
                              ? DefaultColors.grey
                              : theme.primaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // linha com categoria + chip "Em breve"
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              category?['name'] ?? 'Categoria não encontrada',
                              style: TextStyle(
                                color: isFuture
                                    ? DefaultColors.grey.withOpacity(0.6)
                                    : DefaultColors.grey20,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFuture) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: DefaultColors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Em breve',
                                style: TextStyle(
                                  color: DefaultColors.grey,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),

                // Valor + paymentType (à direita)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatValue(transaction.value),
                      style: TextStyle(
                        color:
                            isFuture ? DefaultColors.grey : theme.primaryColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      transaction.paymentType,
                      style: TextStyle(
                        color: isFuture
                            ? DefaultColors.grey.withOpacity(0.6)
                            : DefaultColors.grey20,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
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

  // Gera o rótulo "Parcela X de Y" quando aplicável, baseado no padrão do título
  String? _computeInstallmentLabel(
      List<dynamic> allTransactions, String? title) {
    if (title == null) return null;
    final regex = RegExp(r'^Parcela\s+(\d+)\s*:\s*(.+)$');
    final match = regex.firstMatch(title);
    if (match == null) return null;
    final current = int.tryParse(match.group(1) ?? '') ?? 0;
    final baseTitle = match.group(2) ?? '';

    // Total de parcelas: conta quantas transações existem para o mesmo produto/baseTitle
    final total = allTransactions.where((t) {
      final String? tTitle = (t as dynamic).title as String?;
      if (tTitle == null) return false;
      final m = regex.firstMatch(tTitle);
      if (m == null) return false;
      final tBase = m.group(2) ?? '';
      return tBase == baseTitle;
    }).length;
    if (total <= 0) return null;
    return 'Parcela $current de $total';
  }

  String _titleWithInstallment(String? title, List<dynamic> all) {
    final label = _computeInstallmentLabel(all, title);
    if (label == null) return title ?? '';
    // Se o título já é "Parcela N: Nome", substitui por "Parcela N de Y — Nome"
    final regex = RegExp(r'^Parcela\s+(\d+)\s*:\s*(.+)$');
    final match = title != null ? regex.firstMatch(title) : null;
    if (match == null) return title ?? '';
    final baseTitle = match.group(2) ?? '';
    return '$label — $baseTitle';
  }
}
