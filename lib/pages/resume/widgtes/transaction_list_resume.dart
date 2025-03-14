// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';

import 'date_section_resume.dart';
import 'resume_content.dart';
import 'text_not_transaction.dart';

class TransactionsList extends StatelessWidget {
  final TransactionController transactionController;
  final RxString selectedMonth;
  final NumberFormat formatter;

  const TransactionsList({
    super.key,
    required this.transactionController,
    required this.selectedMonth,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (transactionController.transaction.isEmpty) {
        return const DefaultTextNotTransaction();
      }

      // Ordena as transações da mais recente para a mais antiga
      final sortedTransactions = transactionController.transaction.toList()..sort((a, b) => DateTime.parse(b.paymentDay!).compareTo(DateTime.parse(a.paymentDay!)));

      final groupedTransactions = _groupTransactionsByDate(sortedTransactions);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          String date = groupedTransactions.keys.elementAt(index);
          List transactions = groupedTransactions[date]!;
          return DateSectionResume(
            date: date,
            transactions: transactions,
            formatter: formatter,
          );
        },
      );
    });
  }

  Map<String, List<dynamic>> _groupTransactionsByDate(List transactions) {
    Map<String, List<dynamic>> grouped = {};

    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.paymentDay!);

      if (selectedMonth.value.isNotEmpty) {
        String monthName = ResumeContent.getAllMonths()[transactionDate.month - 1];
        if (monthName != selectedMonth.value) continue;
      }

      String relativeDate = _getRelativeDate(transaction.paymentDay!);
      grouped.putIfAbsent(relativeDate, () => []).add(transaction);
    }

    // Ordena as datas das transações (mais recente primeiro)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseRelativeDate(a);
        DateTime dateB = _parseRelativeDate(b);
        return dateB.compareTo(dateA);
      });

    Map<String, List<dynamic>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  DateTime _parseRelativeDate(String relativeDate) {
    if (relativeDate == 'Hoje') {
      return DateTime.now();
    } else if (relativeDate == 'Ontem') {
      return DateTime.now().subtract(const Duration(days: 1));
    } else {
      return DateFormat('dd/MM/yyyy').parse(relativeDate);
    }
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
}
