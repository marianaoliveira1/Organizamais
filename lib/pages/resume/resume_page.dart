// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';
import '../transaction/pages/category_page.dart';
import 'widgtes/text_not_transaction.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.h),
        child: SingleChildScrollView(
          child: SafeArea(
            child: _ResumeContent(),
          ),
        ),
      ),
    );
  }
}

class _ResumeContent extends StatelessWidget {
  _ResumeContent();

  final TransactionController _transactionController = Get.put(TransactionController());
  final RxString _selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;
  final NumberFormat _formatter = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  static List<String> getAllMonths() => [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthSelector(),
        SizedBox(height: 20.h),
        _buildTransactionsList(context),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: getAllMonths().length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) => _buildMonthItem(context, getAllMonths()[index]),
      ),
    );
  }

  Widget _buildMonthItem(BuildContext context, String month) {
    return Obx(
      () => GestureDetector(
        onTap: () => _selectedMonth.value = _selectedMonth.value == month ? '' : month,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: _selectedMonth.value == month ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            month,
            style: TextStyle(
              color: _selectedMonth.value == month ? Theme.of(context).primaryColor : DefaultColors.grey,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return Obx(() {
      if (_transactionController.transaction.isEmpty) {
        return const DefaultTextNotTransaction();
      }

      final groupedTransactions = _groupTransactionsByDate(_transactionController.transaction);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          String date = groupedTransactions.keys.elementAt(index);
          List transactions = groupedTransactions[date]!;
          return _buildDateSection(context, date, transactions);
        },
      );
    });
  }

  Widget _buildDateSection(BuildContext context, String date, List transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            color: DefaultColors.grey,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 14.h),
        ...transactions.map((transaction) => _buildTransactionItem(context, transaction)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic transaction) {
    final category = categories_expenses.firstWhereOrNull(
      (element) => element['id'] == transaction.category,
    );
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onLongPress: () => _showDeleteConfirmationDialog(
            context,
            transaction,
          ),
          onTap: () => Get.to(
            () => TransactionPage(
              transaction: transaction,
              overrideTransactionSalvar: (transaction) {
                _transactionController.updateTransaction(transaction);
              },
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 16.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      category?['icon'] ?? 'assets/icon-category/default.png',
                      width: 30.w,
                      height: 30.h,
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150.w,
                          child: Text(
                            transaction.title,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true, // Permite a quebra de linha
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        Text(
                          category?['name'] ?? 'Categoria não encontrada',
                          style: TextStyle(
                            color: DefaultColors.grey20,
                            fontSize: 11.sp,
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
                    Text(
                      _formatValue(transaction.value),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      transaction.paymentType,
                      style: TextStyle(
                        color: DefaultColors.grey20,
                        fontSize: 11.sp,
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
              _transactionController.deleteTransaction(transaction.id!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Map<String, List<dynamic>> _groupTransactionsByDate(List transactions) {
    Map<String, List<dynamic>> grouped = {};

    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.paymentDay!);

      if (_selectedMonth.value.isNotEmpty) {
        String monthName = getAllMonths()[transactionDate.month - 1];
        if (monthName != _selectedMonth.value) continue;
      }

      String relativeDate = _getRelativeDate(transaction.paymentDay!);
      grouped.putIfAbsent(relativeDate, () => []).add(transaction);
    }

    // Sort transactions by date (newest first)
    grouped.forEach(
      (_, transactions) => transactions.sort(
        (a, b) => DateTime.parse(b.paymentDay!).compareTo(
          DateTime.parse(a.paymentDay!),
        ),
      ),
    );

    return grouped;
  }

  String _getRelativeDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) return 'Hoje';
    if (DateUtils.isSameDay(
      date,
      now.subtract(
        const Duration(days: 1),
      ),
    )) return 'Ontem';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      double? doubleValue = double.tryParse(
        value.replaceAll('.', '').replaceAll(',', '.'),
      );
      return doubleValue != null ? _formatter.format(doubleValue) : _formatter.format(0);
    } else if (value is num) {
      return _formatter.format(value);
    }
    return _formatter.format(0);
  }
}
