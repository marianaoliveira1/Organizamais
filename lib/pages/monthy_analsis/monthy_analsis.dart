// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/pages/graphics/widgtes/widget_list_category_graphics.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../graphics/graphics_page.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.h,
            ),
            child: Column(
              children: [
                FinancialSummaryCards(),
                MonthlyFinancialChart(),
                Obx(() {
                  var filteredTransactions = controller.transactionsAno
                      .where((e) => e.type == TransactionType.despesa)
                      .toList();
                  var categories = filteredTransactions
                      .map((e) => e.category)
                      .where((e) => e != null)
                      .toSet()
                      .toList()
                      .cast<int>();

                  var data = categories
                      .map(
                        (e) => {
                          "category": e,
                          "value": filteredTransactions
                              .where((element) => element.category == e)
                              .fold<double>(
                            0.0,
                            (previousValue, element) {
                              // Remove os pontos e troca vírgula por ponto para corrigir o parse
                              return previousValue +
                                  double.parse(element.value
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'));
                            },
                          ),
                          "name": findCategoryById(e)?['name'],
                          "color": findCategoryById(e)?['color'],
                          "icon": findCategoryById(
                              e)?['icon'], // Adicionado para acessar o ícone
                        },
                      )
                      .toList();

                  // Ordenar os dados por valor (decrescente)
                  data.sort((a, b) =>
                      (b['value'] as double).compareTo(a['value'] as double));

                  double totalValue = data.fold(
                    0.0,
                    (previousValue, element) =>
                        previousValue + (element['value'] as double),
                  );

                  // Criar as seções do gráfico sem ícones (apenas cores)
                  var chartData = data
                      .map(
                        (e) => PieChartSectionData(
                          value: e['value'] as double,
                          color: e['color'] as Color,
                          title: '', // Sem título
                          radius: 50,
                          showTitle: false,
                          badgePositionPercentageOffset: 0.9,
                        ),
                      )
                      .toList();

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma despesa registrada para exibir o gráfico.",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DefaultTextGraphic(
                              text: "Por categoria",
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: SizedBox(
                                height: 180.h,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 26,
                                    centerSpaceColor: theme.cardColor,
                                    sections: chartData,
                                  ),
                                ),
                              ),
                            ),
                            WidgetCategoryAnalise(
                              data: data,
                              totalValue: totalValue,
                              theme: theme,
                              currencyFormatter: NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                                decimalDigits: 2,
                              ),
                              monthName: '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WidgetCategoryAnalise extends StatelessWidget {
  const WidgetCategoryAnalise({
    super.key,
    required this.data,
    required this.monthName,
    required this.totalValue,
    required this.theme,
    required this.currencyFormatter,
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final String monthName;
  final ThemeData theme;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        var categoryId = item['category'] as int;
        var valor = item['value'] as double;
        var percentual = (valor / totalValue * 100);
        var categoryColor = item['color'] as Color;
        var categoryIcon = item['icon'] as String?;

        return Column(
          children: [
            // Item da categoria
            GestureDetector(
              onTap: () {
                // Navega para a página de análise da categoria
                Get.to(() => CategoryAnalysisPage(
                      categoryId: categoryId,
                      categoryName: item['name'] as String,
                      categoryColor: categoryColor,
                      monthName: monthName,
                      totalValue: valor,
                      percentual: percentual,
                    ));
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Ícone da categoria
                      Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            categoryIcon ?? 'assets/icons/category.png',
                            width: 20.w,
                            height: 20.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Text(
                              "${percentual.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(valor),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: DefaultColors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryAnalysisPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;
  final String monthName;
  final double totalValue;
  final double percentual;

  const CategoryAnalysisPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.monthName,
    required this.totalValue,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    List<TransactionModel> transactions =
        _getTransactionsByCategoryAndMonth(categoryId, monthName);

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Análise de $categoryName',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo da categoria
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${percentual.toStringAsFixed(1)}% do total',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: DefaultColors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(totalValue),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Lista de transações
            Text(
              'Transações em $monthName',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    "Nenhuma transação encontrada",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: DefaultColors.grey,
                    ),
                  ),
                ),
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                color: DefaultColors.grey20.withOpacity(.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                var transactionValue = double.parse(
                  transaction.value.replaceAll('.', '').replaceAll(',', '.'),
                );

                String formattedDate = transaction.paymentDay != null
                    ? dateFormatter.format(
                        DateTime.parse(transaction.paymentDay!),
                      )
                    : "Data não informada";

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Get.theme.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(transactionValue),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            transaction.paymentType ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];
          return transactionMonthName == monthName;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }
}

class FinancialSummaryCards extends StatelessWidget {
  const FinancialSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final totalReceita = controller.totalReceitaAno;
      final totalDespesas = controller.totalDespesasAno;
      final saldo = totalReceita - totalDespesas;

      return Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Anual ${DateTime.now().year} (até hoje)',
              style: TextStyle(
                fontSize: 12.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Cards de Receita e Despesa
            Row(
              children: [
                // Card de Receitas
                Expanded(
                  child: FinancialCard(
                    title: 'Receitas',
                    value: totalReceita,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),

                // Card de Despesas
                Expanded(
                  child: FinancialCard(
                    title: 'Despesas',
                    value: totalDespesas,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card de Saldo
            SaldoCard(saldo: saldo),
          ],
        ),
      );
    });
  }
}

class FinancialCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const FinancialCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 28,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: DefaultColors.grey20,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class SaldoCard extends StatelessWidget {
  final double saldo;

  const SaldoCard({
    Key? key,
    required this.saldo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = saldo >= 0;
    final color = isPositive ? Colors.blue : Colors.orange;
    final backgroundColor =
        isPositive ? Colors.blue.shade50 : Colors.orange.shade50;
    final icon = isPositive ? Icons.account_balance_wallet : Icons.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo do Ano',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(saldo.abs()),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPositive ? 'Positivo' : 'Negativo',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class FinancialDashboard extends StatelessWidget {
  const FinancialDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Financeiro'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: FinancialSummaryCards(),
      ),
    );
  }
}

class MonthlyFinancialChart extends StatelessWidget {
  const MonthlyFinancialChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final monthlyData = _calculateMonthlyData(controller.transaction);

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receitas vs Despesas Mensais',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ano ${DateTime.now().year} (até hoje)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChartLegendItem(label: 'Receitas', color: Colors.green),
                const SizedBox(width: 20),
                ChartLegendItem(label: 'Despesas', color: Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            // Gráfico
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: _getMaxValue(monthlyData) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          Colors.blueGrey.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = _getMonthName(group.x.toInt());
                        final value = rod.toY;
                        final type = rodIndex == 0 ? 'Receitas' : 'Despesas';
                        return BarTooltipItem(
                          '$month\n$type: ${_formatCurrency(value)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getMonthAbbr(value.toInt()),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _getMaxValue(monthlyData) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrencyShort(value),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _createBarGroups(monthlyData),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxValue(monthlyData) / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Map<int, Map<String, double>> _calculateMonthlyData(
      List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, Map<String, double>>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = {'receitas': 0.0, 'despesas': 0.0};
    }

    // Calcular totais por mês
    for (final transaction in transactions) {
      if (transaction.paymentDay != null) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );

          if (transaction.type == TransactionType.receita) {
            monthlyData[month]!['receitas'] =
                monthlyData[month]!['receitas']! + value;
          } else if (transaction.type == TransactionType.despesa) {
            monthlyData[month]!['despesas'] =
                monthlyData[month]!['despesas']! + value;
          }
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(
      Map<int, Map<String, double>> monthlyData) {
    return monthlyData.entries.map((entry) {
      final month = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: data['receitas']!,
            color: Colors.green,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data['despesas']!,
            color: Colors.red,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  double _getMaxValue(Map<int, Map<String, double>> monthlyData) {
    double maxValue = 0;
    for (final data in monthlyData.values) {
      final maxMonth = [data['receitas']!, data['despesas']!]
          .reduce((a, b) => a > b ? a : b);
      if (maxMonth > maxValue) {
        maxValue = maxMonth;
      }
    }
    return maxValue == 0 ? 1000 : maxValue;
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[month - 1];
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }
}

class ChartLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const ChartLegendItem({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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
