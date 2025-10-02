import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';

import '../../../ads_banner/ads_banner.dart';

class DespesasPorTipoDePagamento extends StatelessWidget {
  const DespesasPorTipoDePagamento({super.key, required this.selectedMonth});
  final String selectedMonth;

  String _normalizeMonthName(String name) {
    final map = {
      'jan': 'Janeiro',
      'fev': 'Fevereiro',
      'mar': 'Março',
      'abr': 'Abril',
      'mai': 'Maio',
      'jun': 'Junho',
      'jul': 'Julho',
      'ago': 'Agosto',
      'set': 'Setembro',
      'out': 'Outubro',
      'nov': 'Novembro',
      'dez': 'Dezembro',
    };
    final key = name.trim().toLowerCase();
    const fullMonths = [
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
    // se já for nome completo, mantém
    for (final full in fullMonths) {
      if (full.toLowerCase() == key) return full;
    }
    return map[key] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.put(TransactionController());

    // Formatador de moeda brasileira
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Formatador de data
    final dateFormatter = DateFormat('dd/MM/yyyy');

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
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (selectedMonth.isNotEmpty) {
        final parts = selectedMonth.split('/');
        final String monthName = parts.isNotEmpty
            ? _normalizeMonthName(parts[0])
            : _normalizeMonthName(selectedMonth);
        final int year = parts.length == 2
            ? int.tryParse(parts[1]) ?? DateTime.now().year
            : DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String m = getAllMonths()[transactionDate.month - 1];
          return m == monthName && transactionDate.year == year;
        }).toList();
      }

      return despesas;
    }

    return Column(
      children: [
        Obx(() {
          var filteredTransactions = getFilteredTransactions();
          var paymentTypes = filteredTransactions
              .map((e) => e.paymentType)
              .where((e) => e != null)
              .toSet()
              .toList()
              .cast<String>();

          var data = paymentTypes
              .map(
                (paymentType) => {
                  "paymentType": paymentType,
                  "value": filteredTransactions.where((element) {
                    if (element.paymentType == null) return false;
                    // Usar a mesma lógica robusta de comparação
                    return element.paymentType!.trim().toLowerCase() ==
                        paymentType.trim().toLowerCase();
                  }).fold<double>(
                    0.0,
                    (previousValue, element) {
                      // Remove os pontos e troca vírgula por ponto para corrigir o parse
                      return previousValue +
                          double.parse(element.value
                              .replaceAll('.', '')
                              .replaceAll(',', '.'));
                    },
                  ),
                  "color": _getPaymentTypeColor(paymentType),
                },
              )
              .toList();

          // Ordenar os dados por valor (decrescente)
          data.sort(
              (a, b) => (b['value'] as double).compareTo(a['value'] as double));

          double totalValue = data.fold(
            0.0,
            (previousValue, element) =>
                previousValue + (element['value'] as double),
          );

          // Criar as seções do gráfico pie com labels dentro e explosão no maior
          final double maxVal = data.isEmpty
              ? 0
              : (data
                  .map((e) => e['value'] as double)
                  .reduce((a, b) => a > b ? a : b));
          final int explodeIndex =
              data.indexWhere((e) => (e['value'] as double) == maxVal);
          var chartData = data.asMap().entries.map((entry) {
            final double v = entry.value['value'] as double;
            final String label = (entry.value['paymentType'] as String);
            final double pct = totalValue > 0 ? (v / totalValue) * 100 : 0;
            return PieChartSectionData(
              value: v,
              color: entry.value['color'] as Color,
              title: '',
              titleStyle: const TextStyle(),
              radius: entry.key == explodeIndex ? 76 : 70,
              showTitle: false,
              badgePositionPercentageOffset: 0.9,
              borderSide: BorderSide(
                color: theme.scaffoldBackgroundColor,
                width: 2,
              ),
            );
          }).toList();

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

          // Gráfico principal: Pie (Syncfusion) por tipo de pagamento
          return Column(
            children: [
              RepaintBoundary(
                child: SizedBox(
                  height: 200.h,
                  child: SfCircularChart(
                    margin: EdgeInsets.zero,
                    legend: const Legend(isVisible: false),
                    series: <CircularSeries<Map<String, dynamic>, String>>[
                      PieSeries<Map<String, dynamic>, String>(
                        dataSource: data,
                        xValueMapper: (e, _) => (e['paymentType'] as String),
                        yValueMapper: (e, _) => (e['value'] as double),
                        pointColorMapper: (e, _) => (e['color'] as Color),
                        dataLabelMapper: (e, _) => '',
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: false),
                        explode: true,
                        explodeIndex: explodeIndex < 0 ? 0 : explodeIndex,
                        explodeOffset: '6%',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
/*
              Obx(() {
                if (selectedPaymentType.value == null) {
                  return const SizedBox();
                }

                var chartTxs = filteredTransactions
                    ? filteredTransactions
                    : filteredTransactions.where((t) {
                      final pt = t.paymentType;
                      if (pt == null) return false;
                      return pt.trim().toLowerCase() ==
                          selectedPaymentType.value!.trim().toLowerCase();
                    }).toList();

                // Determina mês/ano selecionado
                final parts = selectedMonth.split('/');
                final String mName = parts.isNotEmpty
                    ? _normalizeMonthName(parts[0])
                    : _normalizeMonthName(selectedMonth);
                final int year = parts.length == 2
                    ? int.tryParse(parts[1]) ?? DateTime.now().year
                    : DateTime.now().year;
                final int monthIndex = getAllMonths().indexOf(mName) + 1;
                final int daysInMonth = DateTime(year, monthIndex + 1, 0).day;

                // Agrega por dia
                final Map<int, double> dailyTotals = {
                  for (int d = 1; d <= daysInMonth; d++) d: 0.0
                };
                for (final t in chartTxs) {
                  if (t.paymentDay == null) continue;
                  final dt = DateTime.parse(t.paymentDay!);
                  if (dt.year == year && dt.month == monthIndex) {
                    final val = double.parse(
                        t.value.replaceAll('.', '').replaceAll(',', '.'));
                    dailyTotals[dt.day] = (dailyTotals[dt.day] ?? 0) + val;
                  }
                }
                final List<double> dailyData = [
                  for (int d = 1; d <= daysInMonth; d++) dailyTotals[d] ?? 0.0
                ];

                // Agrega por semana (1-7, 8-14, 15-21, 22-28, 29-fim)
                final ranges = [
                  [1, 7],
                  [8, 14],
                  [15, 21],
                  [22, 28],
                  [29, daysInMonth],
                ];
                final List<double> weeklyTotals = ranges
                    .map((r) => dailyData
                        .sublist(r[0] - 1, r[1])
                        .fold(0.0, (s, v) => s + v))
                    .toList();
                final List<String> weekLabels = ranges
                    .map((r) => '${r[0]}-${r[1]}')
                    .toList(growable: false);

                // UI igual ao _buildCategoryChart (botões diário/semanal + gráfico)
                return Container(
                  margin: EdgeInsets.only(bottom: 24.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 14.w,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (showWeekly.value) showWeekly.value = false;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: !showWeekly.value
                                        ? DefaultColors.green
                                        : DefaultColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Despesas diárias',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: !showWeekly.value
                                        ? theme.primaryColor
                                        : DefaultColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!showWeekly.value) showWeekly.value = true;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: showWeekly.value
                                        ? DefaultColors.green
                                        : DefaultColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Despesas semanais',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: showWeekly.value
                                        ? theme.primaryColor
                                        : DefaultColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ... restante do bloco removido ...
                    ],
                  ),
                );
              }),
*/
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
        return DefaultColors.deepPurple;
      case 'débito':
        return DefaultColors.darkBlue;
      case 'dinheiro':
        return DefaultColors.orangeDark;
      case 'pix':
        return DefaultColors.greenDark;
      case 'boleto':
        return DefaultColors.brown;
      case 'transferência':
        return DefaultColors.blueGrey;
      case 'cheque':
        return DefaultColors.gold;
      case 'vale':
        return DefaultColors.lime;
      case 'criptomoeda':
        return DefaultColors.slateGrey;
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
    required this.selectedMonth,
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final RxnString selectedPaymentType;
  final ThemeData theme;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;
  final String selectedMonth;

  // Normaliza abreviações (jan/fev/set ...) para o nome completo do mês
  // ou retorna o próprio nome caso já esteja completo
  String _normalizeMonthName(String name) {
    final Map<String, String> abbrToFull = {
      'jan': 'Janeiro',
      'fev': 'Fevereiro',
      'mar': 'Março',
      'abr': 'Abril',
      'mai': 'Maio',
      'jun': 'Junho',
      'jul': 'Julho',
      'ago': 'Agosto',
      'set': 'Setembro',
      'out': 'Outubro',
      'nov': 'Novembro',
      'dez': 'Dezembro',
    };
    final key = name.trim().toLowerCase();
    // Se já for mês completo (case-insensitive), mantém
    const fullMonths = [
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
    for (final full in fullMonths) {
      if (full.toLowerCase() == key) return full;
    }
    return abbrToFull[key] ?? name;
  }

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
                  left: 4.w,
                  right: 4.w,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPaymentType.value == paymentType
                        ? paymentTypeColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Ícone/Cor do tipo de pagamento
                      Container(
                        width: 14.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: paymentTypeColor,
                          shape: BoxShape.circle,
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
                                fontSize: 10.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                            // Comparação com o mesmo dia do mês anterior (igual categorias)
                            _buildPaymentTypeComparisonPercentage(
                              paymentType,
                              theme,
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
                          Icon(Icons.chevron_right,
                              color: DefaultColors.grey, size: 16.h),
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

              var paymentTypeTransactions =
                  getTransactionsByPaymentType(paymentType, selectedMonth);
              paymentTypeTransactions.sort((a, b) {
                if (a.paymentDay == null || b.paymentDay == null) return 0;
                return DateTime.parse(b.paymentDay!)
                    .compareTo(DateTime.parse(a.paymentDay!));
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
                    AdsBanner(),
                    SizedBox(height: 6.h),
                    _buildPaymentTypeMonthComparisonRibbon(
                      paymentType,
                      theme,
                    ),
                    SizedBox(height: 6.h),

                    // Representação do total da receita
                    Builder(builder: (context) {
                      final tc = Get.find<TransactionController>();
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

                      // Suporta formatos "Mês" e "Mês/AAAA"
                      String monthName;
                      int year;
                      if (selectedMonth.contains('/')) {
                        final parts = selectedMonth.split('/');
                        monthName = _normalizeMonthName(parts[0]);
                        year = int.tryParse(parts[1]) ?? DateTime.now().year;
                      } else {
                        monthName = _normalizeMonthName(selectedMonth);
                        year = DateTime.now().year;
                      }

                      final receitasMes = tc.transaction.where((t) {
                        if (t.type != TransactionType.receita) return false;
                        if (t.paymentDay == null) return false;
                        final dt = DateTime.parse(t.paymentDay!);
                        final m = months[dt.month - 1];
                        return m == monthName && dt.year == year;
                      }).toList();

                      final double totalReceitas = tc.transaction.where((t) {
                        if (t.type != TransactionType.receita) return false;
                        if (t.paymentDay == null) return false;
                        final dt = DateTime.parse(t.paymentDay!);
                        final m = months[dt.month - 1];
                        return m == monthName && dt.year == year;
                      }).fold(0.0, (prev, e) {
                        return prev +
                            double.parse(
                              e.value.replaceAll('.', '').replaceAll(',', '.'),
                            );
                      });

                      final double totalGastoDoTipo =
                          paymentTypeTransactions.fold(0.0, (prev, e) {
                        return prev +
                            double.parse(
                              e.value.replaceAll('.', '').replaceAll(',', '.'),
                            );
                      });

                      final percReceita = totalReceitas > 0
                          ? (totalGastoDoTipo / totalReceitas * 100)
                          : 0.0;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          'Corresponde a ${percReceita.toStringAsFixed(1)}% do valor que você recebe no mês',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 2.h),
                    AdsBanner(),
                    SizedBox(height: 6.h),
                    Text(
                      "Transações recentes (${paymentTypeTransactions.length})",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: DefaultColors.grey20,
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
                          transaction.value
                              .replaceAll('.', '')
                              .replaceAll(',', '.'),
                        );

                        String formattedDate = transaction.paymentDay != null
                            ? dateFormatter.format(
                                DateTime.parse(transaction.paymentDay!),
                              )
                            : "Data não informada";

                        return InkWell(
                          onTap: () => Get.to(
                            () => TransactionPage(
                              transaction: transaction,
                              overrideTransactionSalvar: (updatedTransaction) {
                                final controller =
                                    Get.find<TransactionController>();
                                controller
                                    .updateTransaction(updatedTransaction);
                              },
                            ),
                          ),
                          child: Padding(
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
                                        _withInstallmentLabel(
                                            transaction,
                                            Get.find<TransactionController>()
                                                .transaction),
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
                                      currencyFormatter
                                          .format(transactionValue),
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

  Widget _buildPaymentTypeComparisonPercentage(
      String paymentType, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Definir datas conforme o mês selecionado
    final now = DateTime.now();
    final months = const [
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

    DateTime currentMonthStart;
    DateTime currentMonthEnd;
    DateTime previousMonthStart;
    DateTime previousMonthEnd;

    final selectedIndex = months.indexOf(selectedMonth);
    final bool isCurrentMonthSelected =
        selectedMonth.isEmpty || selectedIndex == (now.month - 1);

    if (isCurrentMonthSelected) {
      // Mês atual: compara até o mesmo dia
      currentMonthStart = DateTime(now.year, now.month, 1);
      currentMonthEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      previousMonthStart = DateTime(prevYear, prevMonth, 1);
      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      final prevDay = now.day > daysInPrevMonth ? daysInPrevMonth : now.day;
      previousMonthEnd = DateTime(prevYear, prevMonth, prevDay, 23, 59, 59);
    } else {
      // Mês selecionado pode ser passado ou futuro: se passado -> mês completo; se futuro -> mesmo dia de hoje
      final selectedMonthNumber =
          (selectedIndex >= 0 ? selectedIndex : now.month - 1) + 1;
      final selectedYear = now.year;

      final bool isFuture = (selectedYear > now.year) ||
          (selectedYear == now.year && selectedMonthNumber > now.month);

      currentMonthStart = DateTime(selectedYear, selectedMonthNumber, 1);
      final daysInSelected =
          DateTime(selectedYear, selectedMonthNumber + 1, 0).day;
      final currentEndDay =
          isFuture ? now.day.clamp(1, daysInSelected) : daysInSelected;
      currentMonthEnd = DateTime(
          selectedYear, selectedMonthNumber, currentEndDay, 23, 59, 59);

      final prevMonth = selectedMonthNumber == 1 ? 12 : selectedMonthNumber - 1;
      final prevYear =
          selectedMonthNumber == 1 ? selectedYear - 1 : selectedYear;
      previousMonthStart = DateTime(prevYear, prevMonth, 1);
      final daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
      final prevEndDay = isFuture ? now.day.clamp(1, daysInPrev) : daysInPrev;
      previousMonthEnd = DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);
    }

    // Somar despesas por tipo dentro das janelas
    double currentValue = 0.0;
    double previousValue = 0.0;

    for (final t in transactionController.transaction) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) continue;
      final pt = t.paymentType;
      if (pt == null) continue;
      if (pt.trim().toLowerCase() != paymentType.trim().toLowerCase()) continue;

      final d = DateTime.parse(t.paymentDay!);
      if (d.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(currentMonthEnd.add(const Duration(seconds: 1)))) {
        currentValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
      if (d.isAfter(previousMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(previousMonthEnd.add(const Duration(seconds: 1)))) {
        previousValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
    }

    // Determinar o tipo de variação, seguindo a regra de despesas
    if (currentValue == 0 && previousValue == 0) {
      return const SizedBox.shrink();
    }

    // Se não há valor anterior mas há atual: tratamos como aumento 100%
    if (previousValue == 0 && currentValue > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.arrow_circle_up,
            size: 12.sp,
            color: DefaultColors.redDark,
          ),
          SizedBox(width: 4.w),
          Text(
            '+100.0%',
            style: TextStyle(
              fontSize: 9.sp,
              color: DefaultColors.redDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (previousValue == 0) {
      return const SizedBox.shrink();
    }

    final percentageChange =
        ((currentValue - previousValue) / previousValue) * 100;

    // Para despesas: diminuiu => verde com seta para baixo; aumentou => vermelho com seta para cima; igual => cinza
    late final Color color;
    late final IconData icon;
    late final String display;

    if (percentageChange < 0) {
      color = DefaultColors.greenDark;
      icon = Iconsax.arrow_circle_down;
      display = '+${percentageChange.abs().toStringAsFixed(1)}%';
    } else if (percentageChange > 0) {
      color = DefaultColors.redDark;
      icon = Iconsax.arrow_circle_up;
      display = '-${percentageChange.abs().toStringAsFixed(1)}%';
    } else {
      color = DefaultColors.grey;
      icon = Iconsax.more_circle;
      display = '0.0%';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          display,
          style: TextStyle(
            fontSize: 9.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Versão com "ribbon" colorido à esquerda, igual ao exemplo dos cards
  Widget _buildPaymentTypeMonthComparisonRibbon(
      String paymentType, ThemeData theme) {
    final TransactionController controller = Get.find<TransactionController>();

    // Datas considerando mês selecionado (com suporte a "Mês/AAAA")
    final now = DateTime.now();
    final months = const [
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

    DateTime currentMonthStart;
    DateTime currentMonthEnd;
    DateTime previousMonthStart;
    DateTime previousMonthEnd;

    int selectedIndex = -1;
    int selectedYear = now.year;
    String raw = selectedMonth.trim();
    String mPart = raw;
    String? yPart;
    if (raw.contains('/')) {
      final p = raw.split('/');
      if (p.isNotEmpty) mPart = p[0].trim();
      if (p.length > 1) yPart = p[1].trim();
    }
    if (yPart != null && yPart!.isNotEmpty) {
      selectedYear = int.tryParse(yPart!) ?? now.year;
    }
    final Map<String, int> abbr = {
      'jan': 1,
      'fev': 2,
      'mar': 3,
      'abr': 4,
      'mai': 5,
      'jun': 6,
      'jul': 7,
      'ago': 8,
      'set': 9,
      'out': 10,
      'nov': 11,
      'dez': 12,
    };
    final Map<String, int> full = {
      'janeiro': 1,
      'fevereiro': 2,
      'março': 3,
      'marco': 3,
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
    int? monthNum;
    final lower = mPart.toLowerCase().replaceAll('.', '').trim();
    monthNum = abbr[lower] ?? full[lower];
    if (monthNum == null) {
      final idx = months.indexOf(mPart);
      if (idx >= 0) monthNum = idx + 1;
    }
    if (monthNum == null) {
      selectedIndex = now.month - 1;
    } else {
      selectedIndex = monthNum - 1;
    }
    final selectedMonthNumber = selectedIndex + 1;

    final bool isCurrentSelected =
        (selectedYear == now.year && selectedMonthNumber == now.month);
    // Mês já fechado? Se não, aplica corte no mesmo dia
    final bool isMonthClosed =
        DateTime(selectedYear, selectedMonthNumber + 1, 1)
            .isBefore(DateTime(now.year, now.month, 1));
    final bool isCurrentOrFuture = !isMonthClosed;
    currentMonthStart = DateTime(selectedYear, selectedMonthNumber, 1);
    final int daysInSelected =
        DateTime(selectedYear, selectedMonthNumber + 1, 0).day;
    final int currentEndDay =
        isCurrentOrFuture ? now.day.clamp(1, daysInSelected) : daysInSelected;
    currentMonthEnd =
        DateTime(selectedYear, selectedMonthNumber, currentEndDay, 23, 59, 59);

    final int prevMonth =
        selectedMonthNumber == 1 ? 12 : selectedMonthNumber - 1;
    final int prevYear =
        selectedMonthNumber == 1 ? selectedYear - 1 : selectedYear;
    previousMonthStart = DateTime(prevYear, prevMonth, 1);
    final int daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
    final int prevEndDay =
        isCurrentOrFuture ? now.day.clamp(1, daysInPrev) : daysInPrev;
    previousMonthEnd = DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);

    double currentValue = 0.0;
    double previousValue = 0.0;

    for (final t in controller.transaction) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) continue;
      final pt = t.paymentType;
      if (pt == null) continue;
      if (pt.trim().toLowerCase() != paymentType.trim().toLowerCase()) continue;

      final d = DateTime.parse(t.paymentDay!);
      if (d.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(currentMonthEnd.add(const Duration(seconds: 1)))) {
        currentValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
      if (d.isAfter(previousMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(previousMonthEnd.add(const Duration(seconds: 1)))) {
        previousValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
    }

    late final Color sideColor;
    late final String text;
    String _monthName(int m) {
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
      return months[(m - 1).clamp(0, 11)];
    }

    if (currentValue == 0 && previousValue == 0) {
      sideColor = DefaultColors.grey;
      text = 'Sem dados para comparação nos períodos atual e anterior.';
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: DefaultColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.more_circle,
              size: 14.sp,
              color: sideColor,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: sideColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isMonthClosed) {
      final diff = (currentValue - previousValue).abs();
      final double percentageChange = previousValue == 0
          ? 100.0
          : ((currentValue - previousValue) / previousValue) * 100;
      final String monthLabel = _monthName(currentMonthEnd.month);

      if (currentValue > previousValue) {
        sideColor = DefaultColors.redDark;
        text =
            'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
            'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
            'um gasto maior de R\$ ${_formatCurrency(diff)} (+${percentageChange.abs().toStringAsFixed(1)}%).';
      } else if (currentValue < previousValue) {
        sideColor = DefaultColors.greenDark;
        text =
            'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
            'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
            'um gasto menor de R\$ ${_formatCurrency(diff)} (-${percentageChange.abs().toStringAsFixed(1)}%).';
      } else {
        sideColor = DefaultColors.grey;
        text = 'Você gastou o mesmo valor em $monthLabel '
            'que no mês anterior: R\$ ${_formatCurrency(currentValue)}';
      }
    } else {
      if (previousValue == 0 && currentValue > 0) {
        sideColor = DefaultColors.redDark;
        final sameDayLabel =
            '${previousMonthEnd.day} de ${_monthName(previousMonthEnd.month)}';
        text =
            'No mesmo dia do mês passado ($sameDayLabel) você gastou R\$ ${_formatCurrency(previousValue)}, e agora gastou R\$ ${_formatCurrency(currentValue)}, o que aumentou 100%.';
      } else {
        final diff = (currentValue - previousValue).abs();
        final percentageChange =
            ((currentValue - previousValue) / previousValue) * 100;
        final String monthLabel = _monthName(currentMonthEnd.month);
        final bool isCurrentSelected =
            (selectedYear == now.year && selectedMonthNumber == now.month);

        if (isCurrentSelected) {
          final sameDayLabel =
              '${previousMonthEnd.day} de ${_monthName(previousMonthEnd.month)}';
          if (currentValue > previousValue) {
            sideColor = DefaultColors.redDark;
            text =
                'No mesmo dia do mês passado ($sameDayLabel) você gastou R\$ ${_formatCurrency(previousValue)}, e agora gastou R\$ ${_formatCurrency(currentValue)}, o que aumentou ${percentageChange.abs().toStringAsFixed(1)}% (R\$ ${_formatCurrency(diff)}).';
          } else if (currentValue < previousValue) {
            sideColor = DefaultColors.greenDark;
            text =
                'No mesmo dia do mês passado ($sameDayLabel) você gastou R\$ ${_formatCurrency(previousValue)}, e agora gastou R\$ ${_formatCurrency(currentValue)}, o que diminuiu ${percentageChange.abs().toStringAsFixed(1)}% (R\$ ${_formatCurrency(diff)}).';
          } else {
            sideColor = DefaultColors.grey;
            text =
                'No mesmo dia do mês passado ($sameDayLabel) você gastou R\$ ${_formatCurrency(previousValue)}, e agora gastou o mesmo valor.';
          }
        } else {
          if (currentValue > previousValue) {
            sideColor = DefaultColors.redDark;
            text =
                'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
                'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
                'um gasto maior de R\$ ${_formatCurrency(diff)} (+${percentageChange.abs().toStringAsFixed(1)}%).';
          } else if (currentValue < previousValue) {
            sideColor = DefaultColors.greenDark;
            text =
                'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
                'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
                'um gasto menor de R\$ ${_formatCurrency(diff)} (-${percentageChange.abs().toStringAsFixed(1)}%).';
          } else {
            sideColor = DefaultColors.grey;
            text =
                'Mesmo valor do mês passado: R\$ ${_formatCurrency(currentValue)}';
          }
        }
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: sideColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeMonthComparison(String paymentType, ThemeData theme) {
    final TransactionController controller = Get.find<TransactionController>();

    // Definir datas conforme o mês selecionado
    final now = DateTime.now();
    final months = const [
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

    DateTime currentMonthStart;
    DateTime currentMonthEnd;
    DateTime previousMonthStart;
    DateTime previousMonthEnd;

    final selectedIndex = months.indexOf(selectedMonth);
    final bool isCurrentMonthSelected =
        selectedMonth.isEmpty || selectedIndex == (now.month - 1);

    if (isCurrentMonthSelected) {
      // Mês atual até o dia de hoje; mês anterior até o mesmo dia
      currentMonthStart = DateTime(now.year, now.month, 1);
      currentMonthEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      previousMonthStart = DateTime(prevYear, prevMonth, 1);
      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      final prevDay = now.day > daysInPrevMonth ? daysInPrevMonth : now.day;
      previousMonthEnd = DateTime(prevYear, prevMonth, prevDay, 23, 59, 59);
    } else {
      // Mês selecionado inteiro; mês anterior inteiro
      final selectedMonthNumber =
          (selectedIndex >= 0 ? selectedIndex : now.month - 1) + 1;
      final selectedYear = now.year;

      currentMonthStart = DateTime(selectedYear, selectedMonthNumber, 1);
      final daysInSelected =
          DateTime(selectedYear, selectedMonthNumber + 1, 0).day;
      currentMonthEnd = DateTime(
          selectedYear, selectedMonthNumber, daysInSelected, 23, 59, 59);

      final prevMonth = selectedMonthNumber == 1 ? 12 : selectedMonthNumber - 1;
      final prevYear =
          selectedMonthNumber == 1 ? selectedYear - 1 : selectedYear;
      previousMonthStart = DateTime(prevYear, prevMonth, 1);
      final daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
      previousMonthEnd = DateTime(prevYear, prevMonth, daysInPrev, 23, 59, 59);
    }

    // Somar despesas por tipo dentro das janelas
    double currentValue = 0.0;
    double previousValue = 0.0;

    for (final t in controller.transaction) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) continue;
      final pt = t.paymentType;
      if (pt == null) continue;
      if (pt.trim().toLowerCase() != paymentType.trim().toLowerCase()) continue;

      final d = DateTime.parse(t.paymentDay!);
      if (d.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(currentMonthEnd.add(const Duration(seconds: 1)))) {
        currentValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
      if (d.isAfter(previousMonthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(previousMonthEnd.add(const Duration(seconds: 1)))) {
        previousValue +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
    }

    // Construir texto explicativo com nomes dos meses
    String explanationText = '';
    late final Color color;
    late final IconData icon;
    String monthName(int y, int m) {
      const list = [
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
      return list[(m - 1).clamp(0, 11)];
    }

    final String currentMonthLabel =
        monthName(currentMonthEnd.year, currentMonthEnd.month);
    final String previousMonthLabel =
        monthName(previousMonthEnd.year, previousMonthEnd.month);
    final bool isCurrentOrFuture = (currentMonthEnd.year > now.year) ||
        (currentMonthEnd.year == now.year &&
            currentMonthEnd.month >= now.month);

    if (previousValue == 0 && currentValue > 0) {
      color = DefaultColors.redDark; // aumento de despesa = ruim
      icon = Iconsax.arrow_circle_up;
      final diff = (currentValue - previousValue).abs();
      explanationText = isCurrentOrFuture
          ? 'Gasto maior: +100% (R\$ ${_formatCurrency(diff)}) em relação ao mesmo dia do mês passado. Antes: R\$ ${_formatCurrency(previousValue)}, agora: R\$ ${_formatCurrency(currentValue)}'
          : 'No mês de $previousMonthLabel você gastou R\$ 0,00 e em $currentMonthLabel R\$ ${_formatCurrency(currentValue)}; aumento de 100%.';
    } else if (previousValue == 0 && currentValue == 0) {
      return const SizedBox.shrink();
    } else {
      final diff = (currentValue - previousValue).abs();
      final percentageChange =
          ((currentValue - previousValue) / previousValue) * 100;
      if (currentValue < previousValue) {
        color = DefaultColors.greenDark; // diminuiu = bom
        icon = Iconsax.arrow_circle_down;
        explanationText = isCurrentOrFuture
            ? 'Gasto menor: -${percentageChange.abs().toStringAsFixed(1)}% (R\$ ${_formatCurrency(diff)}) em relação ao mesmo dia do mês passado. Antes: R\$ ${_formatCurrency(previousValue)}, agora: R\$ ${_formatCurrency(currentValue)}'
            : 'No mês de $previousMonthLabel você gastou R\$ ${_formatCurrency(previousValue)} e em $currentMonthLabel R\$ ${_formatCurrency(currentValue)}; gasto menor de R\$ ${_formatCurrency(diff)} (${percentageChange.abs().toStringAsFixed(1)}%).';
      } else if (currentValue > previousValue) {
        color = DefaultColors.redDark; // aumentou = ruim
        icon = Iconsax.arrow_circle_up;
        explanationText = isCurrentOrFuture
            ? 'Gasto maior: +${percentageChange.abs().toStringAsFixed(1)}% (R\$ ${_formatCurrency(diff)}) em relação ao mesmo dia do mês passado. Antes: R\$ ${_formatCurrency(previousValue)}, agora: R\$ ${_formatCurrency(currentValue)}'
            : 'No mês de $previousMonthLabel você gastou R\$ ${_formatCurrency(previousValue)} e em $currentMonthLabel R\$ ${_formatCurrency(currentValue)}; gasto maior de R\$ ${_formatCurrency(diff)} (+${percentageChange.abs().toStringAsFixed(1)}%).';
      } else {
        color = DefaultColors.grey; // igual
        icon = Iconsax.more_circle;
        explanationText = isCurrentOrFuture
            ? 'Mesmo valor do mês passado: R\$ ${_formatCurrency(currentValue)}'
            : 'No mês de $previousMonthLabel e em $currentMonthLabel o gasto foi o mesmo: R\$ ${_formatCurrency(currentValue)}.';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: DefaultColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              explanationText,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    return formatter.format(value);
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

  // Função para obter a primeira letra do tipo de pagamento

  // Reimplementação da função getTransactionsByPaymentType para uso na classe WidgetListPaymentTypeGraphics
  List<TransactionModel> getTransactionsByPaymentType(
      String paymentType, String selectedMonth) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
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
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (selectedMonth.isNotEmpty) {
        final parts = selectedMonth.split('/');
        final String monthName = parts.isNotEmpty ? parts[0] : selectedMonth;
        final int year = parts.length == 2
            ? int.tryParse(parts[1]) ?? DateTime.now().year
            : DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          final dt = DateTime.parse(transaction.paymentDay!);
          final mName = getAllMonths()[dt.month - 1];
          return mName == monthName && dt.year == year;
        }).toList();
      }
      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();

    // Comparação mais robusta para tipos de pagamento
    var paymentTypeTransactions = filteredTransactions.where((transaction) {
      if (transaction.paymentType == null) return false;
      // Comparação ignorando maiúsculas/minúsculas e espaços extras
      return transaction.paymentType!.trim().toLowerCase() ==
          paymentType.trim().toLowerCase();
    }).toList();

    return paymentTypeTransactions;
  }
}
