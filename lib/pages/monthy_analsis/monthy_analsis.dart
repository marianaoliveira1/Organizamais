// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/utils/color.dart';

import 'package:organizamais/pages/transaction/pages/category_page.dart';

// import '../../ads_banner/ads_banner.dart';
import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';

import '../initial/widget/custom_drawer.dart';
import 'widget/financial_summary_cards.dart';
import 'widget/monthly_financial_chart.dart';
import 'widget/annual_balance_spline_chart.dart';
import 'widget/widget_category_analise.dart';
import '../resume/widgtes/text_not_transaction.dart';
import 'widget/payment_type_analise_page.dart';
import 'package:organizamais/widgetes/info_card.dart';
import 'widget/monthly_summary_page.dart';
import '../../ads_banner/ads_banner.dart';

class MonthlyAnalysisPage extends StatefulWidget {
  const MonthlyAnalysisPage({super.key});

  @override
  State<MonthlyAnalysisPage> createState() => _MonthlyAnalysisPageState();
}

class _MonthlyAnalysisPageState extends State<MonthlyAnalysisPage> {
  // Dropdown: mês/ano
  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  static const List<String> _monthsPt = [
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

  // Paleta auxiliar para tipos de pagamento (fallback)
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
        return DefaultColors.hotPink;
      default:
        int colorIndex = paymentType.hashCode.abs() % _customCardColors.length;
        return _customCardColors[colorIndex];
    }
  }

  List<TransactionModel> _filterMonth(List<TransactionModel> all) {
    return all.where((t) {
      if (t.paymentDay == null) return false;
      final d = DateTime.parse(t.paymentDay!);
      return d.month == _selectedMonth && d.year == _selectedYear;
    }).toList();
  }

  double _sumByType(List<TransactionModel> txs, TransactionType type) {
    return txs.where((t) => t.type == type).fold(
        0.0,
        (s, t) =>
            s + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
  }

  Future<double> _fetchGoalDepositsForMonth() async {
    final goals = Get.find<GoalController>().goal;
    if (goals.isEmpty) return 0.0;
    final DateTime start = DateTime(_selectedYear, _selectedMonth, 1);
    final DateTime end =
        DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    double total = 0.0;
    for (final g in goals) {
      if (g.id == null) continue;
      try {
        final qs = await FirebaseFirestore.instance
            .collection('goals')
            .doc(g.id!)
            .collection('transactions')
            .where('isAddition', isEqualTo: true)
            .where('date', isGreaterThanOrEqualTo: start)
            .where('date', isLessThanOrEqualTo: end)
            .get();
        for (final d in qs.docs) {
          total += (d.data()['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {}
    }
    return total;
  }

  Widget _buildMonthlyAnalysisSection(
      ThemeData theme, TransactionController controller) {
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    final txs = _filterMonth(controller.transaction);
    final receitas = _sumByType(txs, TransactionType.receita);
    final despesas = _sumByType(txs, TransactionType.despesa);
    final saldo = receitas - despesas;

    // Categorias (despesa) do mês
    final categorias = <int, double>{};
    for (final t in txs.where(
        (t) => t.type == TransactionType.despesa && t.category != null)) {
      final id = t.category!;
      final v = double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      categorias[id] = (categorias[id] ?? 0.0) + v;
    }
    final catData = categorias.entries
        .map((e) => {
              'category': e.key,
              'value': e.value,
              'name': findCategoryById(e.key)?['name'],
              'color': findCategoryById(e.key)?['color'],
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final totalCat =
        catData.fold<double>(0.0, (s, m) => s + (m['value'] as double));

    // Parcelas do mês
    final parcelas = txs.where((t) => t.title.contains('Parcela')).toList();
    final totalParcelas = parcelas.fold<double>(
        0.0,
        (s, p) =>
            s + double.parse(p.value.replaceAll('.', '').replaceAll(',', '.')));

    // Por tipo de pagamento (despesa)
    final byType = <String, double>{};
    for (final t in txs.where((t) => t.type == TransactionType.despesa)) {
      final key = (t.paymentType ?? 'Outros').trim();
      final val =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      byType[key] = (byType[key] ?? 0.0) + val;
    }
    final payData = byType.entries
        .map((e) => {
              'paymentType': e.key,
              'value': e.value,
              'color': _getPaymentTypeColor(e.key),
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final payTotal =
        payData.fold<double>(0.0, (s, m) => s + (m['value'] as double));

    return InfoCard(
      title: 'Análise Mensal',
      icon: Iconsax.calendar_1,
      onTap: () {},
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(.25)),
                  ),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedMonth,
                    underline: const SizedBox.shrink(),
                    items: List.generate(
                        12,
                        (i) => DropdownMenuItem<int>(
                              value: i + 1,
                              child: Text(_monthsPt[i],
                                  style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 12.sp)),
                            )),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedMonth = v);
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: theme.primaryColor.withOpacity(.25)),
                ),
                child: Text('$_selectedYear',
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _metricPill(theme,
                  label: 'Saldo',
                  value: saldo,
                  color: saldo >= 0
                      ? DefaultColors.greenDark
                      : DefaultColors.redDark,
                  currency: currency),
              SizedBox(width: 8.w),
              _metricPill(theme,
                  label: 'Receitas',
                  value: receitas,
                  color: DefaultColors.greenDark,
                  currency: currency),
              SizedBox(width: 8.w),
              _metricPill(theme,
                  label: 'Despesas',
                  value: despesas,
                  color: theme.primaryColor,
                  currency: currency),
            ],
          ),
          SizedBox(height: 16.h),
          // Categorias (pizza)
          if (catData.isNotEmpty) ...[
            Text('Por categoria',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            SizedBox(
              height: 180.h,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                legend: const Legend(isVisible: false),
                series: <CircularSeries<Map<String, dynamic>, String>>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: catData,
                    xValueMapper: (e, _) => (e['name'] as String? ?? ''),
                    yValueMapper: (e, _) => (e['value'] as double),
                    pointColorMapper: (e, _) =>
                        (e['color'] as Color?) ??
                        theme.primaryColor.withOpacity(.3),
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: false),
                    dataLabelMapper: (e, _) {
                      final v = (e['value'] as double);
                      final pct = totalCat > 0 ? (v / totalCat) * 100 : 0;
                      return '${(e['name'] as String? ?? '')}\n${pct.toStringAsFixed(0)}%';
                    },
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '8%',
                    sortingOrder: SortingOrder.descending,
                    sortFieldValueMapper: (e, _) => (e['value'] as double),
                  )
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ] else ...[
            Text('Sem despesas categorizadas neste mês',
                style: TextStyle(color: DefaultColors.grey, fontSize: 10.sp)),
            SizedBox(height: 12.h),
          ],

          // Parcelas
          Text('Parcelas do mês (${parcelas.length})',
              style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(parcelas.isEmpty ? 'Nenhuma parcela' : 'Total',
                  style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
              Text(currency.format(totalParcelas),
                  style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 16.h),

          // Depósitos em metas financeiras
          FutureBuilder<double>(
            future: _fetchGoalDepositsForMonth(),
            builder: (context, snapshot) {
              final val = snapshot.data ?? 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Depósitos em metas',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total no mês',
                          style: TextStyle(
                              fontSize: 10.sp, color: DefaultColors.grey)),
                      Text(currency.format(val),
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),

          // Tipos de pagamento
          if (payData.isNotEmpty) ...[
            Text('Por tipo de pagamento',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            SizedBox(
              height: 180.h,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                legend: const Legend(isVisible: false),
                series: <CircularSeries<Map<String, dynamic>, String>>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: payData,
                    xValueMapper: (e, _) => (e['paymentType'] as String),
                    yValueMapper: (e, _) => (e['value'] as double),
                    pointColorMapper: (e, _) => (e['color'] as Color),
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: false),
                    dataLabelMapper: (e, _) {
                      final v = (e['value'] as double);
                      final pct = payTotal > 0 ? (v / payTotal) * 100 : 0;
                      return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                    },
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '8%',
                    sortingOrder: SortingOrder.descending,
                    sortFieldValueMapper: (e, _) => (e['value'] as double),
                  )
                ],
              ),
            ),
          ] else ...[
            Text('Sem despesas por tipo neste mês',
                style: TextStyle(color: DefaultColors.grey, fontSize: 10.sp)),
          ],
        ],
      ),
    );
  }

  Widget _metricPill(ThemeData theme,
      {required String label,
      required double value,
      required Color color,
      required NumberFormat currency}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
            SizedBox(height: 2.h),
            Text(currency.format(value),
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Análise Anual',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Obx(() {
              final hasAnyData = controller.transactionsAno.isNotEmpty;
              if (!hasAnyData) {
                return Expanded(
                  child: Center(
                    child: DefaultTextNotTransaction(),
                  ),
                );
              }
              return Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                    ),
                    child: Column(
                      children: [
                        // Nova seção: Análise Mensal

                        FinancialSummaryCards(),
                        SizedBox(height: 4.h),
                        AdsBanner(),
                        SizedBox(height: 10.h),
                        // Botão de acesso ao resumo mensal
                        InfoCard(
                          title: 'Resumo Mensal',
                          onTap: () async {
                            // Exibe anúncio de tela cheia e depois navega
                            try {
                              await AdsInterstitial.show();
                            } catch (_) {}
                            Get.to(() => MonthlySummaryPage(
                                  initialMonth: _selectedMonth,
                                  initialYear: _selectedYear,
                                ));
                          },
                          content: Row(
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Iconsax.calendar_1,
                                    color: theme.primaryColor, size: 18.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Veja receitas, despesas, parcelas e gráficos do mês',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: theme.primaryColor),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        MonthlyFinancialChart(),
                        SizedBox(height: 16.h),
                        AdsBanner(),
                        SizedBox(height: 10.h),
                        AnnualBalanceSplineChart(),
                        SizedBox(height: 10.h),
                        AdsBanner(),
                        Obx(
                          () {
                            var filteredTransactions = controller
                                .transactionsAno
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
                                        .where(
                                            (element) => element.category == e)
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
                                    "icon": findCategoryById(e)?[
                                        'icon'], // Adicionado para acessar o ícone
                                  },
                                )
                                .toList();

                            // Ordenar os dados por valor (decrescente)
                            data.sort((a, b) => (b['value'] as double)
                                .compareTo(a['value'] as double));

                            double totalValue = data.fold(
                              0.0,
                              (previousValue, element) =>
                                  previousValue + (element['value'] as double),
                            );

                            // Usaremos 'data' diretamente como fonte para o Syncfusion Pie

                            if (data.isEmpty) {
                              final vh = MediaQuery.of(context).size.height;
                              return SizedBox(
                                height: vh * 0.7,
                                child: const Center(
                                  child: DefaultTextNotTransaction(),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                SizedBox(
                                  height: 30.h,
                                ),
                                InfoCard(
                                  title: 'Por categoria',
                                  onTap: () {
                                    Get.to(() => const CategoryPage());
                                  },
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          height: 180.h,
                                          child: SfCircularChart(
                                            margin: EdgeInsets.zero,
                                            legend: Legend(isVisible: false),
                                            series: <CircularSeries<
                                                Map<String, dynamic>, String>>[
                                              PieSeries<Map<String, dynamic>,
                                                  String>(
                                                dataSource: data,
                                                xValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['name'] ?? '')
                                                            .toString(),
                                                yValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['value'] as double),
                                                pointColorMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['color']
                                                            as Color?) ??
                                                        Colors.grey
                                                            .withOpacity(0.5),
                                                dataLabelMapper:
                                                    (Map<String, dynamic> e,
                                                        _) {
                                                  final double v =
                                                      (e['value'] as double);
                                                  final double pct =
                                                      totalValue > 0
                                                          ? (v / totalValue) *
                                                              100
                                                          : 0;
                                                  return '${(e['name'] ?? '').toString()}\n${pct.toStringAsFixed(0)}%';
                                                },
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: false),
                                                explode: true,
                                                explodeIndex:
                                                    data.isEmpty ? null : 0,
                                                explodeOffset: '8%',
                                                sortingOrder:
                                                    SortingOrder.descending,
                                                sortFieldValueMapper:
                                                    (Map<String, dynamic> e,
                                                            _) =>
                                                        (e['value'] as double),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      WidgetCategoryAnalise(
                                        data: data,
                                        totalValue: totalValue,
                                        theme: theme,
                                        currencyFormatter:
                                            NumberFormat.currency(
                                          locale: 'pt_BR',
                                          symbol: 'R\$',
                                          decimalDigits: 2,
                                        ),
                                        monthName: '',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                AdsBanner(),
                                SizedBox(
                                  height: 20.h,
                                ),
                                // Por tipo de pagamento (ANUAL)
                                Builder(
                                  builder: (context) {
                                    // Agrupar despesas anuais por tipo de pagamento
                                    final payTypes = filteredTransactions
                                        .map((e) => e.paymentType)
                                        .where((e) => e != null)
                                        .toSet()
                                        .toList()
                                        .cast<String>();

                                    final payData = payTypes
                                        .map(
                                          (pt) => {
                                            'paymentType': pt,
                                            'value': filteredTransactions
                                                .where(
                                                  (t) =>
                                                      t.paymentType != null &&
                                                      t.paymentType!
                                                              .trim()
                                                              .toLowerCase() ==
                                                          pt
                                                              .trim()
                                                              .toLowerCase(),
                                                )
                                                .fold<double>(
                                                  0.0,
                                                  (prev, t) =>
                                                      prev +
                                                      double.parse(
                                                        t.value
                                                            .replaceAll('.', '')
                                                            .replaceAll(
                                                                ',', '.'),
                                                      ),
                                                ),
                                            'color': _getPaymentTypeColor(pt),
                                          },
                                        )
                                        .toList();

                                    payData.sort(
                                      (a, b) => (b['value'] as double)
                                          .compareTo(a['value'] as double),
                                    );

                                    final payTotal = payData.fold<double>(
                                      0.0,
                                      (prev, e) =>
                                          prev + (e['value'] as double),
                                    );

                                    if (payData.isEmpty || payTotal <= 0) {
                                      return const SizedBox.shrink();
                                    }

                                    return InfoCard(
                                      title: 'Por tipo de pagamento',
                                      onTap: () {},
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              height: 180.h,
                                              child: SfCircularChart(
                                                margin: EdgeInsets.zero,
                                                legend:
                                                    Legend(isVisible: false),
                                                series: <CircularSeries<
                                                    Map<String, dynamic>,
                                                    String>>[
                                                  PieSeries<
                                                      Map<String, dynamic>,
                                                      String>(
                                                    dataSource: payData,
                                                    xValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['paymentType']
                                                                as String),
                                                    yValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['value']
                                                                as double),
                                                    pointColorMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['color']
                                                                as Color),
                                                    dataLabelMapper:
                                                        (Map<String, dynamic> e,
                                                            _) {
                                                      final double v =
                                                          (e['value']
                                                              as double);
                                                      final double pct =
                                                          payTotal > 0
                                                              ? (v / payTotal) *
                                                                  100
                                                              : 0;
                                                      return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                                                    },
                                                    dataLabelSettings:
                                                        const DataLabelSettings(
                                                            isVisible: false),
                                                    explode: true,
                                                    explodeIndex:
                                                        payData.isEmpty
                                                            ? null
                                                            : 0,
                                                    explodeOffset: '8%',
                                                    sortingOrder:
                                                        SortingOrder.descending,
                                                    sortFieldValueMapper:
                                                        (Map<String, dynamic> e,
                                                                _) =>
                                                            (e['value']
                                                                as double),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: payData.length,
                                            itemBuilder: (context, index) {
                                              final item = payData[index];
                                              final String pt =
                                                  item['paymentType'] as String;
                                              final double val =
                                                  item['value'] as double;
                                              final Color c =
                                                  item['color'] as Color;
                                              final double perc =
                                                  (val / payTotal) * 100;

                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 6.h,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.to(
                                                      () =>
                                                          PaymentTypeAnalysisPage(
                                                        paymentType: pt,
                                                        paymentColor: c,
                                                        totalValue: val,
                                                        percentual: perc,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 20.w,
                                                        height: 20.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: c,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      9.r),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    pt,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: theme
                                                                          .primaryColor,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 8.w),
                                                                Text(
                                                                  NumberFormat
                                                                      .currency(
                                                                    locale:
                                                                        'pt_BR',
                                                                    symbol:
                                                                        'R\$',
                                                                    decimalDigits:
                                                                        2,
                                                                  ).format(val),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: theme
                                                                        .primaryColor,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 6.h),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  '${perc.toStringAsFixed(0)}%',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color:
                                                                        DefaultColors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 6.w),
                                                                Icon(
                                                                  Iconsax
                                                                      .arrow_right_3,
                                                                  size: 12.sp,
                                                                  color:
                                                                      DefaultColors
                                                                          .grey,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
