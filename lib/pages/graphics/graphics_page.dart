// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/graphics/widgtes/despesas_por_tipo_de_pagamento.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../ads_banner/ads_banner.dart';
import 'widgtes/default_text_graphic.dart';
import 'widgtes/finance_pie_chart.dart';
import 'widgtes/widget_list_category_graphics.dart';

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

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  late ScrollController _monthScrollController;
  String selectedMonth = getAllMonths()[DateTime.now().month - 1];

  @override
  void initState() {
    super.initState();
    _monthScrollController = ScrollController();

    // Centralizar o mês atual após a construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    // Estimar a posição do mês atual para centralizar
    final int currentMonthIndex = DateTime.now().month - 1;
    final double itemWidth = 80.w; // Ajuste este valor conforme a largura real do seu item
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset = currentMonthIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);

    // Limitar o scroll para não ir além dos limites
    final double maxScroll = _monthScrollController.position.maxScrollExtent;
    final double scrollPosition = offset.clamp(0.0, maxScroll);

    _monthScrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

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

    // Variável observável para controlar a categoria selecionada
    final selectedCategoryId = RxnInt(null);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child: Column(
            children: [
              AdsBanner(),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Lista de meses
                      SizedBox(
                        height: 30.h,
                        child: ListView.separated(
                          controller: _monthScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: getAllMonths().length,
                          separatorBuilder: (context, index) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final month = getAllMonths()[index];

                            return GestureDetector(
                              onTap: () {
                                if (selectedMonth == month) {
                                  selectedMonth = '';
                                } else {
                                  setState(() {
                                    selectedMonth = month;
                                  });
                                }
                                selectedCategoryId.value = null;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: selectedMonth == month
                                        ? DefaultColors.green
                                        : DefaultColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    color: selectedMonth == month
                                        ? theme.primaryColor
                                        : DefaultColors.grey,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Show shimmer loading or content
                      Obx(() {
                        if (transactionController.isLoading) {
                          return _buildShimmerContent(theme);
                        }
                        return _buildGraphicsContent(theme, transactionController, currencyFormatter, dateFormatter, dayFormatter, selectedCategoryId);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContent(ThemeData theme) {
    return Column(
      children: [
        // Shimmer for line chart
        _buildShimmerLineChart(theme),
        SizedBox(height: 20.h),
        // Shimmer for pie chart
        _buildShimmerPieChart(theme),
        SizedBox(height: 20.h),
        // Shimmer for additional charts
        _buildShimmerLineChart(theme),
        SizedBox(height: 20.h),
        _buildShimmerPieChart(theme),
      ],
    );
  }

  Widget _buildShimmerLineChart(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for title
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              height: 20.h,
              width: 120.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Shimmer for chart area
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPieChart(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for title
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              height: 20.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Shimmer for pie chart
          Center(
            child: Shimmer(
              duration: const Duration(milliseconds: 1400),
              color: Colors.white.withOpacity(0.6),
              child: Container(
                height: 180.h,
                width: 180.w,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Shimmer for category list
          ...List.generate(4, (index) => 
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Shimmer(
                    duration: const Duration(milliseconds: 1400),
                    color: Colors.white.withOpacity(0.6),
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Shimmer(
                      duration: const Duration(milliseconds: 1400),
                      color: Colors.white.withOpacity(0.6),
                      child: Container(
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Shimmer(
                    duration: const Duration(milliseconds: 1400),
                    color: Colors.white.withOpacity(0.6),
                    child: Container(
                      width: 60.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicsContent(ThemeData theme, TransactionController transactionController, NumberFormat currencyFormatter, DateFormat dateFormatter, DateFormat dayFormatter, RxnInt selectedCategoryId) {
    return Column(
      children: [
        // Line Chart - Despesas diárias
        _buildLineChart(theme, transactionController, currencyFormatter, dayFormatter),
        
        // Pie Chart - Despesas por categoria
        _buildCategoryChart(theme, transactionController, selectedCategoryId, currencyFormatter, dateFormatter),
        
        // Outros gráficos
        DespesasPorTipoDePagamento(selectedMonth: selectedMonth),
        SizedBox(height: 30.h),
        GraficoPorcengtagemReceitaEDespesa(selectedMonth: selectedMonth),
        SizedBox(height: 20.h),
      ],
    );
  }

  List<TransactionModel> getFilteredTransactions(TransactionController transactionController) {
    var despesas = transactionController.transaction
        .where((e) => e.type == TransactionType.despesa)
        .toList();

    if (selectedMonth.isNotEmpty) {
      final int currentYear = DateTime.now().year;
      return despesas.where((transaction) {
        if (transaction.paymentDay == null) return false;
        DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
        String monthName = getAllMonths()[transactionDate.month - 1];
        return monthName == selectedMonth &&
            transactionDate.year == currentYear;
      }).toList();
    }

    return despesas;
  }

  Map<String, dynamic> getSparklineData(TransactionController transactionController, DateFormat dayFormatter) {
    var filteredTransactions = getFilteredTransactions(transactionController);

    int selectedMonthIndex = selectedMonth.isEmpty
        ? DateTime.now().month - 1
        : getAllMonths().indexOf(selectedMonth);
    int selectedYear = DateTime.now().year;

    int daysInMonth = DateTime(selectedYear, selectedMonthIndex + 1 + 1, 0).day;

    Map<String, double> dailyTotals = {};
    for (int i = 1; i <= daysInMonth; i++) {
      String day = i.toString().padLeft(2, '0');
      dailyTotals[day] = 0;
    }

    for (var transaction in filteredTransactions) {
      if (transaction.paymentDay != null) {
        DateTime date = DateTime.parse(transaction.paymentDay!);
        String dayKey = dayFormatter.format(date);
        double value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'));

        if (dailyTotals.containsKey(dayKey)) {
          dailyTotals[dayKey] = dailyTotals[dayKey]! + value;
        }
      }
    }

    List<String> sortedKeys = dailyTotals.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    List<double> sparklineData = [];
    List<String> labels = [];
    List<DateTime> dates = [];
    List<double> values = [];

    for (var day in sortedKeys) {
      sparklineData.add(dailyTotals[day]!);
      labels.add(day);
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

  Widget _buildLineChart(ThemeData theme, TransactionController transactionController, NumberFormat currencyFormatter, DateFormat dayFormatter) {
    var sparklineData = getSparklineData(transactionController, dayFormatter);
    List<double> data = sparklineData['data'];
    List<String> labels = sparklineData['labels'];

    if (data.isEmpty) {
      return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        child: Center(
          child: Text(
            "",
            style: TextStyle(
              color: DefaultColors.grey,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextGraphic(text: "Despesas diárias"),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna com os valores (vertical)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) {
                  double maxValue = data.isNotEmpty
                      ? data.reduce((a, b) => a > b ? a : b)
                      : 0;
                  double stepValue = maxValue / 4;
                  double value = maxValue - (stepValue * index);

                  return Container(
                    height: 24.h,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(bottom: index == 4 ? 0 : 4.h),
                    child: Text(
                      currencyFormatter.format(value),
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: DefaultColors.grey,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(width: 8.w),
              // Área principal do gráfico
              Expanded(
                child: Column(
                  children: [
                    // Gráfico LineChart com fl_chart
                    SizedBox(
                      height: 120.h,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) =>
                                  DefaultColors.green.withOpacity(0.8),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((touchedSpot) {
                                  return LineTooltipItem(
                                    currencyFormatter.format(touchedSpot.y),
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 8.sp,
                                    ),
                                  );
                                }).toList();
                              },
                              tooltipPadding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 4.h,
                              ),
                              tooltipRoundedRadius: 4.r,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: data.isNotEmpty
                                ? (data.reduce((a, b) => a > b ? a : b) > 0
                                    ? data.reduce((a, b) => a > b ? a : b) / 4
                                    : 1)
                                : 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: DefaultColors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (data.length - 1).toDouble(),
                          minY: 0,
                          maxY: data.isNotEmpty &&
                                  data.reduce((a, b) => a > b ? a : b) > 0
                              ? data.reduce((a, b) => a > b ? a : b) * 1.2
                              : 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value,
                                );
                              }).toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: DefaultColors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    DefaultColors.green.withOpacity(0.3),
                                    DefaultColors.green.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 250),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Labels dos dias
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        labels.length > 10 ? 10 : labels.length,
                        (index) {
                          int step = labels.length > 10 ? (labels.length / 10).floor() : 1;
                          int actualIndex = index * step;
                          if (actualIndex < labels.length) {
                            return Text(
                              labels[actualIndex],
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: DefaultColors.grey,
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(ThemeData theme, TransactionController transactionController, RxnInt selectedCategoryId, NumberFormat currencyFormatter, DateFormat dateFormatter) {
    var filteredTransactions = getFilteredTransactions(transactionController);
    var categories = filteredTransactions
        .map((e) => e.category)
        .where((e) => e != null)
        .toSet()
        .toList()
        .cast<int>();

    var data = categories
        .map((e) => {
              "category": e,
              "value": filteredTransactions
                  .where((element) => element.category == e)
                  .fold<double>(
                0.0,
                (previousValue, element) {
                  return previousValue +
                      double.parse(element.value
                          .replaceAll('.', '')
                          .replaceAll(',', '.'));
                },
              ),
              "name": findCategoryById(e)?['name'],
              "color": findCategoryById(e)?['color'],
              "icon": findCategoryById(e)?['icon'],
            })
        .toList();

    data.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    double totalValue = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element['value'] as double),
    );

    var chartData = data
        .map((e) => PieChartSectionData(
              value: e['value'] as double,
              color: e['color'] as Color,
              title: '',
              radius: 50,
              showTitle: false,
              badgePositionPercentageOffset: 0.9,
            ))
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

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextGraphic(text: "Despesas por categoria"),
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
          WidgetListCategoryGraphics(
            data: data,
            totalValue: totalValue,
            selectedCategoryId: selectedCategoryId,
            theme: theme,
            currencyFormatter: currencyFormatter,
            dateFormatter: dateFormatter,
            monthName: selectedMonth,
          ),
        ],
      ),
    );
  }
}
