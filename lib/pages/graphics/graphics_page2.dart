import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

import 'widgtes/default_text_graphic.dart';

class GraphicsPage2 extends StatelessWidget {
  const GraphicsPage2({super.key, required this.selectedMonth});
  final RxString selectedMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController = Get.put(TransactionController());

    // Formatador de moeda brasileira
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Formatador de data
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dayFormatter = DateFormat('dd');

    // Variável observável para controlar o tipo de pagamento selecionado
    final selectedPaymentType = RxnString(null);

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
      var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();

      if (selectedMonth.value.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String monthName = getAllMonths()[transactionDate.month - 1];
          return monthName == selectedMonth.value;
        }).toList();
      }

      return despesas;
    }

    // Obter transações para um tipo de pagamento específico
    List<TransactionModel> getTransactionsByPaymentType(String paymentType) {
      var filteredTransactions = getFilteredTransactions();
      return filteredTransactions.where((transaction) => transaction.paymentType == paymentType).toList();
    }

    // Função para gerar dados para o gráfico Sparkline com todos os dias do mês
    Map<String, dynamic> getSparklineData() {
      var filteredTransactions = getFilteredTransactions();

      // Determinar o mês e ano selecionados
      int selectedMonthIndex = selectedMonth.value.isEmpty ? DateTime.now().month - 1 : getAllMonths().indexOf(selectedMonth.value);
      int selectedYear = DateTime.now().year;

      // Obter o número de dias no mês selecionado
      int daysInMonth = DateTime(selectedYear, selectedMonthIndex + 1 + 1, 0).day;

      // Criar um mapa para todos os dias do mês, inicializados com zero
      Map<String, double> dailyTotals = {};
      for (int i = 1; i <= daysInMonth; i++) {
        String day = i.toString().padLeft(2, '0');
        dailyTotals[day] = 0;
      }

      // Preencher com dados reais das transações
      for (var transaction in filteredTransactions) {
        if (transaction.paymentDay != null) {
          DateTime date = DateTime.parse(transaction.paymentDay!);
          String dayKey = dayFormatter.format(date);
          double value = double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'));

          if (dailyTotals.containsKey(dayKey)) {
            dailyTotals[dayKey] = dailyTotals[dayKey]! + value;
          }
        }
      }

      // Ordenar as chaves (dias) numericamente
      List<String> sortedKeys = dailyTotals.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      // Criar listas para o gráfico sparkline
      List<double> sparklineData = [];
      List<String> labels = [];
      List<DateTime> dates = [];
      List<double> values = [];

      for (var day in sortedKeys) {
        sparklineData.add(dailyTotals[day]!);
        labels.add(day);

        // Criar uma data completa para cada dia
        dates.add(DateTime(selectedYear, selectedMonthIndex + 1, int.parse(day)));
        values.add(dailyTotals[day]!);
      }

      return {
        'data': sparklineData,
        'labels': labels,
        'dates': dates,
        'values': values,
      };
    }

    return Column(
      children: [
        SizedBox(height: 20.h),
        Obx(() {
          var filteredTransactions = getFilteredTransactions();
          var paymentTypes = filteredTransactions.map((e) => e.paymentType).where((e) => e != null).toSet().toList().cast<String>();

          var data = paymentTypes
              .map(
                (paymentType) => {
                  "paymentType": paymentType,
                  "value": filteredTransactions.where((element) => element.paymentType == paymentType).fold<double>(
                    0.0,
                    (previousValue, element) {
                      // Remove os pontos e troca vírgula por ponto para corrigir o parse
                      return previousValue + double.parse(element.value.replaceAll('.', '').replaceAll(',', '.'));
                    },
                  ),
                  "color": _getPaymentTypeColor(paymentType),
                },
              )
              .toList();

          // Ordenar os dados por valor (decrescente)
          data.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

          double totalValue = data.fold(
            0.0,
            (previousValue, element) => previousValue + (element['value'] as double),
          );

          // Criar as seções do gráfico
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
                "",
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 14.sp,
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
                      text: "Despesas por Tipo de Pagamento",
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
                    WidgetListPaymentTypeGraphics(
                      data: data,
                      totalValue: totalValue,
                      selectedPaymentType: selectedPaymentType,
                      theme: theme,
                      currencyFormatter: currencyFormatter,
                      dateFormatter: dateFormatter,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static const List<Color> _customCardColors = [
    DefaultColors.pastelBlue,
    DefaultColors.pastelGreen,
    DefaultColors.pastelPurple,
    DefaultColors.pastelOrange,
    DefaultColors.pastelPink,
    DefaultColors.pastelTeal,
    DefaultColors.pastelCyan,
    DefaultColors.pastelLime,
    DefaultColors.lavender,
    DefaultColors.peach,
    DefaultColors.mint,
    DefaultColors.plum,
    DefaultColors.turquoise,
    DefaultColors.salmon,
    DefaultColors.lightBlue,
  ];

  // Função auxiliar para atribuir cores aos tipos de pagamento
  static Color _getPaymentTypeColor(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'crédito':
        return DefaultColors.darkBlue; // Azul escuro (não está nos custom cards)
      case 'débito':
        return DefaultColors.greenDark; // Verde escuro (não está nos custom cards)
      case 'dinheiro':
        return DefaultColors.orangeDark; // Laranja escuro (não está nos custom cards)
      case 'pix':
        return DefaultColors.deepPurple; // Roxo profundo (não está nos custom cards)
      case 'boleto':
        return DefaultColors.brown; // Marrom (não está nos custom cards)
      case 'transferência':
        return DefaultColors.blueGrey; // Azul-cinza (não está nos custom cards)
      case 'cheque':
        return DefaultColors.gold; // Dourado (não está nos custom cards)
      case 'vale':
        return DefaultColors.lime; // Lima (não está nos custom cards)
      case 'criptomoeda':
        return DefaultColors.slateGrey; // Cinza ardósia (não está nos custom cards)
      case 'cupom':
        return DefaultColors.hotPink; // Rosa forte (não está nos custom cards)
      default:
        int colorIndex = paymentType.hashCode.abs() % _customCardColors.length;
        return _customCardColors[colorIndex];
    }
  }
}

class WidgetListPaymentTypeGraphics extends StatelessWidget {
  const WidgetListPaymentTypeGraphics({
    super.key,
    required this.data,
    required this.totalValue,
    required this.selectedPaymentType,
    required this.theme,
    required this.currencyFormatter,
    required this.dateFormatter,
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final RxnString selectedPaymentType;
  final ThemeData theme;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        var paymentType = item['paymentType'] as String;
        var valor = item['value'] as double;
        var percentual = (valor / totalValue * 100);
        var paymentTypeColor = item['color'] as Color;

        return Column(
          children: [
            // Item do tipo de pagamento
            GestureDetector(
              onTap: () {
                if (selectedPaymentType.value == paymentType) {
                  selectedPaymentType.value = null;
                } else {
                  selectedPaymentType.value = paymentType;
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: selectedPaymentType.value == paymentType ? paymentTypeColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Ícone/Cor do tipo de pagamento
                      Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: paymentTypeColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                            // child: Text(
                            //   _getPaymentTypeInitial(paymentType),
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 14.sp,
                            //   ),
                            // ),
                            ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 105.w,
                              child: Text(
                                paymentType,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${percentual.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 130.w,
                            child: Text(
                              currencyFormatter.format(valor),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Icon(
                            selectedPaymentType.value == paymentType ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: DefaultColors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de transações do tipo de pagamento expandido
            Obx(() {
              if (selectedPaymentType.value != paymentType) {
                return const SizedBox();
              }

              var paymentTypeTransactions = getTransactionsByPaymentType(paymentType);
              paymentTypeTransactions.sort((a, b) {
                if (a.paymentDay == null || b.paymentDay == null) return 0;
                return DateTime.parse(b.paymentDay!).compareTo(DateTime.parse(a.paymentDay!));
              });

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.h,
                  vertical: 14.h,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detalhes das Transações",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paymentTypeTransactions.length,
                      separatorBuilder: (context, index) => Divider(
                        color: DefaultColors.grey20.withOpacity(.5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        var transaction = paymentTypeTransactions[index];
                        var transactionValue = double.parse(
                          transaction.value.replaceAll('.', '').replaceAll(',', '.'),
                        );

                        String formattedDate = transaction.paymentDay != null
                            ? dateFormatter.format(
                                DateTime.parse(transaction.paymentDay!),
                              )
                            : "Data não informada";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 130.w,
                                    child: Text(
                                      transaction.title,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6.h,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormatter.format(transactionValue),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: theme.primaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    if (paymentTypeTransactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            "Nenhuma transação encontrada",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Função para obter a primeira letra do tipo de pagamento
  String _getPaymentTypeInitial(String paymentType) {
    return paymentType.substring(0, 1).toUpperCase();
  }

  // Reimplementação da função getTransactionsByPaymentType para uso na classe WidgetListPaymentTypeGraphics
  List<TransactionModel> getTransactionsByPaymentType(String paymentType) {
    final TransactionController transactionController = Get.find<TransactionController>();
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

    final selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();

      if (selectedMonth.value.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String monthName = getAllMonths()[transactionDate.month - 1];
          return monthName == selectedMonth.value;
        }).toList();
      }
      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions.where((transaction) => transaction.paymentType == paymentType).toList();
  }
}
