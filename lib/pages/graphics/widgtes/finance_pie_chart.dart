// import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
        // selectedMonth chega como "Mês/AAAA"
        final parts = selectedMonth.split('/');
        final String monthName = parts.isNotEmpty ? parts[0] : selectedMonth;
        final int year = parts.length > 1
            ? int.tryParse(parts[1]) ?? DateTime.now().year
            : DateTime.now().year;
        final int monthIndex = getAllMonths().indexOf(monthName) + 1;
        if (monthIndex > 0) {
          return allTransactions.where((transaction) {
            if (transaction.paymentDay == null) return false;
            DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
            return transactionDate.month == monthIndex &&
                transactionDate.year == year;
          }).toList();
        }
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
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                legend: Legend(isVisible: false),
                series: <CircularSeries<_Slice, String>>[
                  PieSeries<_Slice, String>(
                      dataSource: <_Slice>[
                        _Slice('Receita', totalReceita, DefaultColors.green),
                        _Slice('Despesa', totalDespesas, DefaultColors.red),
                      ],
                      xValueMapper: (_Slice s, _) => s.label,
                      yValueMapper: (_Slice s, _) => s.value,
                      pointColorMapper: (_Slice s, _) => s.color,
                      dataLabelMapper: (_Slice s, _) {
                        final double pct =
                            total > 0 ? (s.value / total) * 100 : 0;
                        return '${s.label}\n${pct.toStringAsFixed(0)}%';
                      },
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: false),
                      explode: true,
                      explodeIndex: totalReceita >= totalDespesas ? 0 : 1,
                      explodeOffset: '8%')
                ],
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

class _Slice {
  _Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}
