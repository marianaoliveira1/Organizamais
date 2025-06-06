import 'package:flutter/material.dart';

import 'monthly_financial_chart.dart';

class FinancialChartScreen extends StatelessWidget {
  const FinancialChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Financeiro'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: MonthlyFinancialChart(),
      ),
    );
  }
}
