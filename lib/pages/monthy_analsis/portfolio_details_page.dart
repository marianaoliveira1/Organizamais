import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../ads_banner/ads_banner.dart';
import '../transaction/transaction_page.dart';

import '../../utils/color.dart';
import '../graphics/widgtes/finance_legend.dart';

class PortfolioDetailsPage extends StatelessWidget {
  const PortfolioDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Análise Mensal ',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        // Agrupa transações por mês até o mês atual
        final monthlyData = _getMonthlyData(transactionController);

        return Column(
          children: [
            AdsBanner(),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lista de meses
                    Text(
                      "Análise por Mês",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Compração entre os meses",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    ...monthlyData
                        .where((monthData) =>
                            (monthData['income'] as double) > 0 ||
                            (monthData['expenses'] as double) > 0)
                        .map((monthData) => _buildMonthCard(
                              theme,
                              formatter,
                              monthData,
                              transactionController,
                            )),

                    SizedBox(
                      height: 10.h,
                    ),
                    AdsBanner(),
                    SizedBox(
                      height: 10.h,
                    ),
                    _buildFinalAverages(theme, formatter, monthlyData),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            AdsBanner(),
          ],
        );
      }),
    );
  }

  Widget _buildMonthCard(
    ThemeData theme,
    NumberFormat formatter,
    Map<String, dynamic> monthData,
    TransactionController controller,
  ) {
    final String monthName = monthData['monthName'];
    final double income = monthData['income'];
    final double expenses = monthData['expenses'];
    final double balance = monthData['balance'];
    final int year = monthData['year'];
    final int month = monthData['month'];

    // Busca dados do mês anterior para comparação
    final previousMonthData = _getPreviousMonthData(controller, year, month);
    final double previousBalance = previousMonthData['balance'] ?? 0.0;
    final double previousIncome = previousMonthData['income'] ?? 0.0;
    final double previousExpenses = previousMonthData['expenses'] ?? 0.0;

    final double balanceVariation = balance - previousBalance;
    final double incomeVariation = income - previousIncome;
    final double expensesVariation = expenses - previousExpenses;

    final double balanceVariationPercentage =
        previousBalance != 0 ? (balanceVariation / previousBalance) * 100 : 0;
    final double incomeVariationPercentage =
        previousIncome != 0 ? (incomeVariation / previousIncome) * 100 : 0;
    final double expensesVariationPercentage = previousExpenses != 0
        ? (expensesVariation / previousExpenses) * 100
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(9.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 6.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey20,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formatter.format(balance),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        balance >= 0 ? DefaultColors.green : DefaultColors.red,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receitas',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: DefaultColors.slateGrey,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          formatter.format(income),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Despesas',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: DefaultColors.slateGrey,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        Text(
                          formatter.format(expenses),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 6.h,
          ),
          if ((income + expenses) > 0) ...[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 12.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 160.h,
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      legend: Legend(isVisible: false),
                      series: <CircularSeries<Map<String, dynamic>, String>>[
                        PieSeries<Map<String, dynamic>, String>(
                          dataSource: [
                            {
                              'name': 'Receita',
                              'value': income,
                              'color': DefaultColors.green
                            },
                            {
                              'name': 'Despesas',
                              'value': expenses,
                              'color': DefaultColors.red
                            },
                          ],
                          xValueMapper: (Map<String, dynamic> e, _) =>
                              (e['name'] as String),
                          yValueMapper: (Map<String, dynamic> e, _) =>
                              (e['value'] as double),
                          pointColorMapper: (Map<String, dynamic> e, _) =>
                              (e['color'] as Color),
                          dataLabelMapper: (Map<String, dynamic> e, _) {
                            final double v = (e['value'] as double);
                            final double tot = (income + expenses);
                            final double pct = tot > 0 ? (v / tot) * 100 : 0;
                            return '${(e['name'] as String)}\n${pct.toStringAsFixed(0)}%';
                          },
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: false),
                          explode: true,
                          explodeIndex: income >= expenses ? 0 : 1,
                          explodeOffset: '8%',
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Builder(builder: (context) {
                    final double total = (income + expenses);
                    final double incomePercent =
                        total == 0 ? 0 : (income / total) * 100;
                    final double expensesPercent =
                        total == 0 ? 0 : (expenses / total) * 100;

                    return Column(
                      children: [
                        FinanceLegend(
                          title: 'Receita',
                          color: DefaultColors.green,
                          percent: incomePercent,
                          value: income,
                          formatter: formatter,
                        ),
                        SizedBox(height: 4.h),
                        FinanceLegend(
                          title: 'Despesas',
                          color: DefaultColors.red,
                          percent: expensesPercent,
                          value: expenses,
                          formatter: formatter,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(
                12.r,
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 12.w,
            ),
            child: Column(
              children: [
                // Variação das receitas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          incomeVariation >= 0
                              ? Iconsax.arrow_circle_up
                              : Iconsax.arrow_down_2,
                          color: incomeVariation >= 0
                              ? DefaultColors.green
                              : DefaultColors.red,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Receitas: ",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: incomeVariation >= 0
                                ? DefaultColors.green
                                : DefaultColors.red,
                          ),
                        )
                      ],
                    ),
                    Text(
                      '${incomeVariationPercentage >= 0 ? '+' : ''}${incomeVariationPercentage.toStringAsFixed(1)}% (${incomeVariation >= 0 ? '+' : ''}${formatter.format(incomeVariation)})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: incomeVariation >= 0
                            ? DefaultColors.green
                            : DefaultColors.red,
                      ),
                    ),
                  ],
                ),

                // Variação das despesas
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          expensesVariation <= 0
                              ? Iconsax.arrow_down_2
                              : Iconsax.arrow_circle_up,
                          color: expensesVariation <= 0
                              ? DefaultColors.green
                              : DefaultColors.red,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Despesas: ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: expensesVariation <= 0
                                ? DefaultColors.green
                                : DefaultColors.red,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ' ${expensesVariationPercentage >= 0 ? '+' : ''}${expensesVariationPercentage.toStringAsFixed(1)}% (${expensesVariation >= 0 ? '+' : ''}${formatter.format(expensesVariation)})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: expensesVariation <= 0
                            ? DefaultColors.green
                            : DefaultColors.red,
                      ),
                    ),
                  ],
                ),

                // Variação do saldo
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.money_send,
                          color: balanceVariation >= 0
                              ? DefaultColors.green
                              : DefaultColors.red,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Saldo:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: balanceVariation >= 0
                                ? DefaultColors.green
                                : DefaultColors.red,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ' ${balanceVariationPercentage >= 0 ? '+' : ''}${balanceVariationPercentage.toStringAsFixed(1)}% (${balanceVariation >= 0 ? '+' : ''}${formatter.format(balanceVariation)})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: balanceVariation >= 0
                            ? DefaultColors.green
                            : DefaultColors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 6.h,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalAverages(ThemeData theme, NumberFormat formatter,
      List<Map<String, dynamic>> monthlyData) {
    // Filtra meses com receita > 0
    final List<Map<String, dynamic>> monthsWithIncome =
        monthlyData.where((m) => (m['income'] as double) > 0).toList();

    // Ordena por ano/mês decrescente e pega os últimos 3 com receita
    monthsWithIncome.sort((a, b) {
      final ay = a['year'] as int;
      final by = b['year'] as int;
      if (ay != by) return by.compareTo(ay);
      return (b['month'] as int).compareTo(a['month'] as int);
    });
    final last3 = monthsWithIncome.take(3).toList();

    double avgIncome = 0.0;
    double avgExpenses = 0.0;
    if (last3.isNotEmpty) {
      avgIncome = last3
              .map<double>((m) => (m['income'] as double))
              .fold(0.0, (s, v) => s + v) /
          last3.length;
      avgExpenses = last3
              .map<double>((m) => (m['expenses'] as double))
              .fold(0.0, (s, v) => s + v) /
          last3.length;
    }

    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Com base no seu histórico, aqui está uma previsão de receita e despesas (esses valores podem variar):',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Receita média estimada (últimos 3 meses):',
                    style:
                        TextStyle(fontSize: 12.sp, color: DefaultColors.grey20),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  formatter.format(avgIncome),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Despesas médias estimadas (últimos 3 meses):',
                    style:
                        TextStyle(fontSize: 12.sp, color: DefaultColors.grey20),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  formatter.format(avgExpenses),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ));
  }

  List<Map<String, dynamic>> _getMonthlyData(TransactionController controller) {
    final Map<String, Map<String, dynamic>> monthlyMap = {};
    final DateTime currentDate = DateTime.now();
    final int currentYear = currentDate.year;
    final int currentMonth = currentDate.month;

    // Agrupa transações por mês até o mês atual (apenas ano 2025)
    for (final transaction in controller.transaction) {
      if (transaction.paymentDay == null) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Exibir apenas dados do ano de 2025
        if (paymentDate.year != 2025) {
          continue;
        }

        // Filtra apenas transações até o mês atual
        if (paymentDate.year > currentYear ||
            (paymentDate.year == currentYear &&
                paymentDate.month > currentMonth)) {
          continue;
        }

        final key =
            '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}';

        if (!monthlyMap.containsKey(key)) {
          monthlyMap[key] = {
            'year': paymentDate.year,
            'month': paymentDate.month,
            'monthName': DateFormat('MMMM yyyy', 'pt_BR').format(paymentDate),
            'income': 0.0,
            'expenses': 0.0,
            'balance': 0.0,
          };
        }

        final value = _parseValue(transaction.value);

        if (transaction.type == TransactionType.receita) {
          monthlyMap[key]!['income'] =
              (monthlyMap[key]!['income'] as double) + value;
          monthlyMap[key]!['balance'] =
              (monthlyMap[key]!['balance'] as double) + value;
        } else if (transaction.type == TransactionType.despesa) {
          monthlyMap[key]!['expenses'] =
              (monthlyMap[key]!['expenses'] as double) + value;
          monthlyMap[key]!['balance'] =
              (monthlyMap[key]!['balance'] as double) - value;
        }
      } catch (e) {
        continue;
      }
    }

    // Converte para lista e ordena por data (janeiro primeiro)
    final List<Map<String, dynamic>> monthlyData = monthlyMap.values.toList();
    monthlyData.sort((a, b) {
      if (a['year'] != b['year']) {
        return a['year'].compareTo(b['year']);
      }
      return a['month'].compareTo(b['month']);
    });

    return monthlyData;
  }

  Map<String, double> _getPreviousMonthData(
    TransactionController controller,
    int year,
    int month,
  ) {
    // Calcula o mês anterior
    int previousYear = year;
    int previousMonth = month - 1;

    if (previousMonth == 0) {
      previousMonth = 12;
      previousYear = year - 1;
    }

    // Para esta página, não considerar dados fora de 2025
    if (previousYear != 2025) {
      return {
        'income': 0.0,
        'expenses': 0.0,
        'balance': 0.0,
      };
    }

    double income = 0.0;
    double expenses = 0.0;
    double balance = 0.0;

    for (final transaction in controller.transaction) {
      if (transaction.paymentDay == null) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        if (paymentDate.year == previousYear &&
            paymentDate.month == previousMonth) {
          final value = _parseValue(transaction.value);

          if (transaction.type == TransactionType.receita) {
            income += value;
            balance += value;
          } else if (transaction.type == TransactionType.despesa) {
            expenses += value;
            balance -= value;
          }
        }
      } catch (e) {
        continue;
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': balance,
    };
  }

  double _parseValue(String value) {
    try {
      String cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();

      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }
}

String _withInstallmentLabel(TransactionModel t, List<TransactionModel> all) {
  final regex = RegExp(r'^Parcela\s+(\d+)\s*:\s*(.+)$');
  final match = regex.firstMatch(t.title);
  if (match == null) return t.title;
  final current = int.tryParse(match.group(1) ?? '') ?? 0;
  final baseTitle = match.group(2) ?? '';
  final total = all.where((x) {
    final m = regex.firstMatch(x.title);
    if (m == null) return false;
    return (m.group(2) ?? '') == baseTitle;
  }).length;
  if (total <= 0) return t.title;
  return 'Parcela $current de $total — $baseTitle';
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paymentDate = DateTime.parse(transaction.paymentDay!);
    final formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);
    final double value = double.parse(
        transaction.value.replaceAll('.', '').replaceAll(',', '.'));
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return InkWell(
      onTap: () => Get.to(
        () => TransactionPage(
          transaction: transaction,
          overrideTransactionSalvar: (updatedTransaction) {
            final controller = Get.find<TransactionController>();
            controller.updateTransaction(updatedTransaction);
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    _withInstallmentLabel(transaction,
                        Get.find<TransactionController>().transaction),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatter.format(value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    transaction.paymentType ?? "Não especificado",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
