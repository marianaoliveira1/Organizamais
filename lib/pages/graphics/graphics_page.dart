// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
import 'package:organizamais/pages/graphics/widgtes/despesas_por_tipo_de_pagamento.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../ads_banner/ads_banner.dart';

import '../initial/widget/custom_drawer.dart';
import 'widgtes/finance_pie_chart.dart';
import 'widgtes/widget_list_category_graphics.dart';
import 'pages/select_categories_page.dart';
import 'pages/category_report_page.dart';
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

({int month, int year}) _parseSelectedMonthYear(String selected) {
  if (selected.isEmpty) {
    final now = DateTime.now();
    return (month: now.month, year: now.year);
  }
  final parts = selected.split('/');
  if (parts.length == 2) {
    final name = parts[0];
    final year = int.tryParse(parts[1]) ?? DateTime.now().year;
    final idx = getAllMonths().indexOf(name);
    final month = idx >= 0 ? idx + 1 : DateTime.now().month;
    return (month: month, year: year);
  }
  final idx = getAllMonths().indexOf(selected);
  return (
    month: (idx >= 0 ? idx + 1 : DateTime.now().month),
    year: DateTime.now().year
  );
}

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
  // Flags para animação de entrada única
  static bool _didEntranceAnimateOnce = false;
  bool _shouldPlayEntrance = false;
  bool _entranceVisible = false;
  int _scrollRetries = 0;
  bool _didIntroScroll = false;

  @override
  void initState() {
    super.initState();
    _monthScrollController = ScrollController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                  builder: (_) => const CategoryTypeSelectionPage()),
            );
            if (changed == true && mounted) {
              setState(() {});
            }
          },
          backgroundColor: theme.cardColor,
          content: _entranceWrap(
            _buildEssentialsVsNonEssentialsChart(
              theme,
              transactionController,
              currencyFormatter,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        AdsBanner(),
        SizedBox(height: 20.h),

        // Balanço de troca de gastos (InfoCard)
        InfoCard(
          title: 'Balanço de Gastos por Categoria',
          onTap: () {
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
          onTap: () {
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
            DespesasPorTipoDePagamento(selectedMonth: selectedMonth),
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
                }
              }
            }
            return _buildEssentialsVsNonEssentialsChart(
              theme,
              transactionController,
              currencyFormatter,
              overrides: map,
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
      String? override;
      try {
        final user = Get.find<AuthController>().firebaseUser.value;
        if (user != null) {
          // Síncrono não é possível aqui; vamos ler snapshot acima
        }
      } catch (_) {}
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
      final group = overrides[categoryId ?? -1] ?? classify(categoryName);
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
    var despesas = transactionController.transaction
        .where((e) => e.type == TransactionType.despesa)
        .toList();

    final parts = this.selectedMonth.split('/');
    final String monthName = parts.isNotEmpty ? parts[0] : this.selectedMonth;
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

  Map<String, dynamic> getSparklineData(
      TransactionController transactionController, DateFormat dayFormatter) {
    var filteredTransactions = getFilteredTransactions(transactionController);

    final parts = this.selectedMonth.split('/');
    final String monthName = parts.isNotEmpty ? parts[0] : this.selectedMonth;
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
                      height: 28.h,
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(bottom: index == 4 ? 0 : 6.h),
                      child: Text(
                        value >= 1000
                            ? 'R\$ ${(value / 1000).round()}k'
                            : 'R\$ ${value.round()}',
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
                      // Gráfico StepLine com Syncfusion
                      RepaintBoundary(
                        child: SizedBox(
                          height: 120.h,
                          child: SfCartesianChart(
                            margin: EdgeInsets.zero,
                            primaryXAxis: NumericAxis(
                              isVisible: false,
                              minimum: 0,
                              maximum: (data.length - 1).toDouble(),
                              majorGridLines: const MajorGridLines(width: 0),
                            ),
                            primaryYAxis: NumericAxis(
                              // Mantém eixos invisíveis, mas habilita linhas de grade
                              isVisible: true,
                              minimum: 0,
                              maximum: data.isNotEmpty &&
                                      data.reduce((a, b) => a > b ? a : b) > 0
                                  ? data.reduce((a, b) => a > b ? a : b) * 1.2
                                  : 100,
                              axisLine: const AxisLine(width: 0),
                              majorTickLines: const MajorTickLines(size: 0),
                              labelStyle: const TextStyle(
                                  color: Colors.transparent, fontSize: 0),
                              majorGridLines: MajorGridLines(
                                color: DefaultColors.grey.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            plotAreaBorderWidth: 0,
                            series: <CartesianSeries<MapEntry<int, double>,
                                num>>[
                              StackedLineSeries<MapEntry<int, double>, num>(
                                dataSource: data.asMap().entries.toList(),
                                xValueMapper: (e, _) => e.key,
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
                              format: 'point.y',
                            ),
                          ),
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
                  child: SfCartesianChart(
                    margin: EdgeInsets.zero,
                    primaryXAxis: NumericAxis(
                      minimum: -0.5,
                      maximum: (weeklyTotals.length - 1 + 0.5).toDouble(),
                      interval: 1,
                      rangePadding: ChartRangePadding.none,
                      plotOffset: 12,
                      majorGridLines: const MajorGridLines(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      axisLine: const AxisLine(width: 0),
                      axisLabelFormatter: (args) {
                        final idx = args.value.toInt();
                        final label = (idx >= 0 && idx < weekRangeLabels.length)
                            ? weekRangeLabels[idx]
                            : '';
                        return ChartAxisLabel(
                          label,
                          TextStyle(fontSize: 9.sp, color: DefaultColors.grey),
                        );
                      },
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: (weeklyTotals.isNotEmpty
                                  ? weeklyTotals.reduce((a, b) => a > b ? a : b)
                                  : 0) >
                              0
                          ? weeklyTotals.reduce((a, b) => a > b ? a : b) * 1.3
                          : 100,
                      interval: (weeklyTotals.isNotEmpty
                                  ? weeklyTotals.reduce((a, b) => a > b ? a : b)
                                  : 0) >
                              0
                          ? (weeklyTotals.reduce((a, b) => a > b ? a : b) / 4)
                          : 1,
                      majorGridLines: MajorGridLines(
                          color: DefaultColors.grey.withOpacity(0.15),
                          width: 1),
                      majorTickLines: const MajorTickLines(size: 0),
                      axisLine: const AxisLine(width: 0),
                      axisLabelFormatter: (args) {
                        final value = args.value;
                        final String label = value >= 1000
                            ? '${(value / 1000).round()}k'
                            : value.round().toString();
                        return ChartAxisLabel(
                          label,
                          TextStyle(fontSize: 9.sp, color: DefaultColors.grey),
                        );
                      },
                    ),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries<MapEntry<int, double>, num>>[
                      ColumnSeries<MapEntry<int, double>, num>(
                        dataSource: weeklyTotals.asMap().entries.toList(),
                        xValueMapper: (e, _) => e.key,
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
