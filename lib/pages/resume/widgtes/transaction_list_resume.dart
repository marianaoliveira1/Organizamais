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
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Center(child: DefaultTextNotTransaction()),
        );
      }

      // Ordena as transações da mais recente para a mais antiga
      final sortedTransactions = transactionController.transaction.toList()
        ..sort((a, b) => DateTime.parse(b.paymentDay!)
            .compareTo(DateTime.parse(a.paymentDay!)));

      final groupedTransactions = _groupTransactionsByDate(sortedTransactions);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          String date = groupedTransactions.keys.elementAt(index);
          List transactions = groupedTransactions[date]!;
          return DateSectionResume(
            key: ValueKey('date_$date'),
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
    final int currentYear = DateTime.now().year;
    final today = DateTime.now();

    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.paymentDay!);

      // Filtra apenas transações do ano atual
      if (transactionDate.year != currentYear) continue;

      if (selectedMonth.value.isNotEmpty) {
        String monthName =
            ResumeContent.getAllMonths()[transactionDate.month - 1];
        if (monthName != selectedMonth.value) continue;
      }

      String relativeDate = _getRelativeDate(transaction.paymentDay!);
      grouped.putIfAbsent(relativeDate, () => []).add(transaction);
    }

    // Ordena as datas das transações
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseRelativeDate(a);
        DateTime dateB = _parseRelativeDate(b);

        // Colocar datas futuras no final
        bool aIsFuture =
            dateA.isAfter(today) && !DateUtils.isSameDay(dateA, today);
        bool bIsFuture =
            dateB.isAfter(today) && !DateUtils.isSameDay(dateB, today);

        if (aIsFuture && !bIsFuture)
          return 1; // a é futuro, b não -> a vai depois
        if (!aIsFuture && bIsFuture)
          return -1; // a não é futuro, b é -> a vai antes

        // Se ambos são futuros, ordena cronologicamente (mais próximo primeiro)
        // Se ambos são passados, ordena por mais recente primeiro
        if (aIsFuture && bIsFuture) {
          return dateA.compareTo(dateB); // Futuro: mais próximo primeiro
        } else {
          return dateB.compareTo(dateA); // Passado: mais recente primeiro
        }
      });

    Map<String, List<dynamic>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  DateTime _parseRelativeDate(String relativeDate) {
    DateTime now = DateTime.now();

    if (relativeDate == 'Hoje') {
      return now;
    } else if (relativeDate == 'Ontem') {
      return now.subtract(const Duration(days: 1));
    } else if (relativeDate == 'Antes de ontem') {
      return now.subtract(const Duration(days: 2));
    } else if (relativeDate == 'Amanhã') {
      return now.add(const Duration(days: 1));
    } else if (relativeDate == 'Depois de amanhã') {
      return now.add(const Duration(days: 2));
    } else if (relativeDate.contains('dias atrás')) {
      // Extrai o número de dias (ex: "3 dias atrás" -> 3)
      final match = RegExp(r'(\d+) dias atrás').firstMatch(relativeDate);
      if (match != null) {
        int days = int.parse(match.group(1)!);
        return now.subtract(Duration(days: days));
      }
    } else if (relativeDate.contains('Daqui')) {
      // Extrai o número de dias (ex: "Daqui 3 dias" -> 3)
      final match = RegExp(r'Daqui (\d+) dias').firstMatch(relativeDate);
      if (match != null) {
        int days = int.parse(match.group(1)!);
        return now.add(Duration(days: days));
      }
    }

    // Se não é nenhuma das opções acima, tenta fazer parse da data
    try {
      return DateFormat('dd/MM/yyyy').parse(relativeDate);
    } catch (e) {
      return now; // Fallback para hoje se não conseguir fazer parse
    }
  }

  String _getRelativeDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();

    // Calcular diferença em dias
    int differenceInDays =
        date.difference(DateTime(now.year, now.month, now.day)).inDays;

    // Datas passadas
    if (differenceInDays == 0) return 'Hoje';
    if (differenceInDays == -1) return 'Ontem';
    if (differenceInDays == -2) return 'Antes de ontem';
    if (differenceInDays >= -5 && differenceInDays <= -3) {
      return '${differenceInDays.abs()} dias atrás';
    }

    // Datas futuras
    if (differenceInDays == 1) return 'Amanhã';
    if (differenceInDays == 2) return 'Depois de amanhã';
    if (differenceInDays >= 3 && differenceInDays <= 5) {
      return 'Daqui $differenceInDays dias';
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }
}
