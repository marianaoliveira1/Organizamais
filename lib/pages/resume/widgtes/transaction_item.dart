import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../transaction/pages/category_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

    // installmentLabel calculado, mas não utilizado diretamente na UI
    // final String? installmentLabel = _computeInstallmentLabel(
    //   controller.transaction,
    //   transaction.title,
    // );

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Slidable(
            key: ValueKey('txn-${transaction.id ?? transaction.title}'),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.60,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => Get.to(
                    () => TransactionPage(
                      transaction: transaction,
                      overrideTransactionSalvar: (updated) {
                        final controller = Get.find<TransactionController>();
                        controller.updateTransaction(updated);
                      },
                    ),
                  ),
                  backgroundColor: Colors.orange,
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                CustomSlidableAction(
                  onPressed: (_) =>
                      _showDeleteConfirmationDialog(context, transaction),
                  backgroundColor: Colors.red,
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Deletar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Slidable.of(context)?.close();
                _showActionModal(context, transaction);
              },
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícone circular
                    Center(
                      child: Image.asset(
                        category?['icon'] ?? 'assets/icon-category/default.png',
                        width: 30.w,
                        height: 30.h,
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
                                transaction, controller.transaction),
                            style: TextStyle(
                              color: isFuture
                                  ? DefaultColors.grey
                                  : theme.primaryColor,
                              fontSize: 14.sp,
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
                                  category?['name'] ??
                                      'Categoria não encontrada',
                                  style: TextStyle(
                                    color: isFuture
                                        ? DefaultColors.grey.withOpacity(0.6)
                                        : DefaultColors.grey20,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 2,
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
                                      fontSize: 11.sp,
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
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(builder: (context) {
                            final bool isReceita =
                                transaction.type == TransactionType.receita;
                            final String sign = isReceita ? '+' : '-';
                            final Color valueColor = isFuture
                                ? DefaultColors.grey
                                : (isReceita
                                    ? DefaultColors.greenDark
                                    : DefaultColors.redDark);
                            return Text(
                              '$sign ${_formatValue(transaction.value)}',
                              style: TextStyle(
                                color: valueColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            );
                          }),
                          SizedBox(height: 3.h),
                          Text(
                            transaction.paymentType,
                            style: TextStyle(
                              color: isFuture
                                  ? DefaultColors.grey.withOpacity(0.6)
                                  : DefaultColors.grey20,
                              fontSize: 12.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, dynamic transaction) {
    final theme = Theme.of(context);
    final String title = 'Excluir transação';
    final String subtitle =
        'Você poderá cadastrar novamente se precisar. Confirmar exclusão?';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: theme.primaryColor.withOpacity(0.06)),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        title: null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.primaryColor.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final controller = Get.find<TransactionController>();
                    controller.deleteTransaction(transaction.id!);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          )
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

  // Gera o rótulo "Parcela X de Y" limitado à SÉRIE correta: mesmo baseTitle,
  // paymentType normalizado e valor por parcela igual (tolerância de 1 centavo)
  String? _computeInstallmentLabelForTx(
      List<dynamic> allTransactions, dynamic tx) {
    final String? title = (tx as dynamic).title as String?;
    if (title == null) return null;
    final regex = RegExp(r'^Parcela\s+(\d+)(?:\s+de\s+(\d+))?[:\-]\s*(.+)');
    final match = regex.firstMatch(title);
    if (match == null) return null;
    final int current = int.tryParse(match.group(1) ?? '') ?? 0;
    final String baseTitle = match.group(3) ?? '';

    String normPay(String? s) => (s ?? '').trim().toLowerCase();
    double parseVal(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) {
        final cleaned = v
            .replaceAll('R\$', '')
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '.');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    final String payNorm = normPay((tx as dynamic).paymentType as String?);
    final double val = parseVal((tx as dynamic).value);

    final int total = allTransactions.where((t) {
      final String? tTitle = (t as dynamic).title as String?;
      if (tTitle == null) return false;
      final m = regex.firstMatch(tTitle);
      if (m == null) return false;
      final String tBase = m.group(3) ?? '';
      if (tBase != baseTitle) return false;
      if (normPay((t as dynamic).paymentType as String?) != payNorm) {
        return false;
      }
      final double tv = parseVal((t as dynamic).value);
      return (tv - val).abs() <= 0.01;
    }).length;

    if (total <= 0) return null;
    return 'Parcela $current de $total';
  }

  String _titleWithInstallment(dynamic tx, List<dynamic> all) {
    final String? title = (tx as dynamic).title as String?;
    final label = _computeInstallmentLabelForTx(all, tx);
    if (label == null) return title ?? '';
    final regex = RegExp(r'^Parcela\s+(\d+)(?:\s+de\s+(\d+))?[:\-]\s*(.+)');
    final match = title != null ? regex.firstMatch(title) : null;
    if (match == null) return title ?? '';
    final baseTitle = match.group(3) ?? '';
    return '$label — $baseTitle';
  }

  void _showActionModal(BuildContext context, dynamic transaction) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: DefaultColors.grey20.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.edit,
                    label: 'Editar',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      // Usar o contexto original, não o do modal
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          Get.to(
                            () => TransactionPage(
                              transaction: transaction,
                              overrideTransactionSalvar: (updated) {
                                controller.updateTransaction(updated);
                              },
                            ),
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.delete,
                    label: 'Deletar',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          _showDeleteConfirmationDialog(context, transaction);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.close,
                    label: 'Cancelar',
                    color: DefaultColors.grey20,
                    onTap: () => Navigator.of(modalContext).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: color,
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
