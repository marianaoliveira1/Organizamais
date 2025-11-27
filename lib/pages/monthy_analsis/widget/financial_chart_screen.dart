import 'package:flutter/material.dart';

import 'monthly_financial_chart.dart';

class FinancialChartScreen extends StatelessWidget {
  const FinancialChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Financeiro'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: MonthlyFinancialChart(selectedYear: DateTime.now().year),
      ),
    );
  }
}
