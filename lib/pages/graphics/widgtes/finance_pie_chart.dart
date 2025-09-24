import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../../utils/color.dart';
import 'finance_legend.dart';

class GraficoPorcengtagemReceitaEDespesa extends StatelessWidget {
  final String selectedMonth;

  const GraficoPorcengtagemReceitaEDespesa({
    super.key,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    final TransactionController transactionController =
        Get.put(TransactionController());

    // Lista de meses
    List<String> getAllMonths() {
      final months = [
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
      return months;
    }

    List<TransactionModel> getFilteredTransactions() {
      var allTransactions = transactionController.transaction.toList();

      if (selectedMonth.isNotEmpty) {
        final int currentYear = DateTime.now().year;
        return allTransactions.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String monthName = getAllMonths()[transactionDate.month - 1];
          return monthName == selectedMonth &&
              transactionDate.year == currentYear;
        }).toList();
      }

      return allTransactions;
    }

    // final theme = Theme.of(context);

    return Obx(() {
      var filteredTransactions = getFilteredTransactions();

      // Calcular receitas
      var receitas = filteredTransactions
          .where((e) => e.type == TransactionType.receita)
          .toList();

      double totalReceita = receitas.fold<double>(
        0.0,
        (previousValue, element) {
          return previousValue +
              double.parse(
                  element.value.replaceAll('.', '').replaceAll(',', '.'));
        },
      );

      // Calcular despesas
      var despesas = filteredTransactions
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      double totalDespesas = despesas.fold<double>(
        0.0,
        (previousValue, element) {
          return previousValue +
              double.parse(
                  element.value.replaceAll('.', '').replaceAll(',', '.'));
        },
      );

      num total = totalReceita + totalDespesas;
      double receitaPercent = total == 0 ? 0 : (totalReceita / total) * 100;
      double despesasPercent = total == 0 ? 0 : (totalDespesas / total) * 100;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            switchInCurve: Curves.easeOutCubic,
            child: SizedBox(
              key: ValueKey(total.toStringAsFixed(2)),
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalReceita,
                      title: "",
                      color: DefaultColors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: totalDespesas,
                      title: "",
                      color: DefaultColors.red,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FinanceLegend(
                title: "Receita",
                color: DefaultColors.green,
                percent: receitaPercent,
                value: totalReceita,
                formatter: formatter,
              ),
              SizedBox(
                height: 4.h,
              ),
              FinanceLegend(
                title: "Despesas",
                color: DefaultColors.red,
                percent: despesasPercent,
                value: totalDespesas,
                formatter: formatter,
              ),
            ],
          ),
        ],
      );
    });
  }
}
