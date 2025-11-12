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

      // Usa helper para incluir contas fixas no mês selecionado
      final parts = selectedMonth.value.split('/');
      final String monthName =
          parts.isNotEmpty ? parts[0] : selectedMonth.value;
      final int year = parts.length == 2
          ? int.tryParse(parts[1]) ?? DateTime.now().year
          : DateTime.now().year;
      final List<String> months = ResumeContent.getAllMonths();
      final int month = months.indexOf(monthName) + 1;

      final monthTransactions =
          transactionController.getTransactionsForMonth(year, month);

      // Cache de datas parseadas para ordenação mais eficiente
      final dateCache = <dynamic, DateTime>{};
      for (final t in monthTransactions) {
        if (t.paymentDay != null) {
          try {
            dateCache[t] = DateTime.parse(t.paymentDay!);
          } catch (_) {}
        }
      }

      monthTransactions.sort((a, b) {
        final dateA = dateCache[a];
        final dateB = dateCache[b];
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      final groupedTransactions =
          _groupTransactionsByDate(monthTransactions, dateCache);

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

  Map<String, List<dynamic>> _groupTransactionsByDate(
      List transactions, Map<dynamic, DateTime> dateCache) {
    Map<String, List<dynamic>> grouped = {};
    final int currentYear = DateTime.now().year;
    final today = DateTime.now();

    // Extrair mês/ano selecionados do formato "Mês/AAAA"
    String? selectedMonthName;
    int? selectedYear;
    if (selectedMonth.value.isNotEmpty) {
      final parts = selectedMonth.value.split('/');
      if (parts.length == 2) {
        selectedMonthName = parts[0];
        selectedYear = int.tryParse(parts[1]);
      } else {
        selectedMonthName = selectedMonth.value;
        selectedYear = currentYear;
      }
    }

    for (var transaction in transactions) {
      final transactionDate = dateCache[transaction];
      if (transactionDate == null) continue;

      // Filtra por ano selecionado (ou ano atual como fallback)
      final int yearFilter = selectedYear ?? currentYear;
      if (transactionDate.year != yearFilter) continue;

      if (selectedMonthName != null && selectedMonthName.isNotEmpty) {
        String monthName =
            ResumeContent.getAllMonths()[transactionDate.month - 1];
        if (monthName != selectedMonthName) continue;
      }

      String relativeDate = _getRelativeDate(transactionDate);
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

    // Tenta fazer parse do formato brasileiro "2 de novembro de 2025"
    try {
      final months = {
        'janeiro': 1,
        'fevereiro': 2,
        'março': 3,
        'abril': 4,
        'maio': 5,
        'junho': 6,
        'julho': 7,
        'agosto': 8,
        'setembro': 9,
        'outubro': 10,
        'novembro': 11,
        'dezembro': 12,
      };

      final match = RegExp(r'(\d+) de (\w+) de (\d+)').firstMatch(relativeDate);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final monthName = match.group(2)!;
        final year = int.parse(match.group(3)!);
        final month = months[monthName.toLowerCase()];
        if (month != null) {
          return DateTime(year, month, day);
        }
      }

      // Fallback: tenta fazer parse do formato antigo dd/MM/yyyy
      return DateFormat('dd/MM/yyyy').parse(relativeDate);
    } catch (e) {
      return now; // Fallback para hoje se não conseguir fazer parse
    }
  }

  String _formatDateBrazilian(DateTime date) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _getRelativeDate(DateTime date) {
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

    return _formatDateBrazilian(date);
  }
}
