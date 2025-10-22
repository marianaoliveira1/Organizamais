// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/auth_controller.dart';

import 'package:organizamais/controller/transaction_controller.dart';
// import 'package:organizamais/pages/graphics/widgtes/despesas_por_tipo_de_pagamento.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../ads_banner/ads_banner.dart';

import '../initial/widget/custom_drawer.dart';
import 'widgtes/finance_pie_chart.dart';
import 'widgtes/widget_list_category_graphics.dart';
import 'pages/select_categories_page.dart';
import 'pages/category_report_page.dart';
import 'pages/weekly_report_page.dart';
import 'pages/spending_shift_balance_page.dart';
import 'pages/category_type_selection_page.dart';
import '../resume/widgtes/text_not_transaction.dart';
import '../../widgetes/info_card.dart';

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

List<String> _buildMonthYearOptions() {
  final now = DateTime.now();
  final int currentYear = now.year;
  final int nextYear = now.year + 1;
  final months = getAllMonths();
  final List<String> result = [];
  for (final m in months) {
    result.add('$m/$currentYear');
  }
  for (final m in months) {
    result.add('$m/$nextYear');
  }
  return result;
}

// ({int month, int year}) _parseSelectedMonthYear(String selected) {
//   if (selected.isEmpty) {
//     final now = DateTime.now();
//     return (month: now.month, year: now.year);
//   }
//   final parts = selected.split('/');
//   if (parts.length == 2) {
//     final name = parts[0];
//     final year = int.tryParse(parts[1]) ?? DateTime.now().year;
//     final idx = getAllMonths().indexOf(name);
//     final month = idx >= 0 ? idx + 1 : DateTime.now().month;
//     return (month: month, year: year);
//   }
//   final idx = getAllMonths().indexOf(selected);
//   return (
//     month: (idx >= 0 ? idx + 1 : DateTime.now().month),
//     year: DateTime.now().year
//   );
// }

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _monthScrollController;
  final Map<int, GlobalKey> _monthItemKeys = {}; // keys para centralizar
  String selectedMonth =
      '${getAllMonths()[DateTime.now().month - 1]}/${DateTime.now().year}';
  // Controller obtido uma vez (evita Get.put no build)
  final TransactionController _transactionController =
      Get.isRegistered<TransactionController>()
          ? Get.find<TransactionController>()
          : Get.put(TransactionController());
  Worker? _cacheWorker;
  // Caches simples por mês para reduzir recomputações pesadas em build
  final Map<String, List<TransactionModel>> _cacheFilteredDespesasByMonth = {};
  final Map<String, Map<String, dynamic>> _cacheSparklineByMonth = {};
  final Map<String, List<double>> _cacheWeeklyTotalsByMonth = {};
  Set<int> _selectedCategoryIds = {};
  String?
      _expandedPaymentType; // expande detalhes do tipo de pagamento no gráfico
  // final Set<int> _essentialCategoryIds = const {}; // deprecado
  // Mapa para armazenar seleção de essenciais por mês (chave YYYY-MM)
  // final Map<String, Set<int>> _monthEssentialCategoryIds = {};
  bool _showWeekly = false;
  final bool _showBarCategoryChart = false;
  // Flags para animação de entrada única
  static bool _didEntranceAnimateOnce = false;
  bool _shouldPlayEntrance = false;
  int _classificationVersion = 0; // força rebuild do gráfico de classificações
  Map<int, String> _classificationOverrides = {};
  Map<String, String> _classificationOverridesByName = {};

  Future<void> _reloadClassificationOverrides() async {
    try {
      final user = Get.find<AuthController>().firebaseUser.value;
      Map<int, String> map = {};
      Map<String, String> byName = {};
      if (user != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('categoryClassifications')
            .get();
        for (final d in snap.docs) {
          final doc = d.data();
          final int id =
              int.tryParse(d.id) ?? (doc['categoryId'] as int? ?? -1);
          final String group = (doc['group'] as String? ?? '').toLowerCase();
          if (id >= 0 &&
              (group == 'fixas' || group == 'variaveis' || group == 'extras')) {
            map[id] = group;
            final info = findCategoryById(id);
            final String? name = (info != null ? info['name'] as String? : null)
                ?.trim()
                .toLowerCase();
            if (name != null && name.isNotEmpty) byName[name] = group;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _classificationOverrides = map;
        _classificationOverridesByName = byName;
        _classificationVersion++;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _classificationVersion++;
      });
    }
  }

  bool _entranceVisible = false;
  int _scrollRetries = 0;
  bool _didIntroScroll = false;

  @override
  void initState() {
    super.initState();
    _monthScrollController = ScrollController();
    // Precarrega overrides ao abrir a página (se usuário logado)
    _reloadClassificationOverrides();
    // Preload an interstitial ad early to improve show rate
    try {
      AdsInterstitial.preload();
    } catch (_) {}
    // Limpa caches quando as transações mudarem
    _cacheWorker = ever<List<TransactionModel>>(
      _transactionController.transactionRx,
      (_) => _invalidateCaches(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playIntroMonthScroll();
    });

    if (!_didEntranceAnimateOnce) {
      _shouldPlayEntrance = true;
      _entranceVisible = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _entranceVisible = true;
          _didEntranceAnimateOnce = true;
        });
      });
    } else {
      _shouldPlayEntrance = false;
      _entranceVisible = true;
    }
  }

  void _scrollToCurrentMonth() {
    final options = _buildMonthYearOptions();
    final currentLabel =
        '${getAllMonths()[DateTime.now().month - 1]}/${DateTime.now().year}';
    final int currentMonthIndex =
        options.indexOf(currentLabel).clamp(0, options.length - 1);
    // Tente usar ensureVisible se tivermos a key do item
    final key = _monthItemKeys[currentMonthIndex];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    // Fallback baseado em offset estimado
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset =
        currentMonthIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    if (!_monthScrollController.hasClients ||
        (_monthScrollController.position.hasContentDimensions == false) ||
        _monthScrollController.position.maxScrollExtent == 0) {
      if (_scrollRetries < 4) {
        _scrollRetries += 1;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToCurrentMonth());
      }
      return;
    }
    final double maxScroll = _monthScrollController.position.maxScrollExtent;
    final double scrollPosition = offset.clamp(0.0, maxScroll);
    _monthScrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _playIntroMonthScroll() async {
    final options = _buildMonthYearOptions();
    final currentLabel =
        '${getAllMonths()[DateTime.now().month - 1]}/${DateTime.now().year}';
    final int targetIndex =
        options.indexOf(currentLabel).clamp(0, options.length - 1);
    if (_didIntroScroll) {
      _scrollToCurrentMonth();
      return;
    }
    if (!_monthScrollController.hasClients) {
      if (_scrollRetries < 8) {
        _scrollRetries += 1;
        await Future.delayed(const Duration(milliseconds: 60));
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _playIntroMonthScroll());
      }
      return;
    }
    _didIntroScroll = true;
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    try {
      _monthScrollController.jumpTo(0);
    } catch (_) {}
    for (int i = 0; i <= targetIndex; i++) {
      final key = _monthItemKeys[i];
      if (key != null && key.currentContext != null) {
        await Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        );
        continue;
      }
      final double offset = i * itemWidth - (screenWidth / 2) + (itemWidth / 2);
      final double maxScroll = _monthScrollController.position.maxScrollExtent;
      final double scrollPosition = offset.clamp(0.0, maxScroll);
      await _monthScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    _cacheWorker?.dispose();
    super.dispose();
  }

  void _invalidateCaches() {
    _cacheFilteredDespesasByMonth.clear();
    _cacheSparklineByMonth.clear();
    _cacheWeeklyTotalsByMonth.clear();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final TransactionController transactionController = _transactionController;

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
      appBar: AppBar(
        title: Text(
          'Gráficos',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
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
                      // Lista de meses/ano
                      SizedBox(
                        height: 30.h,
                        child: ListView.separated(
                          controller: _monthScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: _buildMonthYearOptions().length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final month = _buildMonthYearOptions()[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMonth = month;
                                });
                                selectedCategoryId.value = null;
                              },
                              child: Container(
                                key: _monthItemKeys.putIfAbsent(
                                    index, () => GlobalKey()),
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
                        if (transactionController.transaction.isEmpty) {
                          final vh = MediaQuery.of(context).size.height;
                          return SizedBox(
                            height: vh * 0.7,
                            child: const Center(
                              child: DefaultTextNotTransaction(),
                            ),
                          );
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
        // Line Chart - Despesas diárias (fade-in uma única vez por execução)
        _entranceWrap(
          _buildLineChart(
              theme, transactionController, currencyFormatter, dayFormatter),
        ),
        AdsBanner(),
        SizedBox(height: 20.h),
        // Pie Chart - Despesas por categoria (InfoCard)
        InfoCard(
          title: 'Despesas por categoria',
          icon: Iconsax.category,
          onTap: null,
          onIconTap: () async {
            // Abre seletor com os mesmos dados do gráfico
            final filteredTransactions =
                getFilteredTransactions(transactionController);
            final categories = filteredTransactions
                .map((e) => e.category)
                .where((e) => e != null)
                .toSet()
                .toList()
                .cast<int>();
            final data = categories
                .map((e) => {
                      "category": e,
                      "value": filteredTransactions
                          .where((element) => element.category == e)
                          .fold<double>(
                            0.0,
                            (prev, element) =>
                                prev +
                                double.parse(element.value
                                    .replaceAll('.', '')
                                    .replaceAll(',', '.')),
                          ),
                      "name": findCategoryById(e)?['name'],
                      "color": findCategoryById(e)?['color'],
                      "icon": findCategoryById(e)?['icon'],
                    })
                .toList();

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
          backgroundColor: theme.cardColor,
          content: _entranceWrap(
            _buildCategoryChart(
              theme,
              transactionController,
              selectedCategoryId,
              currencyFormatter,
              dateFormatter,
            ),
          ),
        ),

        SizedBox(height: 16.h),
        // Fixas x Variáveis x Extras (InfoCard)
        InfoCard(
          title: 'Fixas x Variáveis x Extras',
          icon: Iconsax.category,
          onTap: () async {
            await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                  builder: (_) => const CategoryTypeSelectionPage()),
            );
            if (!mounted) return;
            await _reloadClassificationOverrides();
          },
          onIconTap: () async {
            await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                  builder: (_) => const CategoryTypeSelectionPage()),
            );
            if (!mounted) return;
            await _reloadClassificationOverrides();
          },
          backgroundColor: theme.cardColor,
          content: _entranceWrap(
            KeyedSubtree(
              key: ValueKey(_classificationVersion),
              child: _buildEssentialsVsNonEssentialsChart(
                theme,
                transactionController,
                currencyFormatter,
                overrides: _classificationOverrides,
                overridesByName: _classificationOverridesByName,
                fromStream: true,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        AdsBanner(),
        SizedBox(height: 20.h),

        // Balanço de troca de gastos (InfoCard)
        InfoCard(
          title: 'Balanço de Gastos por Categoria',
          onTap: () async {
            try {
              await AdsInterstitial.preload();
              final shown = await AdsInterstitial.showIfReady();
              if (!shown) {
                await AdsInterstitial.show();
              }
            } catch (_) {}
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SpendingShiftBalancePage(
                  selectedMonth: selectedMonth,
                ),
              ),
            );
          },
          backgroundColor: theme.cardColor,
          content: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.wallet,
                    color: theme.primaryColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Acompanhe em detalhes cada categoria em que você utilizou seu dinheiro ao longo do mês.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Relatório Mensal (InfoCard)
        InfoCard(
          title: 'Relatório Mensal',
          onTap: () async {
            try {
              await AdsInterstitial.preload();
              final shown = await AdsInterstitial.showIfReady();
              if (!shown) {
                await AdsInterstitial.show();
              }
            } catch (_) {}
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryReportPage(
                  selectedMonth: selectedMonth,
                ),
              ),
            );
          },
          backgroundColor: theme.cardColor,
          content: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child:
                    Icon(Iconsax.chart, color: theme.primaryColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Veja a diferença de valores entre este mês e o anterior, categoria por categoria",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        AdsBanner(),
        SizedBox(height: 20.h),
        // Relatório Semanal (InfoCard)
        InfoCard(
          title: 'Relatório Semanal',
          onTap: () async {
            try {
              await AdsInterstitial.preload();
              final shown = await AdsInterstitial.showIfReady();
              if (!shown) {
                await AdsInterstitial.show();
              }
            } catch (_) {}
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WeeklyReportPage(selectedMonth: selectedMonth),
              ),
            );
          },
          backgroundColor: theme.cardColor,
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
                  "Veja receitas, despesas e saldo por semana, com pizza de gastos",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        // Por tipo de pagamento (InfoCard)
        AdsBanner(),
        SizedBox(
          height: 20.h,
        ),
        InfoCard(
          title: 'Por tipo de pagamento',
          onTap: () {},
          backgroundColor: theme.cardColor,
          content: _entranceWrap(
            _buildPaymentTypePieSection(
              theme,
              transactionController,
              currencyFormatter,
              dateFormatter,
            ),
          ),
        ),
        SizedBox(height: 20.h),

        AdsBanner(),
        SizedBox(height: 20.h),

        // Receita x Despesa (%) (InfoCard)
        InfoCard(
          title: 'Receita x Despesa (%)',
          onTap: () {},
          backgroundColor: theme.cardColor,
          content: _entranceWrap(
            GraficoPorcengtagemReceitaEDespesa(selectedMonth: selectedMonth),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildEssentialsVsNonEssentialsChart(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter,
      {Map<int, String> overrides = const {},
      Map<String, String> overridesByName = const {},
      bool fromStream = false}) {
    // Carrega classificações do Firestore e reconstrói reativamente
    if (!fromStream) {
      final user = Get.find<AuthController>().firebaseUser.value;
      if (user != null) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('categoryClassifications')
              .snapshots(),
          builder: (context, snapshot) {
            final Map<int, String> map = {};
            final Map<String, String> byName = {};
            if (snapshot.hasData) {
              for (final d in snapshot.data!.docs) {
                final doc = d.data();
                final int id =
                    int.tryParse(d.id) ?? (doc['categoryId'] as int? ?? -1);
                final String group =
                    (doc['group'] as String? ?? '').toLowerCase();
                if (id >= 0 &&
                    (group == 'fixas' ||
                        group == 'variaveis' ||
                        group == 'extras')) {
                  map[id] = group;
                  final info = findCategoryById(id);
                  final String? name =
                      (info != null ? info['name'] as String? : null)
                          ?.trim()
                          .toLowerCase();
                  if (name != null && name.isNotEmpty) byName[name] = group;
                }
              }
            }
            return _buildEssentialsVsNonEssentialsChart(
              theme,
              transactionController,
              currencyFormatter,
              overrides: map,
              overridesByName: byName,
              fromStream: true,
            );
          },
        );
      }
    }
    final filteredTransactions = getFilteredTransactions(transactionController);

    double fixedTotal = 0.0;
    double variableTotal = 0.0;
    double extraTotal = 0.0;

    final Set<String> usedFixedCategoryNames = {};
    final Set<String> usedVariableCategoryNames = {};
    final Set<String> usedExtraCategoryNames = {};

    String normalize(String s) => s.trim().toLowerCase();

    String classify(String? name) {
      if (name == null) return 'variaveis';
      final n = normalize(name);

      // Fixas
      const fixedKeywords = [
        'moradia',
        'contas (água, luz, gás, internet)',
        'condomínio',
        'plano de saúde/seguro de vida',
        'seguro do carro',
        'ipva',
        'financiamento',
        'empréstimos',
        'taxas',
        'assinaturas e serviços',
        'educação',
      ];

      // Variáveis
      const variableKeywords = [
        'alimentação',
        'mercado',
        'restaurantes',
        'delivery',
        'lanches',
        'padaria',
        'transporte',
        'combustível',
        'transporte por aplicativo',
        'pedágio/estacionamento',
        'manutenção',
        'saúde',
        'salão',
        'barbearia',
        'cuidados pessoais',
        'academia',
        'livros',
        'revistas',
        'lazer',
        'hobbies',
        'cinema',
        'streaming',
        'jogos online',
        'passeios',
        'compras',
        'vestuário',
        'roupas',
        'acessórios',
        'eletrônicos',
        'presentes',
        'pets',
        'família e filhos',
        'aplicativos',
        'viagens',
        'hospedagem',
        'passagens',
        'alimentação em viagens',
      ];

      // Extras
      const extraKeywords = [
        'multas',
        'emergência',
        'doações',
        'caridade',
        'impostos',
        'outros',
        'trabalho',
      ];

      bool containsAny(String text, List<String> keys) {
        for (final k in keys) {
          if (text.contains(k)) return true;
        }
        return false;
      }

      if (containsAny(n, extraKeywords)) return 'extras';
      if (containsAny(n, fixedKeywords)) return 'fixas';
      if (containsAny(n, variableKeywords)) return 'variaveis';

      // Override via Firestore classification
      // String? override;
      // try {
      //   final user = Get.find<AuthController>().firebaseUser.value;
      //   if (user != null) {
      //     // Síncrono não é possível aqui; vamos ler snapshot acima
      //   }
      // } catch (_) {}
      // default fallback
      return 'variaveis';
    }

    // 'overrides' fornecido via StreamBuilder acima quando logado

    for (var t in filteredTransactions) {
      final double value =
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      final int? categoryId = t.category;
      final Map<String, dynamic>? category =
          categoryId != null ? findCategoryById(categoryId) : null;
      final String? categoryName =
          category != null ? category['name'] as String? : null;
      final String? normalizedName =
          categoryName != null ? categoryName.trim().toLowerCase() : null;
      final int? resolvedId = (category != null
              ? (category['id'] is int ? category['id'] as int : null)
              : null) ??
          categoryId;
      final group = overrides[resolvedId ?? -1] ??
          (normalizedName != null ? overridesByName[normalizedName] : null) ??
          classify(categoryName);
      if (group == 'fixas') {
        fixedTotal += value;
        if (categoryName != null) usedFixedCategoryNames.add(categoryName);
      } else if (group == 'extras') {
        extraTotal += value;
        if (categoryName != null) usedExtraCategoryNames.add(categoryName);
      } else {
        variableTotal += value;
        if (categoryName != null) usedVariableCategoryNames.add(categoryName);
      }
    }

    final double total = fixedTotal + variableTotal + extraTotal;
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
            "Sem dados para Fixas x Variáveis x Extras",
            style: TextStyle(
              color: DefaultColors.grey,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    }

    final double fixedPct = (fixedTotal / total) * 100.0;
    final double variablePct = (variableTotal / total) * 100.0;
    final double extraPct = (extraTotal / total) * 100.0;

    final List<String> fixedNames = usedFixedCategoryNames.toList()..sort();
    final List<String> variableNames = usedVariableCategoryNames.toList()
      ..sort();
    final List<String> extraNames = usedExtraCategoryNames.toList()..sort();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          RepaintBoundary(
            child: SizedBox(
              height: 180.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfCircularChart(
                    margin: EdgeInsets.zero,
                    legend: Legend(isVisible: false),
                    series: <CircularSeries<Map<String, dynamic>, String>>[
                      PieSeries<Map<String, dynamic>, String>(
                        dataSource: [
                          {
                            'name': 'Fixas',
                            'value': fixedTotal,
                            'color': DefaultColors.darkBlue,
                          },
                          {
                            'name': 'Variáveis',
                            'value': variableTotal,
                            'color': DefaultColors.orangeDark,
                          },
                          {
                            'name': 'Extras',
                            'value': extraTotal,
                            'color': DefaultColors.plum,
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
                          final double pct = total > 0 ? (v / total) * 100 : 0;
                          return '${(e['name'] as String)}\n${pct.toStringAsFixed(0)}%';
                        },
                        // dataLabelSettings: DataLabelSettings(
                        //   isVisible: true,
                        //   labelPosition: ChartDataLabelPosition.inside,
                        //   textStyle: TextStyle(
                        //     fontSize: 10.sp,
                        //     color: Colors.white,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        explode: true,
                        explodeIndex: (fixedTotal >= variableTotal &&
                                fixedTotal >= extraTotal)
                            ? 0
                            : (variableTotal >= fixedTotal &&
                                    variableTotal >= extraTotal)
                                ? 1
                                : 2,
                        explodeOffset: '8%',
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFancyLegend(
                color: DefaultColors.darkBlue,
                label: 'Fixas',
                amount: currencyFormatter.format(fixedTotal),
                percent: fixedPct,
                theme: theme,
              ),
              if (fixedNames.isNotEmpty)
                _buildCategoryChips(fixedNames, theme, DefaultColors.darkBlue),
              SizedBox(height: 10.h),
              _buildFancyLegend(
                color: DefaultColors.orangeDark,
                label: 'Variáveis',
                amount: currencyFormatter.format(variableTotal),
                percent: variablePct,
                theme: theme,
              ),
              if (variableNames.isNotEmpty)
                _buildCategoryChips(
                    variableNames, theme, DefaultColors.orangeDark),
              SizedBox(height: 10.h),
              _buildFancyLegend(
                color: DefaultColors.plum,
                label: 'Extras',
                amount: currencyFormatter.format(extraTotal),
                percent: extraPct,
                theme: theme,
              ),
              if (extraNames.isNotEmpty)
                _buildCategoryChips(extraNames, theme, DefaultColors.plum),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> names, ThemeData theme, Color color) {
    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
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
    final parts = selectedMonth.split('/');
    final String monthName = parts.isNotEmpty ? parts[0] : selectedMonth;
    final int year = parts.length == 2
        ? int.tryParse(parts[1]) ?? DateTime.now().year
        : DateTime.now().year;

    final String cacheKey = '$monthName/$year';
    final cached = _cacheFilteredDespesasByMonth[cacheKey];
    if (cached != null) return cached;

    final despesas = transactionController.transaction
        .where((e) => e.type == TransactionType.despesa && e.paymentDay != null)
        .where((t) {
      final d = DateTime.parse(t.paymentDay!);
      return getAllMonths()[d.month - 1] == monthName && d.year == year;
    }).toList(growable: false);

    _cacheFilteredDespesasByMonth[cacheKey] = despesas;
    return despesas;
  }

  Map<String, dynamic> getSparklineData(
      TransactionController transactionController, DateFormat dayFormatter) {
    final String cacheKey = selectedMonth;
    final cached = _cacheSparklineByMonth[cacheKey];
    if (cached != null) return cached;

    var filteredTransactions = getFilteredTransactions(transactionController);

    final parts = selectedMonth.split('/');
    final String monthName = parts.isNotEmpty ? parts[0] : selectedMonth;
    final int selectedMonthIndex = getAllMonths().indexOf(monthName);
    final int selectedYear = parts.length == 2
        ? int.tryParse(parts[1]) ?? DateTime.now().year
        : DateTime.now().year;

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

    final result = {
      'data': sparklineData,
      'labels': labels,
      'dates': dates,
      'values': values,
    };
    _cacheSparklineByMonth[cacheKey] = result;
    return result;
  }

  Widget _buildLineChart(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter,
      DateFormat dayFormatter) {
    var sparklineData = getSparklineData(transactionController, dayFormatter);
    List<double> data = sparklineData['data'];
    final List<String> dayLabels =
        (sparklineData['labels'] as List<String>).toList();

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RepaintBoundary(
                  child: SizedBox(
                    height: 120.h,
                    child: SfCartesianChart(
                      margin: EdgeInsets.zero,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        labelPlacement: LabelPlacement.onTicks,
                        arrangeByIndex: true,
                        interval: 1,
                        majorGridLines: const MajorGridLines(width: 0),
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        labelIntersectAction: AxisLabelIntersectAction.hide,
                        axisLabelFormatter: (args) {
                          // Mostrar dias de 2 em 2: 1, 3, 5, ... e sempre o último dia
                          final String raw = args.text;
                          int day =
                              int.tryParse(raw) ?? (dayLabels.indexOf(raw) + 1);
                          final int lastDay = dayLabels.length;
                          final bool show =
                              (day > 0 && (day % 2 == 1)) || day == lastDay;
                          return ChartAxisLabel(
                            show ? day.toString() : '',
                            TextStyle(
                                fontSize: 6.sp, color: DefaultColors.grey),
                          );
                        },
                        labelStyle: TextStyle(
                            fontSize: 6.sp, color: DefaultColors.grey),
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: true,
                        minimum: 0,
                        maximum: data.isNotEmpty &&
                                data.reduce((a, b) => a > b ? a : b) > 0
                            ? data.reduce((a, b) => a > b ? a : b) * 1.2
                            : 100,
                        interval: ((data.isNotEmpty &&
                                    data.reduce((a, b) => a > b ? a : b) > 0
                                ? data.reduce((a, b) => a > b ? a : b) * 1.2
                                : 100) /
                            4),
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        labelStyle: TextStyle(
                            color: DefaultColors.grey, fontSize: 9.sp),
                        majorGridLines: MajorGridLines(
                          color: DefaultColors.grey.withOpacity(0.12),
                          width: 0.6,
                        ),
                        axisLabelFormatter: (args) {
                          final num v = args.value;
                          return ChartAxisLabel(
                            currencyFormatter.format(v),
                            TextStyle(
                                fontSize: 9.sp, color: DefaultColors.grey),
                          );
                        },
                      ),
                      series: <CartesianSeries<MapEntry<int, double>, String>>[
                        LineSeries<MapEntry<int, double>, String>(
                          dataSource: data.asMap().entries.toList(),
                          xValueMapper: (e, _) =>
                              (e.key >= 0 && e.key < dayLabels.length)
                                  ? dayLabels[e.key]
                                  : '',
                          yValueMapper: (e, _) => e.value,
                          color: DefaultColors.green,
                          width: 2,
                          markerSettings:
                              const MarkerSettings(isVisible: false),
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        canShowMarker: false,
                        header: '',
                        builder:
                            (data, point, series, pointIndex, seriesIndex) {
                          final num y = point.y ?? 0;
                          return Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: DefaultColors.green.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              currencyFormatter.format(y),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          if (_showWeekly)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180.h,
                  child: SfCartesianChart(
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(
                      labelPlacement: LabelPlacement.onTicks,
                      rangePadding: ChartRangePadding.none,
                      plotOffset: 12,
                      majorGridLines: MajorGridLines(
                        color: DefaultColors.grey.withOpacity(0.12),
                        width: 1,
                      ),
                      majorTickLines: const MajorTickLines(size: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle:
                          TextStyle(fontSize: 9.sp, color: DefaultColors.grey),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: (weeklyTotals.isNotEmpty
                                  ? weeklyTotals.reduce((a, b) => a > b ? a : b)
                                  : 0) >
                              0
                          ? weeklyTotals.reduce((a, b) => a > b ? a : b) * 1.3
                          : 100,
                      interval: ((weeklyTotals.isNotEmpty
                                  ? weeklyTotals
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.3
                                  : 100) /
                              6)
                          .clamp(1, double.infinity),
                      majorGridLines: MajorGridLines(
                          color: DefaultColors.grey.withOpacity(0.15),
                          width: 1),
                      majorTickLines: const MajorTickLines(size: 0),
                      axisLine: const AxisLine(width: 0),
                      axisLabelFormatter: (args) {
                        final num value = args.value;
                        final String label = currencyFormatter.format(value);
                        return ChartAxisLabel(
                          label,
                          TextStyle(fontSize: 9.sp, color: DefaultColors.grey),
                        );
                      },
                    ),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries<MapEntry<int, double>, String>>[
                      ColumnSeries<MapEntry<int, double>, String>(
                        dataSource: weeklyTotals.asMap().entries.toList(),
                        xValueMapper: (e, _) => weekRangeLabels[e.key],
                        yValueMapper: (e, _) => e.value,
                        color: DefaultColors.green,
                        borderRadius: BorderRadius.all(Radius.circular(4.r)),
                        width: 0.45,
                        spacing: 0.15,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: false),
                      )
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      canShowMarker: false,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final num y = point.y ?? 0;
                        return Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: DefaultColors.green.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            currencyFormatter.format(y),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      },
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
    final String cacheKey = selectedMonth;
    final cached = _cacheWeeklyTotalsByMonth[cacheKey];
    if (cached != null) return cached;

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
    _cacheWeeklyTotalsByMonth[cacheKey] = weeklyTotals;
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

  // Wrapper para animação de entrada única por execução
  Widget _entranceWrap(Widget child) {
    if (!_shouldPlayEntrance) return child;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      opacity: _entranceVisible ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutBack,
        scale: _entranceVisible ? 1.0 : 0.98,
        child: child,
      ),
    );
  }

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

    // Usaremos 'data' diretamente como fonte para o Syncfusion Pie

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // (removida a linha dinâmica de porcentagem para voltar ao estado anterior)
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
                child: RepaintBoundary(
                  child: SizedBox(
                    height: 180.h,
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      legend: Legend(isVisible: false),
                      series: <CircularSeries<Map<String, dynamic>, String>>[
                        PieSeries<Map<String, dynamic>, String>(
                          dataSource: data,
                          xValueMapper: (Map<String, dynamic> e, _) =>
                              (e['name'] as String),
                          yValueMapper: (Map<String, dynamic> e, _) =>
                              (e['value'] as double),
                          pointColorMapper: (Map<String, dynamic> e, _) =>
                              (e['color'] as Color),
                          dataLabelMapper: (Map<String, dynamic> e, _) {
                            final double v = (e['value'] as double);
                            final double pct =
                                totalValue > 0 ? (v / totalValue) * 100 : 0;
                            return '${(e['name'] as String)}\n${pct.toStringAsFixed(0)}%';
                          },
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: false),
                          explode: true,
                          explodeIndex: data.isEmpty ? null : 0,
                          explodeOffset: '8%',
                          sortingOrder: SortingOrder.descending,
                          sortFieldValueMapper: (Map<String, dynamic> e, _) =>
                              (e['value'] as double),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
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
              child: RepaintBoundary(
                child: SizedBox(
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
                              final String abbr = name.length <= 3
                                  ? name
                                  : name.substring(0, 3);
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
              ),
            ),
          // Carregar budgets do Firestore do usuário atual
          Obx(() {
            final user = Get.find<AuthController>().firebaseUser.value;
            if (user == null) {
              return WidgetListCategoryGraphics(
                data: data,
                totalValue: totalValue,
                selectedCategoryId: selectedCategoryId,
                theme: theme,
                currencyFormatter: currencyFormatter,
                dateFormatter: dateFormatter,
                monthName: selectedMonth,
              );
            }
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('categoryBudgets')
                  .snapshots(),
              builder: (context, snapshot) {
                final Map<int, double> budgets = {};
                if (snapshot.hasData) {
                  for (final d in snapshot.data!.docs) {
                    final docData = d.data();
                    final int id = int.tryParse(d.id) ??
                        (docData['categoryId'] as int?) ??
                        -1;
                    final double amount =
                        (docData['amount'] as num?)?.toDouble() ?? 0.0;
                    if (id >= 0) budgets[id] = amount;
                  }
                }
                // Incluir categorias com orçamento mesmo sem transações (valor 0)
                final List<Map<String, dynamic>> extendedData =
                    List<Map<String, dynamic>>.from(data);
                final Set<int> existingIds =
                    extendedData.map((e) => e['category'] as int).toSet();
                budgets.keys
                    .where((id) => !existingIds.contains(id))
                    .forEach((id) {
                  final info = findCategoryById(id);
                  extendedData.add({
                    'category': id,
                    'value': 0.0,
                    'name': info?['name'],
                    'color':
                        info?['color'] ?? theme.primaryColor.withOpacity(0.2),
                    'icon': info?['icon'],
                  });
                });
                return WidgetListCategoryGraphics(
                  data: extendedData,
                  totalValue: totalValue,
                  selectedCategoryId: selectedCategoryId,
                  theme: theme,
                  currencyFormatter: currencyFormatter,
                  dateFormatter: dateFormatter,
                  monthName: selectedMonth,
                  budgets: budgets,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentTypePieSection(
      ThemeData theme,
      TransactionController transactionController,
      NumberFormat currencyFormatter,
      DateFormat dateFormatter) {
    Color pickBaseColorFor(String paymentType) {
      String canonical = paymentType.trim().toLowerCase();
      canonical = canonical.replaceAll(RegExp(r'\s+'), ' ');
      Color distinctHslColor(String key) {
        int h = 0;
        for (final c in key.codeUnits) {
          h = (h * 131 + c) & 0x7fffffff;
        }
        double hue = (h % 360).toDouble();
        double sat = 0.72;
        double light = 0.54;
        final List<Color> reserved = [
          DefaultColors.deepPurple,
          DefaultColors.darkBlue,
          DefaultColors.orangeDark,
          DefaultColors.graphite,
          DefaultColors.brown,
          DefaultColors.blueGrey,
          DefaultColors.gold,
          DefaultColors.lime,
          DefaultColors.turquoise,
          DefaultColors.slateGrey,
          DefaultColors.hotPink,
        ];
        final List<double> reservedHues = reserved
            .map((c) => HSLColor.fromColor(c).hue)
            .toList(growable: false);
        double delta(double a, double b) {
          final d = (a - b).abs();
          return d > 180 ? 360 - d : d;
        }

        int attempts = 0;
        while (attempts < 36 && reservedHues.any((rh) => delta(hue, rh) < 12)) {
          hue = (hue + 17) % 360;
          attempts++;
        }
        // Verdes próximos ao PIX ficam mais claros para diferenciar
        if (hue >= 90 && hue <= 150) {
          sat = 0.55;
          light = 0.68;
        }
        return HSLColor.fromAHSL(1.0, hue, sat, light).toColor();
      }

      if (canonical.contains('cartão') || canonical.contains('cartao')) {
        // Regras específicas por nome de cartão (bancos principais)
        final n = canonical;
        if (n.contains('nubank')) return DefaultColors.deepPurple; // roxo
        if (n.contains('inter')) return DefaultColors.orangeDark; // laranja
        if (n.contains('santander')) return Colors.redAccent; // vermelho
        if (n.contains('bradesco')) return DefaultColors.hotPink; // rosa
        if (n.contains('banco do brasil') || n.contains('bb'))
          return Colors.amber; // amarelo
        if (n.contains('caixa')) return DefaultColors.darkBlue; // azul

        // Demais cartões: paleta pastel estável
        final cardPalette = <Color>[
          DefaultColors.pastelPurple,
          DefaultColors.pastelOrange,
          DefaultColors.pastelPink,
          DefaultColors.pastelTeal,
          DefaultColors.pastelCyan,
          DefaultColors.lavender,
          DefaultColors.peach,
          DefaultColors.mint,
          DefaultColors.salmon,
          DefaultColors.lightBlue,
        ];
        int h = 0;
        for (final c in paymentType.codeUnits) {
          h = (h * 131 + c) & 0x7fffffff;
        }
        return cardPalette[h % cardPalette.length];
      }
      // Normalizações e sinônimos
      if (canonical.contains('cartão') || canonical.contains('cartao')) {
        canonical = 'cartao';
      } else if (canonical.contains('crédito') ||
          canonical.contains('credito')) {
        canonical = 'credito';
      } else if (canonical.contains('débito') || canonical.contains('debito')) {
        canonical = 'debito';
      } else if (canonical.contains('transferência') ||
          canonical.contains('transferencia')) {
        canonical = 'transferencia';
      } else if (canonical.contains('vale refe')) {
        canonical = 'vale_refeicao';
      } else if (canonical == 'vr' || canonical == 'vale-refeicao') {
        canonical = 'vale_refeicao';
      } else if (canonical == 'ted' ||
          canonical.contains('transferência eletrônica')) {
        canonical = 'ted';
      }

      switch (canonical) {
        case 'cartao':
          return DefaultColors.deepPurple; // Cartão genérico
        case 'credito':
          return DefaultColors.deepPurple;
        case 'debito':
          return DefaultColors.darkBlue;
        case 'dinheiro':
          return DefaultColors.orangeDark;
        case 'pix':
          return DefaultColors.greenDark; // mantém verde forte só para PIX
        case 'boleto':
          return DefaultColors.brown;
        case 'transferencia':
          return DefaultColors.blueGrey;
        case 'cheque':
          return DefaultColors.gold;
        case 'vale':
          return DefaultColors.pastelLime;
        case 'vale_refeicao':
          return DefaultColors.pastelLime; // Vale Refeição mais claro
        case 'ted':
          return DefaultColors.turquoise; // TED (azul-esverdeado)
        case 'criptomoeda':
          return DefaultColors.slateGrey;
        case 'cupom':
          return DefaultColors.pastelPink;
        default:
          return distinctHslColor(canonical);
      }
    }

    final txs = getFilteredTransactions(transactionController)
        .where((e) => e.type == TransactionType.despesa)
        .toList();
    final Map<String, double> byType = {};
    for (final t in txs) {
      final key = (t.paymentType ?? 'Outros').trim();
      byType[key] = (byType[key] ?? 0) +
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
    }
    // Garante distinção de cores por rótulo atual
    final labels = byType.keys.toList();
    final Map<String, Color> baseColors = {
      for (final k in labels) k: pickBaseColorFor(k),
    };
    // Ajuste simples para distanciar matizes vizinhos
    final List<String> order = baseColors.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final Map<String, Color> distinctColors = {};
    final List<double> usedHues = [];
    double hueOf(Color c) => HSLColor.fromColor(c).hue;
    double satOf(Color c) => HSLColor.fromColor(c).saturation;
    double lightOf(Color c) => HSLColor.fromColor(c).lightness;
    double deltaHue(double a, double b) {
      final d = (a - b).abs();
      return d > 180 ? 360 - d : d;
    }

    for (final k in order) {
      final Color bc = baseColors[k]!;
      double h = hueOf(bc);
      final double s = satOf(bc);
      final double l = lightOf(bc);
      int attempts = 0;
      while (attempts < 36 && usedHues.any((u) => deltaHue(h, u) < 18)) {
        h = (h + 23) % 360;
        attempts++;
      }
      usedHues.add(h);
      distinctColors[k] = HSLColor.fromAHSL(1.0, h, s, l).toColor();
    }

    final data = byType.entries
        .map((e) => {
              'paymentType': e.key,
              'value': e.value,
              'color': distinctColors[e.key]!,
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    final double total = data.fold(0.0, (s, e) => s + (e['value'] as double));
    if (total <= 0) {
      return Center(
        child: Text(
          'Sem dados para exibir por tipo de pagamento',
          style: TextStyle(color: DefaultColors.grey, fontSize: 12.sp),
        ),
      );
    }

    final double maxVal =
        data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    final int explodeIndex =
        data.indexWhere((e) => (e['value'] as double) == maxVal);

    // Janela de comparação (mês selecionado vs mês anterior; mesmo dia se mês atual/futuro)
    final DateTime now = DateTime.now();
    int selMonth, selYear;
    final partsMY = selectedMonth.split('/');
    if (partsMY.length == 2) {
      selYear = int.tryParse(partsMY[1]) ?? now.year;
      selMonth = getAllMonths().indexOf(partsMY[0]) + 1;
      if (selMonth <= 0) selMonth = now.month;
    } else {
      selYear = now.year;
      selMonth = getAllMonths().indexOf(selectedMonth) + 1;
      if (selMonth <= 0) selMonth = now.month;
    }
    final bool isMonthClosed =
        (selYear < now.year) || (selYear == now.year && selMonth < now.month);
    final DateTime curStart = DateTime(selYear, selMonth, 1);
    final int daysInSel = DateTime(selYear, selMonth + 1, 0).day;
    final int curEndDay =
        isMonthClosed ? daysInSel : now.day.clamp(1, daysInSel);
    final DateTime curEnd = DateTime(selYear, selMonth, curEndDay, 23, 59, 59);
    final int prevMonth = selMonth == 1 ? 12 : selMonth - 1;
    final int prevYear = selMonth == 1 ? selYear - 1 : selYear;
    final DateTime prevStart = DateTime(prevYear, prevMonth, 1);
    final int daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
    final int prevEndDay =
        isMonthClosed ? daysInPrev : now.day.clamp(1, daysInPrev);
    final DateTime prevEnd =
        DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: RepaintBoundary(
            child: SizedBox(
              height: 180.h,
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
        ),
        SizedBox(height: 12.h),
        ...[
          for (final e in data) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  final name = (e['paymentType'] as String);
                  setState(() {
                    _expandedPaymentType =
                        _expandedPaymentType == name ? null : name;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                          color: (e['color'] as Color), shape: BoxShape.circle),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (e['paymentType'] as String),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            '${(total > 0 ? ((e['value'] as double) / total * 100) : 0).toStringAsFixed(0)}% das despesas',
                            style: TextStyle(
                                fontSize: 10.sp, color: DefaultColors.grey),
                          ),
                          Builder(builder: (context) {
                            final String name = (e['paymentType'] as String);
                            double currentValue = 0.0;
                            double previousValue = 0.0;
                            for (final t in transactionController.transaction) {
                              if (t.paymentDay == null ||
                                  t.type != TransactionType.despesa) {
                                continue;
                              }
                              final pt = t.paymentType;
                              if (pt == null) continue;
                              if (pt.trim().toLowerCase() !=
                                  name.trim().toLowerCase()) {
                                continue;
                              }
                              final d = DateTime.parse(t.paymentDay!);
                              final v = double.parse(t.value
                                  .replaceAll('.', '')
                                  .replaceAll(',', '.'));
                              if (d.isAfter(curStart
                                      .subtract(const Duration(seconds: 1))) &&
                                  d.isBefore(
                                      curEnd.add(const Duration(seconds: 1)))) {
                                currentValue += v;
                              }
                              if (d.isAfter(prevStart
                                      .subtract(const Duration(seconds: 1))) &&
                                  d.isBefore(prevEnd
                                      .add(const Duration(seconds: 1)))) {
                                previousValue += v;
                              }
                            }

                            double changePct;
                            IconData changeIcon;
                            Color changeColor;
                            if (previousValue == 0 && currentValue > 0) {
                              changePct = 100.0;
                              changeIcon = Iconsax.arrow_circle_up;
                              changeColor = DefaultColors.redDark;
                            } else if (previousValue > 0 && currentValue == 0) {
                              changePct = -100.0;
                              changeIcon = Iconsax.arrow_circle_down;
                              changeColor = DefaultColors.greenDark;
                            } else if (previousValue == 0 &&
                                currentValue == 0) {
                              changePct = 0.0;
                              changeIcon = Iconsax.more_circle;
                              changeColor = DefaultColors.grey;
                            } else {
                              final c = ((currentValue - previousValue) /
                                      previousValue) *
                                  100;
                              changePct = c;
                              if (c > 0) {
                                changeIcon = Iconsax.arrow_circle_up;
                                changeColor = DefaultColors.redDark;
                              } else if (c < 0) {
                                changeIcon = Iconsax.arrow_circle_down;
                                changeColor = DefaultColors.greenDark;
                              } else {
                                changeIcon = Iconsax.more_circle;
                                changeColor = DefaultColors.grey;
                              }
                            }

                            final String changeLabel = changePct > 0
                                ? '+${changePct.abs().toStringAsFixed(1)}%'
                                : changePct < 0
                                    ? '-${changePct.abs().toStringAsFixed(1)}%'
                                    : '0.0%';

                            return Row(
                              children: [
                                Icon(changeIcon,
                                    size: 12.sp, color: changeColor),
                                SizedBox(width: 4.w),
                                Text(
                                  changeLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: changeColor,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(e['value'] as double),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        Icon(
                          _expandedPaymentType == (e['paymentType'] as String)
                              ? Iconsax.arrow_up_24
                              : Iconsax.arrow_down_1,
                          color: theme.primaryColor,
                          size: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_expandedPaymentType == (e['paymentType'] as String))
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildPaymentTypeInlineDetails(
                  theme: theme,
                  paymentType: (e['paymentType'] as String),
                  transactionController: transactionController,
                  currencyFormatter: currencyFormatter,
                  dateFormatter: dateFormatter,
                ),
              ),
          ]
        ]
      ],
    );
  }

  Widget _buildPaymentTypeInlineDetails({
    required ThemeData theme,
    required String paymentType,
    required TransactionController transactionController,
    required NumberFormat currencyFormatter,
    required DateFormat dateFormatter,
  }) {
    final now = DateTime.now();
    // Parse mês/ano selecionado
    int selMonth, selYear;
    final parts = selectedMonth.split('/');
    if (parts.length == 2) {
      selYear = int.tryParse(parts[1]) ?? now.year;
      selMonth = getAllMonths().indexOf(parts[0]) + 1;
      if (selMonth <= 0) selMonth = now.month;
    } else {
      selYear = now.year;
      selMonth = getAllMonths().indexOf(selectedMonth) + 1;
      if (selMonth <= 0) selMonth = now.month;
    }

    final bool isMonthClosed =
        (selYear < now.year) || (selYear == now.year && selMonth < now.month);

    // Janelas de comparação
    final DateTime curStart = DateTime(selYear, selMonth, 1);
    final int daysInSel = DateTime(selYear, selMonth + 1, 0).day;
    final int curEndDay =
        isMonthClosed ? daysInSel : now.day.clamp(1, daysInSel);
    final DateTime curEnd = DateTime(selYear, selMonth, curEndDay, 23, 59, 59);

    final int prevMonth = selMonth == 1 ? 12 : selMonth - 1;
    final int prevYear = selMonth == 1 ? selYear - 1 : selYear;
    final DateTime prevStart = DateTime(prevYear, prevMonth, 1);
    final int daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
    final int prevEndDay =
        isMonthClosed ? daysInPrev : now.day.clamp(1, daysInPrev);
    final DateTime prevEnd =
        DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);

    double currentValue = 0.0;
    double previousValue = 0.0;
    final filtered = transactionController.transaction.where((t) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) {
        return false;
      }
      final pt = t.paymentType;
      if (pt == null) return false;
      return pt.trim().toLowerCase() == paymentType.trim().toLowerCase();
    });
    for (final t in filtered) {
      final d = DateTime.parse(t.paymentDay!);
      final v = double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      if (d.isAfter(curStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(curEnd.add(const Duration(seconds: 1)))) {
        currentValue += v;
      }
      if (d.isAfter(prevStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(prevEnd.add(const Duration(seconds: 1)))) {
        previousValue += v;
      }
    }

    // Texto de comparação
    Color sideColor;
    String text;
    String monthNamePt(int m) {
      const ms = [
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
      return ms[(m - 1).clamp(0, 11)];
    }

    if (currentValue == 0 && previousValue == 0) {
      sideColor = DefaultColors.grey;
      text =
          'Mesmo valor: ${currencyFormatter.format(currentValue)} (igual ao mês passado, ${currencyFormatter.format(previousValue)})';
    } else if (isMonthClosed) {
      final diff = (currentValue - previousValue).abs();
      final pct = previousValue == 0
          ? 100.0
          : ((currentValue - previousValue) / previousValue) * 100;
      final ml = monthNamePt(selMonth);
      if (currentValue > previousValue) {
        sideColor = DefaultColors.redDark;
        text =
            'No mês passado você gastou ${currencyFormatter.format(previousValue)} e agora em $ml ${currencyFormatter.format(currentValue)}; gasto maior de ${currencyFormatter.format(diff)} (+${pct.abs().toStringAsFixed(1)}%).';
      } else if (currentValue < previousValue) {
        sideColor = DefaultColors.greenDark;
        text =
            'No mês passado você gastou ${currencyFormatter.format(previousValue)} e agora em $ml ${currencyFormatter.format(currentValue)}; gasto menor de ${currencyFormatter.format(diff)} (-${pct.abs().toStringAsFixed(1)}%).';
      } else {
        sideColor = DefaultColors.grey;
        text =
            'Você gastou o mesmo valor em $ml que no mês anterior: ${currencyFormatter.format(currentValue)}';
      }
    } else {
      final diff = (currentValue - previousValue).abs();
      final pct = previousValue == 0
          ? 100.0
          : ((currentValue - previousValue) / previousValue) * 100;
      final sameDayLabel = '${prevEnd.day} de ${monthNamePt(prevEnd.month)}';
      if (currentValue > previousValue) {
        sideColor = DefaultColors.redDark;
        text =
            'No mesmo dia do mês passado ($sameDayLabel) você gastou ${currencyFormatter.format(previousValue)}, e agora gastou ${currencyFormatter.format(currentValue)}, o que aumentou ${pct.abs().toStringAsFixed(1)}% (${currencyFormatter.format(diff)}).';
      } else if (currentValue < previousValue) {
        sideColor = DefaultColors.greenDark;
        text =
            'No mesmo dia do mês passado ($sameDayLabel) você gastou ${currencyFormatter.format(previousValue)}, e agora gastou ${currencyFormatter.format(currentValue)}, o que diminuiu ${pct.abs().toStringAsFixed(1)}% (${currencyFormatter.format(diff)}).';
      } else {
        sideColor = DefaultColors.grey;
        text =
            'No mesmo dia do mês passado ($sameDayLabel) você gastou ${currencyFormatter.format(previousValue)}, e agora gastou o mesmo valor: ${currencyFormatter.format(currentValue)}.';
      }
    }

    // Transações recentes do método no mês selecionado
    final List<TransactionModel> monthTxs = transactionController.transaction
        .where((t) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) {
        return false;
      }
      final pt = t.paymentType;
      if (pt == null) return false;
      if (pt.trim().toLowerCase() != paymentType.trim().toLowerCase()) {
        return false;
      }
      final d = DateTime.parse(t.paymentDay!);
      return d.year == selYear && d.month == selMonth;
    }).toList()
      ..sort((a, b) => DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!)));

    // Receita total do mês selecionado (mês inteiro)
    final DateTime monthStart = DateTime(selYear, selMonth, 1);
    final DateTime monthEnd = DateTime(selYear, selMonth + 1, 0, 23, 59, 59);
    final double totalReceitasMes = transactionController.transaction
        .where((t) => t.type == TransactionType.receita && t.paymentDay != null)
        .where((t) {
      final d = DateTime.parse(t.paymentDay!);
      return d.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
          d.isBefore(monthEnd.add(const Duration(seconds: 1)));
    }).fold(
            0.0,
            (prev, t) =>
                prev +
                double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
    final double percReceita =
        totalReceitasMes > 0 ? (currentValue / totalReceitasMes * 100) : 0.0;
    // removed unused monthLabelTitle

    // Choose gradient colors based on sideColor (increase/red, decrease/green, neutral/grey)
    final List<Color> gradColors = sideColor == DefaultColors.redDark
        ? [DefaultColors.redDark, DefaultColors.red]
        : (sideColor == DefaultColors.greenDark
            ? [DefaultColors.greenDark, DefaultColors.green]
            : [DefaultColors.grey, DefaultColors.darkGrey]);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          AdsBanner(),
          SizedBox(height: 8.h),
          // Gradient header card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradColors,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Salary proportion card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: DefaultColors.grey20.withOpacity(.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Isso corresponde do seu salário mensal',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DefaultColors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${percReceita.toStringAsFixed(1).replaceAll('.', ',')}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          AdsBanner(),
          SizedBox(height: 8.h),
          Text('Transações recentes (${monthTxs.length})',
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: DefaultColors.grey20)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthTxs.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: DefaultColors.grey20.withOpacity(.5)),
            itemBuilder: (_, i) {
              final t = monthTxs[i];
              final v = double.parse(
                  t.value.replaceAll('.', '').replaceAll(',', '.'));
              final date = t.paymentDay != null
                  ? dateFormatter.format(DateTime.parse(t.paymentDay!))
                  : '';
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 200.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4.h),
                          Text(date,
                              style: TextStyle(
                                  fontSize: 10.sp, color: DefaultColors.grey)),
                        ],
                      ),
                    ),
                    Text(currencyFormatter.format(v),
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor)),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildFancyLegend({
    required Color color,
    required String label,
    required String amount,
    required double percent,
    required ThemeData theme,
  }) {
    final double pct = percent.isNaN ? 0 : percent.clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 10.sp,
                color: DefaultColors.grey,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
