import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/ads_banner/ads_banner.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controller/transaction_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../../utils/performance_helpers.dart';
import '../../transaction/pages/category_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetSuggestionsPage extends StatefulWidget {
  const BudgetSuggestionsPage({super.key});

  @override
  State<BudgetSuggestionsPage> createState() => _BudgetSuggestionsPageState();
}

class _BudgetSuggestionsPageState extends State<BudgetSuggestionsPage> {
  final TransactionController _transactionController =
      Get.find<TransactionController>();

  Map<int, String> _classificationOverrides = {};
  Map<String, String> _classificationOverridesByName = {};

  @override
  void initState() {
    super.initState();
    _loadClassificationOverrides();
  }

  Future<void> _loadClassificationOverrides() async {
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
      if (mounted) {
        setState(() {
          _classificationOverrides = map;
          _classificationOverridesByName = byName;
        });
      }
    } catch (_) {
      // Ignora erros
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Calcular receita total
    final incomeData = _calculateIncome();
    final totalIncome = incomeData['total'] as double;
    final incomeMonthName = incomeData['month'] as String;

    // Calcular valores sugeridos (50/30/20)
    final suggestedNecessidades = totalIncome * 0.5;
    final suggestedLazer = totalIncome * 0.3;
    final suggestedPoupanca = totalIncome * 0.2;

    // Calcular gastos reais usando a mesma lógica do gráfico "Fixas x Variáveis x Extras"
    final currentExpensesData =
        _calculateFixasVariaveisExtras(useCurrentMonth: true);
    final currentFixas = currentExpensesData['fixas'] as double;
    final currentVariaveis = currentExpensesData['variaveis'] as double;
    final currentExtras = currentExpensesData['extras'] as double;

    // Calcular gastos do mês anterior (ou mês atual se não houver)
    final previousExpensesData =
        _calculateFixasVariaveisExtras(useCurrentMonth: false);
    final previousFixas = previousExpensesData['fixas'] as double;
    final previousVariaveis = previousExpensesData['variaveis'] as double;
    final previousExtras = previousExpensesData['extras'] as double;

    // Calcular percentuais atuais
    final totalCurrent = currentFixas + currentVariaveis + currentExtras;
    final currentFixasPercent =
        totalCurrent > 0 ? (currentFixas / totalCurrent) * 100 : 0;
    final currentVariaveisPercent =
        totalCurrent > 0 ? (currentVariaveis / totalCurrent) * 100 : 0;
    final currentExtrasPercent =
        totalCurrent > 0 ? (currentExtras / totalCurrent) * 100 : 0;

    // Calcular dias restantes no mês
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;
    final progressPercent =
        daysInMonth > 0 ? (daysPassed / daysInMonth) * 100 : 0;

    // Projeção até o fim do mês
    final projectedFixas = progressPercent > 0
        ? (currentFixas / progressPercent) * 100
        : currentFixas;
    final projectedVariaveis = progressPercent > 0
        ? (currentVariaveis / progressPercent) * 100
        : currentVariaveis;
    final projectedExtras = progressPercent > 0
        ? (currentExtras / progressPercent) * 100
        : currentExtras;
    final totalProjected =
        projectedFixas + projectedVariaveis + projectedExtras;
    final projectedFixasPercent =
        totalProjected > 0 ? (projectedFixas / totalProjected) * 100 : 0;
    final projectedVariaveisPercent =
        totalProjected > 0 ? (projectedVariaveis / totalProjected) * 100 : 0;
    final projectedExtrasPercent =
        totalProjected > 0 ? (projectedExtras / totalProjected) * 100 : 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Método 50/30/20',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 20.h),
              // 1️⃣ Header
              _buildHeader(theme, incomeMonthName, totalIncome, formatter),

              SizedBox(height: 24.h),

              // 2️⃣ Card: O que é o método 50/30/20?
              _buildInfoCard(theme),

              SizedBox(height: 20.h),

              // 3️⃣ Card: Gráfico da distribuição
              _buildDistributionChartCard(
                theme: theme,
                currentFixasPercent: currentFixasPercent.toDouble(),
                currentVariaveisPercent: currentVariaveisPercent.toDouble(),
                currentExtrasPercent: currentExtrasPercent.toDouble(),
                fixas: currentFixas,
                variaveis: currentVariaveis,
                extras: currentExtras,
              ),

              SizedBox(height: 20.h),

              // 4️⃣ Card: Ideais vs Real
              _buildIdealVsRealCard(
                theme: theme,
                formatter: formatter,
                suggestedNecessidades: suggestedNecessidades,
                suggestedLazer: suggestedLazer,
                suggestedPoupanca: suggestedPoupanca,
                currentNecessidades: currentFixas,
                currentLazer: currentVariaveis,
                realPoupanca: currentExtras,
                previousNecessidades: previousFixas,
                previousLazer: previousVariaveis,
                previousPoupanca: previousExtras,
                previousMonthName: previousExpensesData['month'] as String,
              ),

              SizedBox(height: 20.h),

              // 5️⃣ Card: Projeção até o fim do mês
              _buildProjectionCard(
                theme: theme,
                projectedNecessidadesPercent: projectedFixasPercent.toDouble(),
                projectedLazerPercent: projectedVariaveisPercent.toDouble(),
                projectedPoupancaPercent: projectedExtrasPercent.toDouble(),
                daysRemaining: daysRemaining,
              ),

              SizedBox(height: 20.h),

              // 6️⃣ Card: Insights inteligentes
              _buildInsightsCard(
                theme: theme,
                formatter: formatter,
                currentNecessidades: currentFixas,
                currentLazer: currentVariaveis,
                realPoupanca: currentExtras,
                previousNecessidades: previousFixas,
                previousLazer: previousVariaveis,
                previousPoupanca: previousExtras,
                suggestedNecessidades: suggestedNecessidades,
                suggestedLazer: suggestedLazer,
                suggestedPoupanca: suggestedPoupanca,
              ),

              SizedBox(height: 20.h),

              // 7️⃣ Botões da parte inferior

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // 1️⃣ Header
  Widget _buildHeader(ThemeData theme, String monthName, double totalIncome,
      NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método 50/30/20',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Entenda sua distribuição ideal de gastos.',
          style: TextStyle(
            color: DefaultColors.grey20,
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: DefaultColors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, color: theme.primaryColor, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: 'Sua receita de '),
                      TextSpan(
                        text: monthName,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' foi '),
                      TextSpan(
                        text: formatter.format(totalIncome),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2️⃣ Card: O que é o método 50/30/20?
  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: DefaultColors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: DefaultColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.book_1,
                  color: DefaultColors.blue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Como funciona o método 50/30/20',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'O método 50/30/20 é uma forma simples de organizar seu dinheiro:',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          _buildMethodItem(
              theme, '50%', 'para necessidades', DefaultColors.blue),
          SizedBox(height: 8.h),
          _buildMethodItem(theme, '30%', 'para desejos', DefaultColors.orange),
          SizedBox(height: 8.h),
          _buildMethodItem(theme, '20%', 'para poupança e investimentos',
              DefaultColors.green),
          SizedBox(height: 16.h),
          Text(
            'O app calcula automaticamente essa divisão com base na sua receita.',
            style: TextStyle(
              color: DefaultColors.grey20,
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem(
      ThemeData theme, String percent, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            percent,
            style: TextStyle(
              color: color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  // 3️⃣ Card: Gráfico da distribuição
  Widget _buildDistributionChartCard({
    required ThemeData theme,
    required double currentFixasPercent,
    required double currentVariaveisPercent,
    required double currentExtrasPercent,
    required double fixas,
    required double variaveis,
    required double extras,
  }) {
    final total = fixas + variaveis + extras;
    if (total == 0) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Iconsax.chart_21, size: 48.sp, color: DefaultColors.grey20),
              SizedBox(height: 12.h),
              Text(
                'Nenhum dado disponível',
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = [
      {
        'name': 'Fixas',
        'value': fixas,
        'color': DefaultColors.darkBlue,
        'currentPercent': currentFixasPercent.toDouble(),
      },
      {
        'name': 'Variáveis',
        'value': variaveis.toDouble(),
        'color': DefaultColors.orangeDark,
        'currentPercent': currentVariaveisPercent.toDouble(),
      },
      {
        'name': 'Extras',
        'value': extras.toDouble(),
        'color': DefaultColors.plum,
        'currentPercent': currentExtrasPercent.toDouble(),
      },
    ];

    // Encontrar o índice do maior valor para explode
    final maxValue = data
        .map((e) => (e['value'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final explodeIndex =
        data.indexWhere((e) => (e['value'] as num).toDouble() == maxValue);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua divisão atual',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 180.h,
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              legend: const Legend(isVisible: false),
              series: <CircularSeries<Map<String, dynamic>, String>>[
                PieSeries<Map<String, dynamic>, String>(
                  dataSource: data,
                  xValueMapper: (e, _) => e['name'] as String,
                  yValueMapper: (e, _) => (e['value'] as num).toDouble(),
                  pointColorMapper: (e, _) => e['color'] as Color,
                  dataLabelMapper: (e, _) {
                    final double v = (e['value'] as num).toDouble();
                    final double pct = total > 0 ? (v / total) * 100 : 0;
                    return '${(e['name'] as String)}\n${pct.toStringAsFixed(0)}%';
                  },
                  explode: true,
                  explodeIndex: explodeIndex,
                  explodeOffset: '8%',
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Legendas
          ...data.map((item) {
            final currentPct = item['currentPercent'] as double;
            final color = item['color'] as Color;
            final name = item['name'] as String;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  Text(
                    '${currentPct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4️⃣ Card: Ideais vs Real
  Widget _buildIdealVsRealCard({
    required ThemeData theme,
    required NumberFormat formatter,
    required double suggestedNecessidades,
    required double suggestedLazer,
    required double suggestedPoupanca,
    required double currentNecessidades,
    required double currentLazer,
    required double realPoupanca,
    required double previousNecessidades,
    required double previousLazer,
    required double previousPoupanca,
    required String previousMonthName,
  }) {
    // Obter categorias usadas
    final currentCategories = _getCategoriesByType(useCurrentMonth: true);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ideais vs Real',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),

          // Necessidades
          _buildIdealVsRealItem(
            theme: theme,
            formatter: formatter,
            title: 'Necessidades (50%)',
            suggestedValue: suggestedNecessidades,
            previousValue: previousNecessidades,
            currentValue: currentNecessidades,
            color: DefaultColors.blue,
            categories: currentCategories['necessidades'] as List<String>,
          ),

          SizedBox(height: 20.h),
          Divider(color: DefaultColors.grey20.withOpacity(0.2), height: 1),
          SizedBox(height: 20.h),

          // Desejos
          _buildIdealVsRealItem(
            theme: theme,
            formatter: formatter,
            title: 'Desejos (30%)',
            suggestedValue: suggestedLazer,
            previousValue: previousLazer,
            currentValue: currentLazer,
            color: DefaultColors.orange,
            categories: currentCategories['lazer'] as List<String>,
          ),

          SizedBox(height: 20.h),
          Divider(color: DefaultColors.grey20.withOpacity(0.2), height: 1),
          SizedBox(height: 20.h),

          // Poupança
          _buildIdealVsRealItem(
            theme: theme,
            formatter: formatter,
            title: 'Poupança (20%)',
            suggestedValue: suggestedPoupanca,
            previousValue: previousPoupanca,
            currentValue: realPoupanca,
            color: DefaultColors.green,
            categories: currentCategories['poupanca'] as List<String>,
          ),
        ],
      ),
    );
  }

  Widget _buildIdealVsRealItem({
    required ThemeData theme,
    required NumberFormat formatter,
    required String title,
    required double suggestedValue,
    required double previousValue,
    required double currentValue,
    required Color color,
    required List<String> categories,
  }) {
    final difference = currentValue - suggestedValue;
    final differencePercent =
        suggestedValue > 0 ? (difference / suggestedValue) * 100 : 0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (differencePercent <= -10) {
      statusColor = DefaultColors.greenDark;
      statusText = 'Ok';
      statusIcon = Iconsax.tick_circle;
    } else if (differencePercent <= 10) {
      statusColor = DefaultColors.deepOrange;
      statusText = 'Perto';
      statusIcon = Iconsax.info_circle;
    } else {
      statusColor = DefaultColors.redDark;
      statusText = 'Acima';
      statusIcon = Iconsax.warning_2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Lista de categorias usadas
        if (categories.isNotEmpty) ...[
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: categories.map((category) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: theme.primaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],

        // Row: Ideal e Mês anterior
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ideal:',
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatter.format(suggestedValue),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Mês anterior:',
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatter.format(previousValue),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Row: Este mês
        Row(
          children: [
            Text(
              'Este mês:',
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              formatter.format(currentValue),
              style: TextStyle(
                color: statusColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5️⃣ Card: Projeção até o fim do mês
  Widget _buildProjectionCard({
    required ThemeData theme,
    required double projectedNecessidadesPercent,
    required double projectedLazerPercent,
    required double projectedPoupancaPercent,
    required int daysRemaining,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_2, color: DefaultColors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Projeção até o fim do mês',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '$daysRemaining dias restantes',
            style: TextStyle(
              color: DefaultColors.grey20,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Se continuar assim, você deve terminar o mês com:',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // Necessidades
          _buildProjectionItem(
            theme: theme,
            label: 'Necessidades',
            percent: projectedNecessidadesPercent,
            idealPercent: 50.0,
            color: DefaultColors.blue,
          ),

          SizedBox(height: 12.h),

          // Desejos
          _buildProjectionItem(
            theme: theme,
            label: 'Desejos',
            percent: projectedLazerPercent,
            idealPercent: 30.0,
            color: DefaultColors.orange,
          ),

          SizedBox(height: 12.h),

          // Poupança
          _buildProjectionItem(
            theme: theme,
            label: 'Poupança',
            percent: projectedPoupancaPercent,
            idealPercent: 20.0,
            color: DefaultColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionItem({
    required ThemeData theme,
    required String label,
    required double percent,
    required double idealPercent,
    required Color color,
  }) {
    final difference = percent - idealPercent;
    String status;
    Color statusColor;

    if (difference.abs() <= 5) {
      status = 'ok';
      statusColor = DefaultColors.green;
    } else if (difference > 0) {
      status = 'acima';
      statusColor = DefaultColors.red;
    } else {
      status = 'abaixo';
      statusColor = DefaultColors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}% ($status)',
              style: TextStyle(
                color: statusColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 6.h,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // 6️⃣ Card: Insights inteligentes
  Widget _buildInsightsCard({
    required ThemeData theme,
    required NumberFormat formatter,
    required double currentNecessidades,
    required double currentLazer,
    required double realPoupanca,
    required double previousNecessidades,
    required double previousLazer,
    required double previousPoupanca,
    required double suggestedNecessidades,
    required double suggestedLazer,
    required double suggestedPoupanca,
  }) {
    final insights = <Map<String, dynamic>>[];

    // Insight 1: Comparação de necessidades
    if (previousNecessidades > 0) {
      final diffPercent = ((currentNecessidades - previousNecessidades) /
              previousNecessidades) *
          100;
      if (diffPercent.abs() > 5) {
        insights.add({
          'text': diffPercent > 0
              ? 'Você gastou ${diffPercent.toStringAsFixed(0)}% a mais em Necessidades comparado ao mês anterior.'
              : 'Você gastou ${diffPercent.abs().toStringAsFixed(0)}% a menos em Necessidades comparado ao mês anterior.',
          'color': diffPercent > 0 ? DefaultColors.red : DefaultColors.green,
        });
      }
    }

    // Insight 2: Lazer dentro do limite
    final lazerDiff = currentLazer - suggestedLazer;
    final lazerDiffPercent =
        suggestedLazer > 0 ? (lazerDiff / suggestedLazer) * 100 : 0;
    if (lazerDiffPercent <= 10 && lazerDiffPercent >= -10) {
      insights.add({
        'text': 'Seu gasto em "Desejos" está dentro do limite, bom equilíbrio!',
        'color': DefaultColors.green,
      });
    } else if (lazerDiffPercent > 10) {
      insights.add({
        'text':
            'Atenção: Seus gastos com "Desejos" estão ${lazerDiffPercent.toStringAsFixed(0)}% acima do ideal.',
        'color': DefaultColors.orange,
      });
    }

    // Insight 3: Poupança
    final poupancaDiff = realPoupanca - suggestedPoupanca;
    final poupancaDiffPercent =
        suggestedPoupanca > 0 ? (poupancaDiff / suggestedPoupanca) * 100 : 0;
    if (poupancaDiffPercent >= 0) {
      insights.add({
        'text': 'Ótimo! Você está economizando conforme o método 50/30/20.',
        'color': DefaultColors.green,
      });
    } else {
      insights.add({
        'text':
            'Atenção: Sua poupança está abaixo do ideal. Considere reduzir gastos em outras categorias.',
        'color': DefaultColors.orange,
      });
    }

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.lamp, color: DefaultColors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Insights inteligentes',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...insights.map((insight) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: insight['color'] as Color,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      insight['text'] as String,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateIncome() {
    final now = DateTime.now();

    // Tentar calcular receita do último mês completo
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;

    final lastMonthStart = DateTime(lastMonthYear, lastMonth, 1);
    final lastMonthEnd = DateTime(lastMonthYear, lastMonth + 1, 0, 23, 59, 59);

    final lastMonthTransactions = _transactionController
        .getTransactionsForDateRange(lastMonthStart, lastMonthEnd);

    double lastMonthIncome = 0.0;
    for (final t in lastMonthTransactions) {
      if (t.type == TransactionType.receita) {
        lastMonthIncome += PerformanceHelpers.parseCurrencyValue(t.value);
      }
    }

    // Se não houver receita no último mês, usar mês atual
    if (lastMonthIncome == 0) {
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final currentMonthTransactions = _transactionController
          .getTransactionsForDateRange(currentMonthStart, currentMonthEnd);

      double currentMonthIncome = 0.0;
      for (final t in currentMonthTransactions) {
        if (t.type == TransactionType.receita) {
          currentMonthIncome += PerformanceHelpers.parseCurrencyValue(t.value);
        }
      }

      final monthNames = [
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

      return {
        'total': currentMonthIncome,
        'month': monthNames[now.month - 1],
      };
    }

    final monthNames = [
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

    return {
      'total': lastMonthIncome,
      'month': monthNames[lastMonth - 1],
    };
  }

  Map<String, dynamic> _calculateFixasVariaveisExtras(
      {required bool useCurrentMonth}) {
    final now = DateTime.now();
    int targetMonth;
    int targetYear;

    if (useCurrentMonth) {
      targetMonth = now.month;
      targetYear = now.year;
    } else {
      // Tentar calcular gastos do último mês completo
      targetMonth = now.month == 1 ? 12 : now.month - 1;
      targetYear = now.month == 1 ? now.year - 1 : now.year;
    }

    final monthStart = DateTime(targetYear, targetMonth, 1);
    final monthEnd = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

    final transactions = _transactionController.getTransactionsForDateRange(
        monthStart, monthEnd);

    double fixedTotal = 0.0;
    double variableTotal = 0.0;
    double extraTotal = 0.0;

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

      return 'variaveis';
    }

    for (final t in transactions) {
      if (t.type == TransactionType.despesa) {
        final double value = PerformanceHelpers.parseCurrencyValue(t.value);
        final int? categoryId = t.category;
        final Map<String, dynamic>? category =
            categoryId != null ? findCategoryById(categoryId) : null;
        final String? categoryName =
            category != null ? category['name'] as String? : null;
        final String? normalizedName = categoryName?.trim().toLowerCase();
        final int? resolvedId = (category != null
                ? (category['id'] is int ? category['id'] as int : null)
                : null) ??
            categoryId;
        final group = _classificationOverrides[resolvedId ?? -1] ??
            (normalizedName != null
                ? _classificationOverridesByName[normalizedName]
                : null) ??
            classify(categoryName);

        if (group == 'fixas') {
          fixedTotal += value;
        } else if (group == 'extras') {
          extraTotal += value;
        } else {
          variableTotal += value;
        }
      }
    }

    // Se não houver gastos e não for mês atual, tentar mês atual
    if (!useCurrentMonth &&
        fixedTotal == 0 &&
        variableTotal == 0 &&
        extraTotal == 0) {
      return _calculateFixasVariaveisExtras(useCurrentMonth: true);
    }

    final monthNames = [
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

    return {
      'fixas': fixedTotal,
      'variaveis': variableTotal,
      'extras': extraTotal,
      'month': monthNames[targetMonth - 1],
    };
  }

  Map<String, List<String>> _getCategoriesByType(
      {required bool useCurrentMonth}) {
    final now = DateTime.now();
    int targetMonth;
    int targetYear;

    if (useCurrentMonth) {
      targetMonth = now.month;
      targetYear = now.year;
    } else {
      targetMonth = now.month == 1 ? 12 : now.month - 1;
      targetYear = now.month == 1 ? now.year - 1 : now.year;
    }

    final monthStart = DateTime(targetYear, targetMonth, 1);
    final monthEnd = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

    final transactions = _transactionController.getTransactionsForDateRange(
        monthStart, monthEnd);

    final Map<String, Set<String>> categoriesMap = {
      'necessidades': <String>{},
      'lazer': <String>{},
      'poupanca': <String>{},
    };

    String normalize(String s) => s.trim().toLowerCase();

    String classify(String? name) {
      if (name == null) return 'variaveis';
      final n = normalize(name);

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

      return 'variaveis';
    }

    for (final t in transactions) {
      if (t.type == TransactionType.despesa && t.category != null) {
        final category = findCategoryById(t.category);
        if (category != null) {
          final categoryName = category['name'] as String? ?? 'Outros';
          final String normalizedName = categoryName.trim().toLowerCase();
          final int? resolvedId =
              (category['id'] is int ? category['id'] as int : null) ??
                  t.category;
          final group = _classificationOverrides[resolvedId ?? -1] ??
              _classificationOverridesByName[normalizedName] ??
              classify(categoryName);

          // Mapear: fixas -> necessidades, variaveis -> lazer, extras -> poupanca (para exibição)
          if (group == 'fixas') {
            categoriesMap['necessidades']?.add(categoryName);
          } else if (group == 'variaveis') {
            categoriesMap['lazer']?.add(categoryName);
          } else if (group == 'extras') {
            categoriesMap['poupanca']?.add(categoryName);
          }
        }
      }
    }

    // Se não houver categorias e não for mês atual, tentar mês atual
    if (!useCurrentMonth &&
        categoriesMap['necessidades']!.isEmpty &&
        categoriesMap['lazer']!.isEmpty &&
        categoriesMap['poupanca']!.isEmpty) {
      return _getCategoriesByType(useCurrentMonth: true);
    }

    return {
      'necessidades': categoriesMap['necessidades']!.toList()..sort(),
      'lazer': categoriesMap['lazer']!.toList()..sort(),
      'poupanca': categoriesMap['poupanca']!.toList()..sort(),
    };
  }
}
