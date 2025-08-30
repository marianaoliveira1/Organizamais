// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
import 'pages/select_categories_page.dart';
import 'pages/category_report_page.dart';
import 'pages/spending_shift_balance_page.dart';

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
  Set<int> _selectedCategoryIds = {};
  final Set<int> _essentialCategoryIds = {
    // Moradia / Aluguel / Financiamento / Condomínio / Contas / Manutenção
    5, // Moradia
    37, // Financiamento
    90, // Condomínio
    26, // Contas (água, luz, gás, internet)
    19, // Manutenção e reparos
    // Alimentação (Supermercado/Feira/Padaria)
    1, // Alimentação
    29, // Mercado
    69, // Padaria
    // Transporte (essencial)
    17, // Transporte
    28, // Combustível
    93, // Transporte público
    22, // Transporte por Aplicativo
    71, // Pedágio/Estacionamento
    70, // IPVA
    32, // Seguro do Carro
    92, // Manutenção do carro
    // Saúde
    15, // Saúde
    36, // Plano de Saúde/Seguro de vida
    24, // Farmácia
    86, // Exames
    87, // Consultas Médicas
    // Educação
    9, // Educação
    94, // Escola / Material escolar
    96, // Cursos
    // Seguros e Obrigações
    80, // Seguros
    35, // Impostos
    91, // IPTU
  };
  // Mapa para armazenar seleção de essenciais por mês (chave YYYY-MM)
  final Map<String, Set<int>> _monthEssentialCategoryIds = {};
  bool _showWeekly = false;
  bool _showBarCategoryChart = false;

  @override
  void initState() {
    super.initState();
    _monthScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    final int currentMonthIndex = DateTime.now().month - 1;
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset =
        currentMonthIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);
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
    final dayFormatter = DateFormat('dd');

    // Variável observável para controlar a categoria selecionada
    final selectedCategoryId = RxnInt(null);

    // já centraliza no initState

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
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 8.w),
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
                        return _buildGraphicsContent(
                            theme,
                            transactionController,
                            currencyFormatter,
                            dateFormatter,
                            dayFormatter,
                            selectedCategoryId);
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

  // removido seletor por modal (substituído por página dedicada)

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
          ...List.generate(
            4,
            (index) => Padding(
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

  Widget _buildGraphicsContent(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter,
      DateFormat dateFormatter,
      DateFormat dayFormatter,
      RxnInt selectedCategoryId) {
    return Column(
      children: [
        // Line Chart - Despesas diárias
        _buildLineChart(
            theme, transactionController, currencyFormatter, dayFormatter),
        AdsBanner(),
        SizedBox(height: 20.h),
        // Pie Chart - Despesas por categoria
        _buildCategoryChart(theme, transactionController, selectedCategoryId,
            currencyFormatter, dateFormatter),

        SizedBox(height: 16.h),
        _buildEssentialsVsNonEssentialsChart(
            theme, transactionController, currencyFormatter),
        AdsBanner(),
        SizedBox(height: 20.h),

        // Botão: Balanço de troca de gastos (alimentação)
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SpendingShiftBalancePage(
                  selectedMonth: selectedMonth,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 14.w,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📊 Balanço de Gastos por Categoria",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DefaultTextGraphic(
                      text: 'Todas as categorias usadas no mês',
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: theme.primaryColor),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryReportPage(
                  selectedMonth: selectedMonth,
                ),
              ),
            );
          },
          child: Container(
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
                Text(
                  "📊 Relatório Mensal",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextGraphic(
                      text: 'Comparativo com mês anterior',
                    ),
                    Icon(Icons.chevron_right, color: theme.primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Outros gráficos
        DespesasPorTipoDePagamento(selectedMonth: selectedMonth),
        SizedBox(height: 30.h),

        AdsBanner(),
        SizedBox(height: 20.h),

        GraficoPorcengtagemReceitaEDespesa(selectedMonth: selectedMonth),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildEssentialsVsNonEssentialsChart(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter) {
    final filteredTransactions = getFilteredTransactions(transactionController);
    final String monthKey = _getMonthKey();
    final Set<int> effectiveEssentialIds =
        _monthEssentialCategoryIds[monthKey] ?? _essentialCategoryIds;

    double essentialTotal = 0.0;
    double nonEssentialTotal = 0.0;
    final Set<int> usedEssentialCategoryIds = {};
    final Set<int> usedNonEssentialCategoryIds = {};
    for (var t in filteredTransactions) {
      final double value =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      final int? categoryId = t.category;
      if (categoryId != null && effectiveEssentialIds.contains(categoryId)) {
        essentialTotal += value;
        usedEssentialCategoryIds.add(categoryId);
      } else {
        nonEssentialTotal += value;
        if (categoryId != null) usedNonEssentialCategoryIds.add(categoryId);
      }
    }

    final double total = essentialTotal + nonEssentialTotal;
    if (total <= 0) {
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 14.w,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Text(
            "Sem dados para Essenciais x Não essenciais",
            style: TextStyle(
              color: DefaultColors.grey,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    }

    final double essentialPct = (essentialTotal / total) * 100.0;
    final double nonEssentialPct = (nonEssentialTotal / total) * 100.0;
    final List<String> essentialNames = usedEssentialCategoryIds
        .map((id) => findCategoryById(id)?['name'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList()
      ..sort();
    final List<String> nonEssentialNames = usedNonEssentialCategoryIds
        .map((id) => findCategoryById(id)?['name'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList()
      ..sort();

    // Monta lista de categorias usadas no mês para o seletor
    final List<int> monthUsedCategories = filteredTransactions
        .map((e) => e.category)
        .where((e) => e != null)
        .toSet()
        .toList()
        .cast<int>();

    // removed: detailed data list not needed for selection mode

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
                child: DefaultTextGraphic(text: "Essenciais x Não essenciais"),
              ),
              IconButton(
                icon: Icon(Icons.tune, color: theme.primaryColor),
                onPressed: () async {
                  final Set<int> initialSelected = {
                    ...effectiveEssentialIds
                        .where((id) => monthUsedCategories.contains(id))
                  };
                  final result = await Navigator.of(context).push<Set<int>>(
                    MaterialPageRoute(
                      builder: (_) => CategoryReportPage(
                        selectedMonth: selectedMonth,
                        selectionMode: true,
                        initialSelected: initialSelected,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _monthEssentialCategoryIds[monthKey] = result;
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 180.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 26,
                centerSpaceColor: theme.cardColor,
                sections: [
                  PieChartSectionData(
                    value: essentialTotal,
                    color: DefaultColors.green,
                    title: '',
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: nonEssentialTotal,
                    color: DefaultColors.redDark,
                    title: '',
                    radius: 50,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              _buildLegendItem(
                color: DefaultColors.green,
                label: 'Essenciais',
                amount: currencyFormatter.format(essentialTotal),
                percent: essentialPct,
                theme: theme,
              ),
              if (essentialNames.isNotEmpty) ...[
                _buildCategoryChips(essentialNames, theme, DefaultColors.green),
              ],
              SizedBox(
                height: 10.h,
              ),
              _buildLegendItem(
                color: DefaultColors.redDark,
                label: 'Não essenciais',
                amount: currencyFormatter.format(nonEssentialTotal),
                percent: nonEssentialPct,
                theme: theme,
              ),
            ],
          ),
          if (nonEssentialNames.isNotEmpty) ...[
            _buildCategoryChips(
                nonEssentialNames, theme, DefaultColors.redDark),
          ],
        ],
      ),
    );
  }

  String _getMonthKey() {
    int month;
    if (selectedMonth.isEmpty) {
      month = DateTime.now().month;
    } else {
      month = getAllMonths().indexOf(selectedMonth) + 1;
      if (month <= 0) month = DateTime.now().month;
    }
    final int year = DateTime.now().year;
    final String monthStr = month.toString().padLeft(2, '0');
    return '$year-$monthStr';
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String amount,
    required double percent,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$amount  ·  ${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: DefaultColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(List<String> names, ThemeData theme, Color color) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: names
          .map(
            (name) => Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.primaryColor,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  List<TransactionModel> getFilteredTransactions(
      TransactionController transactionController) {
    var despesas = transactionController.transaction
        .where((e) => e.type == TransactionType.despesa)
        .toList();

    final String selectedMonth = this.selectedMonth;
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

  Map<String, dynamic> getSparklineData(
      TransactionController transactionController, DateFormat dayFormatter) {
    var filteredTransactions = getFilteredTransactions(transactionController);

    final String selectedMonth = this.selectedMonth;
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

  Widget _buildLineChart(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter,
      DateFormat dayFormatter) {
    var sparklineData = getSparklineData(transactionController, dayFormatter);
    List<double> data = sparklineData['data'];

    final weeklyTotals = _getWeeklyTotals(transactionController);
    final weekRangeLabels = _getWeekRangeLabels();

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
                    if (_showWeekly) {
                      setState(() => _showWeekly = false);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: !_showWeekly
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
                        color: !_showWeekly
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
                    if (!_showWeekly) {
                      setState(() => _showWeekly = true);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _showWeekly
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
                        color: _showWeekly
                            ? theme.primaryColor
                            : DefaultColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (!_showWeekly)
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
                        children: (sparklineData['labels'] as List<String>)
                            .map((day) {
                          return Text(
                            day,
                            style: TextStyle(
                              fontSize: 6.sp,
                              color: DefaultColors.grey,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (_showWeekly)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180.h,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (weeklyTotals.isNotEmpty
                                  ? weeklyTotals.reduce((a, b) => a > b ? a : b)
                                  : 0) >
                              0
                          ? weeklyTotals.reduce((a, b) => a > b ? a : b) * 1.2
                          : 100,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              String label;
                              if (value >= 1000) {
                                label = '${(value / 1000).round()}k';
                              } else {
                                label = value.round().toString();
                              }
                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: DefaultColors.grey,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= weeklyTotals.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  weekRangeLabels[idx],
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (weeklyTotals.isNotEmpty
                                    ? weeklyTotals
                                        .reduce((a, b) => a > b ? a : b)
                                    : 0) >
                                0
                            ? (weeklyTotals.reduce((a, b) => a > b ? a : b) / 4)
                            : 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: DefaultColors.grey.withOpacity(0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(weeklyTotals.length, (i) {
                        final y = weeklyTotals[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: y,
                              color: DefaultColors.green,
                              borderRadius: BorderRadius.circular(4.r),
                              width: 14.w,
                            ),
                          ],
                        );
                      }),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              DefaultColors.green.withOpacity(0.85),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              currencyFormatter.format(rod.toY),
                              TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(weeklyTotals.length, (index) {
                      final value = weeklyTotals[index];
                      if (value <= 0) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              weekRangeLabels[index],
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: DefaultColors.grey,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(value),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: DefaultColors.grey,
                          ),
                        ),
                        Text(
                          currencyFormatter
                              .format(weeklyTotals.fold(0.0, (s, v) => s + v)),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: DefaultColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<double> _getWeeklyTotals(TransactionController transactionController) {
    final filteredTransactions = getFilteredTransactions(transactionController);
    final List<double> weeklyTotals = List<double>.filled(5, 0.0);
    for (var t in filteredTransactions) {
      if (t.paymentDay == null) continue;
      final DateTime date = DateTime.parse(t.paymentDay!);
      final int day = date.day;
      final int weekIndex = ((day - 1) ~/ 7).clamp(0, 4);
      final double value =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      weeklyTotals[weekIndex] += value;
    }
    return weeklyTotals;
  }

  // Colors for potential future multi-series weekly charts (kept minimal)
  // Using DefaultColors.green for single-series expenses bars

  List<String> _getWeekRangeLabels() {
    final String monthName = selectedMonth;
    final int year = DateTime.now().year;
    int month = DateTime.now().month;
    if (monthName.isNotEmpty) {
      final idx = getAllMonths().indexOf(monthName);
      if (idx >= 0) month = idx + 1;
    }
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    String pad(int d) => d.toString().padLeft(1, '0');
    final List<List<int>> ranges = [
      [1, 7],
      [8, 14],
      [15, 21],
      [22, 28],
      [29, daysInMonth],
    ];
    return ranges
        .map((r) => '${pad(r[0])}-${pad(r[1])}')
        .toList(growable: false);
  }

  // Removed old week label function (using ordinal labels to match requested style)

  Widget _buildCategoryChart(
      ThemeData theme,
      TransactionController transactionController,
      RxnInt selectedCategoryId,
      NumberFormat currencyFormatter,
      DateFormat dateFormatter) {
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
      (previousValue, element) => previousValue + (element['value'] as double),
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
      margin: EdgeInsets.only(bottom: 16.h),
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
                child: DefaultTextGraphic(text: "Despesas por categoria"),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: theme.primaryColor),
                onPressed: () async {
                  final result = await Navigator.of(context).push<Set<int>>(
                    MaterialPageRoute(
                      builder: (_) => SelectCategoriesPage(
                        data: data,
                        initialSelected: _selectedCategoryIds,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedCategoryIds = result;
                    });
                  }
                },
              ),
            ],
          ),
          // SizedBox(height: 6.h),
          // Row(
          //   children: [
          //     // Pizza toggle with bordered container
          //     GestureDetector(
          //       onTap: () {
          //         if (_showBarCategoryChart) {
          //           setState(() => _showBarCategoryChart = false);
          //         }
          //       },
          //       child: Container(
          //         padding: EdgeInsets.all(6.w),
          //         decoration: BoxDecoration(
          //           color: Colors.transparent,
          //           border: Border.all(
          //             color: !_showBarCategoryChart
          //                 ? theme.primaryColor
          //                 : DefaultColors.grey.withOpacity(0.3),
          //           ),
          //           borderRadius: BorderRadius.circular(10.r),
          //         ),
          //         child: Icon(
          //           Icons.pie_chart_rounded,
          //           color: !_showBarCategoryChart
          //               ? theme.primaryColor
          //               : DefaultColors.grey,
          //           size: 18.sp,
          //         ),
          //       ),
          //     ),
          //     SizedBox(width: 8.w),
          //     // Bar toggle with card-colored background and border
          //     GestureDetector(
          //       onTap: () {
          //         if (!_showBarCategoryChart) {
          //           setState(() => _showBarCategoryChart = true);
          //         }
          //       },
          //       child: Container(
          //         padding: EdgeInsets.all(6.w),
          //         decoration: BoxDecoration(
          //           color: theme.cardColor,
          //           border: Border.all(
          //             color: _showBarCategoryChart
          //                 ? theme.primaryColor
          //                 : DefaultColors.grey.withOpacity(0.3),
          //           ),
          //           borderRadius: BorderRadius.circular(10.r),
          //         ),
          //         child: Icon(
          //           Iconsax.chart_2,
          //           color: _showBarCategoryChart
          //               ? theme.primaryColor
          //               : DefaultColors.grey,
          //           size: 18.sp,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 16.h),
          if (!_showBarCategoryChart)
            Center(
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<Set<int>>(
                    MaterialPageRoute(
                      builder: (_) => SelectCategoriesPage(
                        data: data,
                        initialSelected: _selectedCategoryIds,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedCategoryIds = result;
                    });
                  }
                },
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
            )
          else
            SizedBox(
              height: 220.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (data.isNotEmpty
                              ? (data
                                  .map((e) => e['value'] as double)
                                  .reduce((a, b) => a > b ? a : b))
                              : 0) >
                          0
                      ? (data
                              .map((e) => e['value'] as double)
                              .reduce((a, b) => a > b ? a : b) *
                          1.2)
                      : 100,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final String name =
                              (data[idx]['name'] ?? '') as String;
                          final String abbr =
                              name.length <= 3 ? name : name.substring(0, 3);
                          return Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              abbr,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: DefaultColors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final double v = data[i]['value'] as double;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: v,
                          width: 12.w,
                          color: (data[i]['color'] as Color?) ??
                              theme.primaryColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    );
                  }),
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
