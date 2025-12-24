// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';
import 'package:organizamais/utils/color.dart';

import 'package:organizamais/pages/monthy_analsis/widget/category_analise_page.dart';

// import '../../ads_banner/ads_banner.dart';
import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';

import '../initial/widget/custom_drawer.dart';
import 'widget/financial_summary_cards.dart';
import 'widget/monthly_financial_chart.dart';
import 'widget/annual_balance_spline_chart.dart';
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
  final int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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
    // Cache de datas parseadas para evitar parsing repetido
    final dateCache = <TransactionModel, DateTime>{};
    for (final t in all) {
      if (t.paymentDay != null) {
        try {
          dateCache[t] = DateTime.parse(t.paymentDay!);
        } catch (_) {}
      }
    }

    return all.where((t) {
      final d = dateCache[t];
      if (d == null) return false;
      return d.month == _selectedMonth && d.year == _selectedYear;
    }).toList();
  }

  List<TransactionModel> _filterYear(List<TransactionModel> all, int year) {
    final now = DateTime.now();
    final currentYear = now.year;
    final today = DateTime(now.year, now.month, now.day);

    // Cache de datas parseadas para evitar parsing repetido
    final dateCache = <TransactionModel, DateTime>{};
    for (final t in all) {
      if (t.paymentDay != null) {
        try {
          dateCache[t] = DateTime.parse(t.paymentDay!);
        } catch (_) {}
      }
    }

    return all.where((t) {
      final d = dateCache[t];
      if (d == null) return false;

      // Verificar se é do ano selecionado
      if (d.year != year) return false;

      // Nunca mostrar datas futuras (ex: ano selecionado maior que o ano atual)
      final transactionDate = DateTime(d.year, d.month, d.day);
      if (transactionDate.isAfter(today)) return false;

      // Se o ano selecionado for o ano atual, filtrar apenas até hoje
      // Se for um ano passado, mostrar todas as transações daquele ano
      if (year == currentYear) {
        return transactionDate.isBefore(today) ||
            transactionDate.isAtSameMomentAs(today);
      }

      // Para anos passados, mostrar todas as transações
      return true;
    }).toList();
  }

  // Helper otimizado para parsing de valores
  static double _parseValue(String value) {
    try {
      final cleaned = value.replaceAll('R\$', '').trim();
      if (cleaned.contains(',')) {
        return double.parse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
      }
      return double.parse(cleaned.replaceAll(' ', ''));
    } catch (_) {
      return 0.0;
    }
  }

  double _sumByType(List<TransactionModel> txs, TransactionType type) {
    double total = 0.0;
    for (final t in txs) {
      if (t.type == type) {
        total += _parseValue(t.value);
      }
    }
    return total;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final double width = constraints.maxWidth;
        final double height = size.height;
        final bool isTablet = width > 600;
        final double referenceWidth =
            size.shortestSide.clamp(360.0, 600.0).toDouble();

        final media = MediaQuery.of(context);
        final double textScale = isTablet
            ? media.textScaleFactor
            : media.textScaleFactor.clamp(0.85, 0.95);

        double pw(double value) => (value / 375) * width;
        double ph(double value) => (value / 812) * height;
        double pr(double value) => (value / 375) * width;
        double pf(double value) => (value / 375) * referenceWidth;
        double clampValue(double value, double min, double max) =>
            value.clamp(min, max);

        final double spacing = clampValue(isTablet ? 28 : 20, 16, 36);
        final double cardSpacing = clampValue(isTablet ? 24 : 18, 12, 28);
        final double paddingHorizontal = clampValue(isTablet ? 32 : 20, 16, 40);
        final double mobileMaxWidth = clampValue(width * 0.92, 320, 520);
        final double mobileMinWidth =
            clampValue(mobileMaxWidth * 0.9, 280, mobileMaxWidth);
        final double tabletCardMax = clampValue(width * 0.45, 450, 550);
        final double tabletCardMin =
            clampValue(tabletCardMax * 0.92, 420, tabletCardMax);

        Widget wrapCard(Widget child, {double? minHeight}) {
          final double maxWidth = isTablet ? tabletCardMax : mobileMaxWidth;
          final double minWidth = isTablet ? tabletCardMin : mobileMinWidth;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight ?? 0,
              ),
              child: child,
            ),
          );
        }

        Widget wrapFullWidth(Widget child) {
          return Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 1200 : mobileMaxWidth + 32,
              ),
              child: child,
            ),
          );
        }

        Widget adaptiveCard(
          Widget child, {
          double? minHeight,
          bool forceFullWidth = false,
        }) {
          final constrained = ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight ?? 0),
            child: child,
          );
          if (isTablet) {
            return forceFullWidth ? wrapFullWidth(constrained) : constrained;
          }
          return wrapCard(constrained, minHeight: minHeight);
        }

        Widget buildYearSelectorCard() {
          final List<int> years = [2025, 2026, 2027, 2028, 2029, 2030];
          final double pillHeight = clampValue(ph(isTablet ? 52 : 44), 36, 62);
          final double pillVertical = clampValue(ph(isTablet ? 11 : 8), 8, 16);
          // Mais espaço lateral nos chips de ano
          final double pillHorizontal =
              clampValue(pw(isTablet ? 70 : 60), 26, 56);
          final BorderRadius pillRadius = BorderRadius.circular(pr(999));

          return Padding(
            padding: EdgeInsets.symmetric(vertical: cardSpacing * 0.2),
            child: SizedBox(
              height: pillHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: years.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: clampValue(cardSpacing * 0.6, 8, 20)),
                itemBuilder: (context, index) {
                  final int year = years[index];
                  final bool selected = _selectedYear == year;
                  return InkWell(
                    onTap: () => setState(() => _selectedYear = year),
                    borderRadius: pillRadius,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: pillVertical,
                        horizontal: pillHorizontal,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? theme.cardColor : Colors.transparent,
                        borderRadius: pillRadius,
                        border: Border.all(
                          color: selected
                              ? DefaultColors.greenDark
                              : theme.primaryColor.withOpacity(.25),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: selected
                                ? DefaultColors.greenDark
                                : theme.primaryColor,
                            fontSize: pf(isTablet ? 15 : 12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        Widget buildMonthlySummaryCard() {
          final double descriptionFont =
              clampValue(pf(isTablet ? 14 : 12), 11, 15);
          final double chevronSize = clampValue(pf(isTablet ? 18 : 16), 14, 20);
          final double leadingIconSize =
              clampValue(pf(isTablet ? 22 : 20), 16, 24);
          final double leadingIconSpacing =
              clampValue(pw(isTablet ? 10 : 8), 6, 12).toDouble();
          final double leadingIconBox =
              clampValue(pf(isTablet ? 36 : 32), 26, 42);
          final double leadingIconPadding =
              clampValue(pf(isTablet ? 9 : 8), 6, 12);
          final Color leadingIconBg =
              theme.primaryColor.withOpacity(isTablet ? 0.10 : 0.12);

          return InfoCard(
            title: 'Resumo Mensal',
            onTap: () => Get.to(() => MonthlySummaryPage(
                  initialMonth: _selectedMonth,
                  initialYear: _selectedYear,
                )),
            content: Row(
              children: [
                Container(
                  width: leadingIconBox,
                  height: leadingIconBox,
                  decoration: BoxDecoration(
                    color: leadingIconBg,
                    borderRadius: BorderRadius.circular(pr(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bar_chart_outlined,
                      color: theme.primaryColor,
                      size: leadingIconSize,
                    ),
                  ),
                ),
                SizedBox(width: leadingIconSpacing),
                Expanded(
                  child: Text(
                    'Veja receitas, despesas, parcelas e gráficos do mês',
                    style: TextStyle(
                      fontSize: descriptionFont,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.primaryColor,
                  size: chevronSize,
                ),
              ],
            ),
          );
        }

        Widget buildAdsCard() {
          return Container(
            padding: EdgeInsets.all(cardSpacing * 0.5),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(pr(18)),
              border: Border.all(color: theme.primaryColor.withOpacity(0.05)),
            ),
            child: const AdsBanner(),
          );
        }

        Widget buildEmptyStateCard() {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: clampValue(height * 0.08, 48, 120),
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(pr(20)),
              border: Border.all(color: theme.primaryColor.withOpacity(0.05)),
            ),
            child: const Center(child: DefaultTextNotTransaction()),
          );
        }

        Widget buildDistributionEntry({
          required String label,
          required double value,
          required double percent,
          required Color color,
          String? iconPath,
          VoidCallback? onTap,
          double? leadingSize,
          double? leadingPadding,
        }) {
          final double avatarSize =
              (leadingSize ?? clampValue(pw(isTablet ? 32 : 26), 22, 40))
                  .toDouble();
          final double iconPadding =
              (leadingPadding ?? clampValue(pw(isTablet ? 6 : 5), 3, 8))
                  .toDouble();
          final Widget leading = Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(pr(12)),
            ),
            child: iconPath != null && iconPath.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(iconPadding),
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    Iconsax.category,
                    color: color,
                    size: pf(16),
                  ),
          );

          final content = Row(
            children: [
              leading,
              SizedBox(width: clampValue(pw(12), 8, 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: pf(isTablet ? 15 : 14),
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: clampValue(pw(8), 6, 16)),
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                            decimalDigits: 2,
                          ).format(value),
                          style: TextStyle(
                            fontSize: pf(isTablet ? 15 : 14),
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                    SizedBox(height: clampValue(ph(4), 3, 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: pf(12),
                            color: DefaultColors.grey,
                          ),
                        ),
                        SizedBox(width: clampValue(pw(6), 4, 12)),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: pf(12),
                          color: DefaultColors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final child = Padding(
            padding: EdgeInsets.symmetric(
              vertical: clampValue(ph(6), 4, 12),
            ),
            child: onTap == null
                ? content
                : InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(pr(12)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: clampValue(ph(4), 2, 6),
                      ),
                      child: content,
                    ),
                  ),
          );

          if (onTap == null) return child;
          return Material(
            color: Colors.transparent,
            child: child,
          );
        }

        InfoCard buildCategoryCard({
          required List<Map<String, dynamic>> data,
          required double totalValue,
          required double chartHeight,
        }) {
          return InfoCard(
            title: 'Por categoria',
            onTap: null,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: chartHeight,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        legend: Legend(isVisible: false),
                        series: <CircularSeries<Map<String, dynamic>, String>>[
                          PieSeries<Map<String, dynamic>, String>(
                            dataSource: data,
                            xValueMapper: (e, _) =>
                                (e['name'] ?? '').toString(),
                            yValueMapper: (e, _) => (e['value'] as double),
                            pointColorMapper: (e, _) =>
                                (e['color'] as Color?) ??
                                Colors.grey.withOpacity(0.5),
                            dataLabelMapper: (e, _) {
                              final v = (e['value'] as double);
                              final pct =
                                  totalValue > 0 ? (v / totalValue) * 100 : 0;
                              return '${(e['name'] ?? '').toString()}\n${pct.toStringAsFixed(0)}%';
                            },
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                            explode: true,
                            explodeIndex: data.isEmpty ? null : 0,
                            explodeOffset: '8%',
                            sortingOrder: SortingOrder.descending,
                            sortFieldValueMapper: (e, _) =>
                                (e['value'] as double),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: cardSpacing * 0.6),
                for (final item in data)
                  () {
                    final double itemValue = (item['value'] as double);
                    final double percent =
                        totalValue > 0 ? (itemValue / totalValue) * 100 : 0;
                    final Color categoryColor =
                        (item['color'] as Color?) ?? theme.primaryColor;
                    final String? iconPath = item['icon'] as String?;

                    return buildDistributionEntry(
                      label: (item['name'] ?? 'Categoria').toString(),
                      value: itemValue,
                      percent: percent,
                      color: categoryColor,
                      iconPath: iconPath,
                      // Categoria: levemente maior (container/foto)
                      leadingSize:
                          clampValue(pw(isTablet ? 40 : 34), 26, 52).toDouble(),
                      leadingPadding:
                          clampValue(pw(isTablet ? 8 : 6), 4, 10).toDouble(),
                      onTap: item['category'] is int
                          ? () {
                              final int categoryId = item['category'] as int;
                              final String categoryName =
                                  (item['name'] ?? 'Categoria').toString();
                              final String monthName =
                                  _monthsPt[_selectedMonth - 1];

                              Get.to(
                                () => CategoryAnalysisPage(
                                  categoryId: categoryId,
                                  categoryName: categoryName,
                                  categoryColor: categoryColor,
                                  monthName: monthName,
                                  totalValue: itemValue,
                                  percentual: percent,
                                ),
                              );
                            }
                          : null,
                    );
                  }(),
              ],
            ),
          );
        }

        InfoCard buildPaymentCard({
          required List<Map<String, dynamic>> data,
          required double total,
          required double chartHeight,
        }) {
          return InfoCard(
            title: 'Por tipo de pagamento',
            onTap: null,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: chartHeight,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        legend: Legend(isVisible: false),
                        series: <CircularSeries<Map<String, dynamic>, String>>[
                          PieSeries<Map<String, dynamic>, String>(
                            dataSource: data,
                            xValueMapper: (e, _) =>
                                (e['paymentType'] as String),
                            yValueMapper: (e, _) => (e['value'] as double),
                            pointColorMapper: (e, _) => (e['color'] as Color),
                            dataLabelMapper: (e, _) {
                              final v = (e['value'] as double);
                              final pct = total > 0 ? (v / total) * 100 : 0;
                              return '${(e['paymentType'] as String)}\n${pct.toStringAsFixed(0)}%';
                            },
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                            explode: true,
                            explodeIndex: data.isEmpty ? null : 0,
                            explodeOffset: '8%',
                            sortingOrder: SortingOrder.descending,
                            sortFieldValueMapper: (e, _) =>
                                (e['value'] as double),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: cardSpacing * 0.5),
                for (final item in data)
                  buildDistributionEntry(
                    label: item['paymentType'] as String,
                    value: item['value'] as double,
                    percent: total > 0
                        ? ((item['value'] as double) / total) * 100
                        : 0,
                    color: item['color'] as Color,
                    iconPath: null,
                    // Bolha de cor menor para tipos de pagamento
                    leadingSize:
                        clampValue(pw(isTablet ? 22 : 18), 14, 30).toDouble(),
                    leadingPadding:
                        clampValue(pw(isTablet ? 5 : 4), 2, 6).toDouble(),
                    onTap: () {
                      Get.to(
                        () => PaymentTypeAnalysisPage(
                          paymentType: item['paymentType'] as String,
                          paymentColor: item['color'] as Color,
                          totalValue: item['value'] as double,
                          percentual: total > 0
                              ? ((item['value'] as double) / total) * 100
                              : 0,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }

        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Análise Anual',
                style: TextStyle(
                  fontSize: pf(16),
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
            drawer: const CustomDrawer(),
            body: SafeArea(
              child: Obx(() {
                final yearTransactions =
                    _filterYear(controller.transaction, _selectedYear);

                if (yearTransactions.isEmpty) {
                  final yearSelector = wrapFullWidth(buildYearSelectorCard());
                  final emptyState = wrapCard(buildEmptyStateCard());
                  final ads = wrapCard(buildAdsCard());

                  if (isTablet) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: spacing,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              yearSelector,
                              SizedBox(height: spacing),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: emptyState),
                                  SizedBox(width: cardSpacing),
                                  Expanded(child: ads),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: spacing,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        yearSelector,
                        SizedBox(height: spacing),
                        emptyState,
                        SizedBox(height: cardSpacing),
                        ads,
                      ],
                    ),
                  );
                }

                final filteredTransactions = yearTransactions
                    .where((e) => e.type == TransactionType.despesa)
                    .toList();
                final categories = filteredTransactions
                    .map((e) => e.category)
                    .where((e) => e != null)
                    .cast<int>()
                    .toSet()
                    .toList();

                final Map<int, double> categoryTotals = {};
                for (final t in filteredTransactions) {
                  if (t.category != null) {
                    categoryTotals[t.category!] =
                        (categoryTotals[t.category!] ?? 0.0) +
                            _parseValue(t.value);
                  }
                }

                final categoryData = categories
                    .map(
                      (e) => {
                        'category': e,
                        'value': categoryTotals[e] ?? 0.0,
                        'name': findCategoryById(e)?['name'],
                        'color': findCategoryById(e)?['color'],
                        'icon': findCategoryById(e)?['icon'],
                      },
                    )
                    .toList()
                  ..sort((a, b) =>
                      (b['value'] as double).compareTo(a['value'] as double));

                final double totalValue = categoryData.fold(
                  0.0,
                  (sum, m) => sum + (m['value'] as double),
                );

                final double chartHeight =
                    clampValue(ph(isTablet ? 260 : 200), 190, 320);

                final Widget categoryCard = categoryData.isEmpty
                    ? buildEmptyStateCard()
                    : buildCategoryCard(
                        data: categoryData,
                        totalValue: totalValue,
                        chartHeight: chartHeight,
                      );

                final Map<String, double> paymentTypeTotals = {};
                final Map<String, String> paymentTypeDisplay = {};
                for (final t in filteredTransactions) {
                  final raw = t.paymentType?.trim();
                  if (raw == null || raw.isEmpty) continue;
                  final key = raw.toLowerCase();
                  paymentTypeTotals[key] =
                      (paymentTypeTotals[key] ?? 0.0) + _parseValue(t.value);
                  paymentTypeDisplay.putIfAbsent(key, () => raw);
                }

                final payData = paymentTypeTotals.entries.map((entry) {
                  final display = paymentTypeDisplay[entry.key] ?? entry.key;
                  return {
                    'paymentType': display,
                    'value': entry.value,
                    'color': _getPaymentTypeColor(display),
                  };
                }).toList()
                  ..sort((a, b) =>
                      (b['value'] as double).compareTo(a['value'] as double));

                final double payTotal = payData.fold<double>(
                  0.0,
                  (prev, e) => prev + (e['value'] as double),
                );

                Widget? paymentCard;
                if (payData.isNotEmpty && payTotal > 0) {
                  paymentCard = buildPaymentCard(
                    data: payData,
                    total: payTotal,
                    chartHeight: chartHeight,
                  );
                }

                final double pairedCardHeight =
                    clampValue(height * (isTablet ? 0.32 : 0.28), 260, 420);
                final double wideCardHeight =
                    clampValue(height * (isTablet ? 0.35 : 0.3), 240, 440);

                final Widget yearSection =
                    wrapFullWidth(buildYearSelectorCard());
                final Widget analysisCard = adaptiveCard(
                  FinancialSummaryCards(selectedYear: _selectedYear),
                  minHeight: pairedCardHeight,
                );
                final Widget receiptsVsExpenses = adaptiveCard(
                  MonthlyFinancialChart(selectedYear: _selectedYear),
                  minHeight: pairedCardHeight,
                );
                final Widget monthlySummaryTile = adaptiveCard(
                  buildMonthlySummaryCard(),
                  forceFullWidth: true,
                );
                final Widget annualBalance = adaptiveCard(
                  AnnualBalanceSplineChart(selectedYear: _selectedYear),
                  minHeight: wideCardHeight,
                );
                final Widget categorySection = adaptiveCard(
                  categoryCard,
                  minHeight: wideCardHeight,
                );
                final Widget? paymentSection = paymentCard != null
                    ? adaptiveCard(
                        paymentCard,
                        minHeight: wideCardHeight,
                      )
                    : null;
                final Widget adsSection = adaptiveCard(
                  buildAdsCard(),
                  forceFullWidth: true,
                );

                if (isTablet) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: paddingHorizontal,
                          vertical: spacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            yearSection,
                            SizedBox(height: spacing),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: analysisCard),
                                SizedBox(width: cardSpacing),
                                Expanded(child: receiptsVsExpenses),
                              ],
                            ),
                            SizedBox(height: spacing),
                            monthlySummaryTile,
                            SizedBox(height: spacing),
                            annualBalance,
                            SizedBox(height: spacing),
                            if (paymentSection != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: categorySection),
                                  SizedBox(width: cardSpacing),
                                  Expanded(child: paymentSection),
                                ],
                              )
                            else
                              categorySection,
                            SizedBox(height: spacing),
                            adsSection,
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: spacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      yearSection,
                      SizedBox(height: spacing),
                      analysisCard,
                      SizedBox(height: cardSpacing),
                      receiptsVsExpenses,
                      SizedBox(height: cardSpacing),
                      monthlySummaryTile,
                      SizedBox(height: cardSpacing),
                      annualBalance,
                      SizedBox(height: cardSpacing),
                      categorySection,
                      if (paymentSection != null) ...[
                        SizedBox(height: cardSpacing),
                        paymentSection,
                      ],
                      SizedBox(height: cardSpacing),
                      // adsSection,
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
