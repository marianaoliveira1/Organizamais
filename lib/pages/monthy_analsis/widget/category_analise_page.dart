import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:organizamais/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/controller/auth_controller.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/transaction_page.dart';

import '../../graphics/widgtes/default_text_graphic.dart';

class CategoryMonthlyChart extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryMonthlyChart({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryMonthlyChart> createState() => _CategoryMonthlyChartState();
}

enum _ChartMode { bar, line }

class _CategoryMonthlyChartState extends State<CategoryMonthlyChart> {
  _ChartMode _chartMode = _ChartMode.bar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double contentMaxWidth = isTablet ? 900 : double.infinity;
        final double fontScale = isTablet ? 1.05 : 1.0;

        double scaledSp(double value) => value.sp * fontScale;

        return Obx(() {
          final monthlyData = _calculateMonthlyData(controller.transaction);
          final user = Get.find<AuthController>().firebaseUser.value;
          final String? uid = user?.uid;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextGraphic(
                          text: "Evolução Mensal da Categoria (até hoje)",
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color: widget.categoryColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Gasto',
                                  style: TextStyle(
                                    fontSize: scaledSp(11),
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 18.w),
                            Row(
                              children: [
                                Container(
                                  width: 26.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: DefaultColors.grey
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Meta',
                                  style: TextStyle(
                                    fontSize: scaledSp(11),
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 18.w),
                            Row(
                              children: [
                                SizedBox(
                                  width: 26.w,
                                  height: 2.h,
                                  child: CustomPaint(
                                    painter: _DashedLinePainter(
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Média Mensal',
                                  style: TextStyle(
                                    fontSize: scaledSp(11),
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _ChartModeButton(
                                      icon: Iconsax.chart_2,
                                      selected: _chartMode == _ChartMode.bar,
                                      onPressed: () {
                                        if (_chartMode != _ChartMode.bar) {
                                          setState(() =>
                                              _chartMode = _ChartMode.bar);
                                        }
                                      },
                                    ),
                                    SizedBox(width: 8.w),
                                    _ChartModeButton(
                                      icon: Iconsax.activity,
                                      selected: _ChartMode == _ChartMode.line,
                                      onPressed: () {
                                        if (_chartMode != _ChartMode.line) {
                                          setState(() =>
                                              _chartMode = _ChartMode.line);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  height: isTablet ? 360 : 320,
                                  width: double.infinity,
                                  child: StreamBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: uid == null
                                        ? const Stream.empty()
                                        : FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('categoryBudgets')
                                            .doc(widget.categoryId.toString())
                                            .snapshots(),
                                    builder: (context, budgetSnap) {
                                      final double budget = (budgetSnap.data
                                                  ?.data()?['amount'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                      final double monthlyAverage =
                                          _calculateMonthlyAverage(monthlyData);
                                      final expenseEntries =
                                          List<MapEntry<int, double>>.generate(
                                        12,
                                        (index) {
                                          final month = index + 1;
                                          return MapEntry(
                                            month,
                                            monthlyData[month] ?? 0.0,
                                          );
                                        },
                                      );
                                      final List<MapEntry<int, double>>
                                          metaEntries = expenseEntries
                                              .map(
                                                (entry) => MapEntry(
                                                  entry.key,
                                                  (budget > 0 &&
                                                          entry.value > 0)
                                                      ? budget
                                                      : 0.0,
                                                ),
                                              )
                                              .toList();
                                      final bool hasMetaBars = metaEntries
                                          .any((entry) => entry.value > 0);
                                      final double maxExpense =
                                          expenseEntries.fold<double>(
                                        0,
                                        (max, entry) => entry.value > max
                                            ? entry.value
                                            : max,
                                      );
                                      final double maxMeta =
                                          hasMetaBars ? budget : 0.0;
                                      final double axisBase = [
                                        maxExpense,
                                        maxMeta,
                                        monthlyAverage
                                      ].reduce((a, b) => a > b ? a : b);
                                      final double interval =
                                          _getOptimalInterval(axisBase);
                                      final double maxY =
                                          _calculateNiceMax(axisBase, interval);

                                      if (_chartMode == _ChartMode.bar) {
                                        return _buildCategoryBarChart(
                                          availableWidth: constraints.maxWidth,
                                          expenseEntries: expenseEntries,
                                          metaEntries: metaEntries,
                                          hasMetaBars: hasMetaBars,
                                          monthlyAverage: monthlyAverage,
                                          interval: interval,
                                          maxY: maxY,
                                          theme: theme,
                                        );
                                      }

                                      return _buildCategoryLineChart(
                                        expenseEntries: expenseEntries,
                                        metaEntries: metaEntries,
                                        hasMetaBars: hasMetaBars,
                                        monthlyAverage: monthlyAverage,
                                        interval: interval,
                                        maxY: maxY,
                                        theme: theme,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: uid == null
                        ? const Stream.empty()
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('categoryBudgets')
                            .doc(widget.categoryId.toString())
                            .snapshots(),
                    builder: (context, snap) {
                      final double budget =
                          (snap.data?.data()?['amount'] as num?)?.toDouble() ??
                              0.0;
                      final analysis =
                          _generateMonthlyAnalysis(monthlyData, budget);
                      if (analysis.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DefaultTextGraphic(
                              text: "Análise Mensal",
                            ),
                            SizedBox(height: 16.h),
                            ...analysis
                                .map((item) => _buildAnalysisItem(item, theme)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTextWithHighlightedNumbers(String text, ThemeData theme,
      {double fontSize = 13}) {
    // Regex para encontrar números (incluindo R$ e porcentagens)
    final RegExp numberPattern = RegExp(r'R\$[\s]?[\d.,]+|[\d.,]+%|[\d.,]+');

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final Match match in numberPattern.allMatches(text)) {
      // Adicionar texto antes do número
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w500,
            color: DefaultColors.textGrey,
            height: 1.4,
          ),
        ));
      }

      final String matchedText = match.group(0) ?? '';
      if (matchedText.startsWith('R\$')) {
        final bool hasSpaceAfterSymbol =
            matchedText.length > 2 && matchedText[2] == ' ';
        final String symbolText = hasSpaceAfterSymbol ? 'R\$ ' : 'R\$';
        final String valueText = matchedText.substring(symbolText.length);
        final double symbolFontSize = (fontSize * 0.6).sp;
        spans.add(TextSpan(
          text: symbolText,
          style: TextStyle(
            fontSize: symbolFontSize,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
            height: 1.4,
          ),
        ));
        spans.add(TextSpan(
          text: valueText,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
            height: 1.4,
          ),
        ));
      } else {
        // Adicionar número destacado comum
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
            height: 1.4,
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    // Adicionar texto restante
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w500,
          color: DefaultColors.textGrey,
          height: 1.4,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildAnalysisItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DefaultColors.grey20.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: (item['cardColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  item['icon'],
                  color: item['cardColor'],
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                item['month'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Linha 1: Variação
          _buildTextWithHighlightedNumbers(
            item['line1'],
            theme,
            fontSize: 13.sp,
          ),
          // Linha 2: Meta mensal
          if (item['line2'] != null && item['line2'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildTextWithHighlightedNumbers(
              item['line2'],
              theme,
              fontSize: 13.sp,
            ),
          ],
          // Linha 3: Status da meta
          if (item['line3'] != null && item['line3'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildTextWithHighlightedNumbers(
              item['line3'],
              theme,
              fontSize: 13.sp,
            ),
          ],
          // Linha 4: Mensagem explicativa
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: (item['cardColor'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              item['line4'],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: item['cardColor'],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMonthlyAnalysis(
      Map<int, double> monthlyData,
      [double budget = 0.0]) {
    List<Map<String, dynamic>> analysis = [];
    final currentMonth = DateTime.now().month;

    for (int month = 2; month <= currentMonth; month++) {
      double currentValue = monthlyData[month] ?? 0;
      double previousValue = monthlyData[month - 1] ?? 0;
      double difference = currentValue - previousValue;
      double absoluteDifference = difference.abs();

      if (currentValue > 0 || previousValue > 0) {
        double percentChange = 0;
        if (previousValue > 0) {
          percentChange = (difference / previousValue) * 100;
        } else if (currentValue > 0) {
          percentChange = 100; // Primeira despesa na categoria
        }

        Color cardColor;
        IconData icon;
        String line1; // Variação
        String line2; // Meta mensal
        String line3; // Status da meta
        String line4; // Mensagem explicativa

        // Construir linha 1 (variação)
        if (percentChange >= -5 && percentChange <= 5) {
          // Estável
          if (difference > 0) {
            line1 =
                'Variação mínima: aumentou R\$ ${_formatCurrency(absoluteDifference)} (${percentChange.toStringAsFixed(1)}%).';
          } else if (difference < 0) {
            line1 =
                'Variação mínima: diminuiu R\$ ${_formatCurrency(absoluteDifference)} (${percentChange.abs().toStringAsFixed(1)}%).';
          } else {
            line1 = 'Variação mínima: manteve o mesmo valor (0%).';
          }
        } else if (difference > 0) {
          line1 =
              'Aumentou em R\$ ${_formatCurrency(absoluteDifference)} (${percentChange.toStringAsFixed(1)}%).';
        } else {
          line1 =
              'Diminuiu em R\$ ${_formatCurrency(absoluteDifference)} (${percentChange.abs().toStringAsFixed(1)}%).';
        }

        // Construir linha 2 (meta mensal)
        if (budget > 0) {
          line2 = 'Meta mensal: R\$ ${_formatCurrency(budget)}.';
        } else {
          line2 = '';
        }

        // Construir linha 3 (status da meta)
        if (budget > 0) {
          final double remaining = budget - currentValue;
          if (remaining >= 0) {
            line3 =
                'Faltam R\$ ${_formatCurrency(remaining)} para atingir sua meta.';
          } else {
            line3 =
                'Você ultrapassou sua meta em R\$ ${_formatCurrency(remaining.abs())}.';
          }
        } else {
          line3 = '';
        }

        // Construir linha 4 (mensagem explicativa) e definir cores
        if (percentChange > 15) {
          cardColor = Colors.red;
          icon = Iconsax.arrow_circle_up;
          line4 =
              'Atenção! Seu gasto subiu muito acima do esperado. Vale revisar onde esse aumento aconteceu.';
        } else if (percentChange >= 5 && percentChange <= 15) {
          cardColor = Colors.orange;
          icon = Iconsax.arrow_circle_up;
          line4 =
              'Aumento moderado. Acompanhe de perto para manter o controle.';
        } else if (percentChange >= -5 && percentChange <= 5) {
          cardColor = Colors.grey;
          icon = Iconsax.arrow_right_2;
          line4 = 'Você manteve o mesmo padrão de gastos do mês anterior.';
        } else if (percentChange >= -15 && percentChange <= -5) {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          line4 = 'Ótima redução! Continue nesse ritmo.';
        } else {
          cardColor = Colors.green;
          icon = Iconsax.arrow_down_2;
          line4 = 'Excelente! Você teve uma economia significativa neste mês.';
        }

        analysis.add({
          'month': _getMonthName(month),
          'line1': line1,
          'line2': line2,
          'line3': line3,
          'line4': line4,
          'percentChange': percentChange,
          'isPositive': difference > 0,
          'currentValue': currentValue,
          'previousValue': previousValue,
          'cardColor': cardColor,
          'icon': icon,
        });
      }
    }

    return analysis;
  }

  // _getCategoryTips removido (não utilizado)

  // _buildTipItem removido

  Map<int, double> _calculateMonthlyData(List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final monthlyData = <int, double>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    // Calcular totais por mês para a categoria específica
    for (final transaction in transactions) {
      if (transaction.paymentDay != null &&
          transaction.category == widget.categoryId &&
          transaction.type == TransactionType.despesa) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  double _getOptimalInterval(double maxValue) {
    if (maxValue <= 0) return 100;

    // Calcular um intervalo que resulte em aproximadamente 4-6 divisões
    double rawInterval = maxValue / 5;

    // Arredondar para um valor "limpo"
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 25) return 25;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 250) return 250;
    if (rawInterval <= 500) return 500;
    if (rawInterval <= 1000) return 1000;
    if (rawInterval <= 2500) return 2500;
    if (rawInterval <= 5000) return 5000;

    // Para valores maiores, usar potências de 10
    double magnitude = 1;
    while (rawInterval > magnitude * 10) {
      magnitude *= 10;
    }

    if (rawInterval <= magnitude * 2.5) return magnitude * 2.5;
    if (rawInterval <= magnitude * 5) return magnitude * 5;
    return magnitude * 10;
  }

  double _calculateNiceMax(double rawMax, double interval) {
    double effectiveMax = rawMax.isFinite && rawMax > 0 ? rawMax : 1000;
    double effectiveInterval =
        interval.isFinite && interval > 0 ? interval : effectiveMax / 4;
    double niceMax =
        ((effectiveMax / effectiveInterval).ceil()) * effectiveInterval;
    if (niceMax <= effectiveMax) {
      niceMax += effectiveInterval;
    }
    return niceMax <= 0 ? effectiveInterval : niceMax;
  }

  double _calculateMonthlyAverage(Map<int, double> monthlyData) {
    final activeMonths =
        monthlyData.values.where((value) => value > 0).toList();
    if (activeMonths.isEmpty) return 0.0;
    return activeMonths.reduce((a, b) => a + b) / activeMonths.length;
  }

  Widget _buildCategoryBarChart({
    required double availableWidth,
    required List<MapEntry<int, double>> expenseEntries,
    required List<MapEntry<int, double>> metaEntries,
    required bool hasMetaBars,
    required double monthlyAverage,
    required double interval,
    required double maxY,
    required ThemeData theme,
  }) {
    final int groupCount = expenseEntries.length;
    final int barsPerGroup = hasMetaBars ? 2 : 1;
    const double minGroupSpacing = 10;
    const double minBarWidth = 8;

    final double totalSpacingWidth =
        groupCount > 1 ? (groupCount - 1) * minGroupSpacing : 0;
    double maxPossibleBarWidth = groupCount == 0
        ? minBarWidth
        : (availableWidth - totalSpacingWidth) / (groupCount * barsPerGroup);
    double barWidth =
        maxPossibleBarWidth.isFinite ? maxPossibleBarWidth : minBarWidth;
    barWidth = barWidth.clamp(minBarWidth, 20);

    final double totalBarsWidth = barWidth * groupCount * barsPerGroup;
    double remainingSpace = availableWidth - totalBarsWidth;
    double groupSpacing = groupCount > 1
        ? (remainingSpace / (groupCount - 1)).clamp(6.0, 24.0)
        : minGroupSpacing;
    if (!groupSpacing.isFinite) groupSpacing = minGroupSpacing;

    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 1000 : maxY,
        minY: 0,
        alignment: BarChartAlignment.center,
        groupsSpace: groupSpacing,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black.withValues(alpha: 0.8),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, _, rod, rodIndex) {
              final month = _getMonthName(group.x.toInt());
              final label = rodIndex == 0 ? 'Gasto' : 'Meta';
              return BarTooltipItem(
                '$month\\n$label: ${_formatCurrency(rod.toY)}',
                TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval > 0 ? interval : null,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, _) => Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _getMonthAbbr(value.toInt()),
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              interval: interval > 0 ? interval : null,
              getTitlesWidget: (value, _) => Text(
                _formatCurrencyShort(value),
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        extraLinesData: monthlyAverage > 0
            ? ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: monthlyAverage,
                  dashArray: const [6, 4],
                  color: theme.primaryColor,
                  strokeWidth: 1.4,
                ),
              ])
            : const ExtraLinesData(),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(groupCount, (index) {
          final expense = expenseEntries[index].value;
          final meta = metaEntries[index].value;
          final rods = <BarChartRodData>[
            BarChartRodData(
              toY: expense,
              color: widget.categoryColor,
              width: barWidth,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(barWidth * 0.35),
                topRight: Radius.circular(barWidth * 0.35),
              ),
            ),
          ];
          if (hasMetaBars) {
            rods.add(
              BarChartRodData(
                toY: meta,
                color: DefaultColors.grey,
                width: barWidth,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(barWidth * 0.35),
                  topRight: Radius.circular(barWidth * 0.35),
                ),
              ),
            );
          }
          return BarChartGroupData(
            x: expenseEntries[index].key,
            barsSpace: hasMetaBars ? 3 : 0,
            barRods: rods,
          );
        }),
      ),
    );
  }

  Widget _buildCategoryLineChart({
    required List<MapEntry<int, double>> expenseEntries,
    required List<MapEntry<int, double>> metaEntries,
    required bool hasMetaBars,
    required double monthlyAverage,
    required double interval,
    required double maxY,
    required ThemeData theme,
  }) {
    return SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: NumericAxis(
        minimum: 1,
        maximum: 12,
        interval: 1,
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          final int m = args.value.toInt();
          return ChartAxisLabel(
            _getMonthAbbr(m),
            TextStyle(
              color: DefaultColors.grey,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: maxY <= 0 ? 1000 : maxY,
        interval: interval > 0 ? interval : null,
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          return ChartAxisLabel(
            _formatCurrencyShort(args.value.toDouble()),
            TextStyle(
              color: DefaultColors.grey,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<Map<int, double>, num>>[
        SplineAreaSeries<Map<int, double>, num>(
          dataSource:
              expenseEntries.map((entry) => {entry.key: entry.value}).toList(),
          xValueMapper: (e, _) => e.keys.first,
          yValueMapper: (e, _) => e.values.first,
          color: widget.categoryColor.withValues(alpha: 0.10),
          borderColor: widget.categoryColor,
          borderWidth: 2,
        ),
        if (hasMetaBars)
          SplineSeries<Map<int, double>, num>(
            dataSource:
                metaEntries.map((entry) => {entry.key: entry.value}).toList(),
            xValueMapper: (e, _) => e.keys.first,
            yValueMapper: (e, _) => e.values.first,
            color: DefaultColors.grey,
            width: 3,
          ),
        if (monthlyAverage > 0)
          FastLineSeries<Map<int, double>, num>(
            dataSource: expenseEntries
                .map((entry) => {entry.key: monthlyAverage})
                .toList(),
            xValueMapper: (e, _) => e.keys.first,
            yValueMapper: (e, _) => e.values.first,
            color: theme.primaryColor,
            width: 2,
            dashArray: const <double>[5, 5],
            markerSettings: const MarkerSettings(isVisible: false),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
        format: 'point.y',
      ),
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[month - 1];
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatCurrencyShort(double value) {
    if (value == 0) return 'R\$ 0';

    if (value >= 1000000) {
      double millions = value / 1000000;
      if (millions == millions.roundToDouble()) {
        return 'R\$ ${millions.toStringAsFixed(0)}M';
      } else {
        return 'R\$ ${millions.toStringAsFixed(1)}M';
      }
    } else if (value >= 1000) {
      double thousands = value / 1000;
      if (thousands == thousands.roundToDouble()) {
        return 'R\$ ${thousands.toStringAsFixed(0)}k';
      } else {
        return 'R\$ ${thousands.toStringAsFixed(1)}k';
      }
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartModeButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _ChartModeButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          // color: selected
          //     ? theme.primaryColor.withValues(alpha: 0.1)
          //     : theme.cardColor,
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : DefaultColors.grey20.withValues(alpha: .4),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: selected ? theme.primaryColor : DefaultColors.grey,
        ),
      ),
    );
  }
}

class CategoryAnalysisPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;
  final String monthName;
  final double totalValue;
  final double percentual;

  const CategoryAnalysisPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.monthName,
    required this.totalValue,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    List<TransactionModel> transactions =
        _getTransactionsByCategoryForYear(categoryId);

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final bool isTablet = media.size.width >= 600;
    final double textScale = isTablet
        ? media.textScaleFactor
        : media.textScaleFactor.clamp(0.9, 1.0);

    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Análise de $categoryName",
            style: TextStyle(
              fontSize: isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            AdsBanner(),
            SizedBox(height: 8.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo da categoria
                    CategorySummaryAnalysisPage(
                      theme: theme,
                      categoryName: categoryName,
                      currencyFormatter: currencyFormatter,
                      totalValue: totalValue,
                      percentual: percentual,
                      categoryColor: categoryColor,
                    ),
                    SizedBox(height: 20.h),

                    // Card com média mensal
                    _buildMonthlyAverageCard(context, theme),
                    SizedBox(height: 20.h),

                    AdsBanner(),
                    SizedBox(height: 20.h),

                    // Gráfico mensal da categoria
                    CategoryMonthlyChart(
                      categoryId: categoryId,
                      categoryName: categoryName,
                      categoryColor: categoryColor,
                    ),

                    SizedBox(height: 20.h),

                    // Lista de transações
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                            color: theme.primaryColor.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transações no ano de ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: DefaultColors.grey20,
                            ),
                          ),
                          if (transactions.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.h),
                                child: Text(
                                  "Nenhuma transação encontrada",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (context, index) => Divider(
                              color: DefaultColors.grey20.withValues(alpha: .5),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              var transaction = transactions[index];
                              var transactionValue = double.parse(
                                transaction.value
                                    .replaceAll('.', '')
                                    .replaceAll(',', '.'),
                              );

                              String formattedDate = transaction.paymentDay !=
                                      null
                                  ? dateFormatter.format(
                                      DateTime.parse(transaction.paymentDay!),
                                    )
                                  : "Data não informada";

                              return InkWell(
                                onTap: () => Get.to(
                                  () => TransactionPage(
                                    transaction: transaction,
                                    overrideTransactionSalvar:
                                        (updatedTransaction) {
                                      final controller =
                                          Get.find<TransactionController>();
                                      controller.updateTransaction(
                                          updatedTransaction);
                                    },
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 160.w,
                                            child: Text(
                                              transaction.title,
                                              style: TextStyle(
                                                fontSize:
                                                    isTablet ? 13.sp : 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            currencyFormatter
                                                .format(transactionValue),
                                            style: TextStyle(
                                              fontSize:
                                                  isTablet ? 13.sp : 12.sp,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: DefaultColors.grey20,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120.w,
                                            child: Text(
                                              transaction.paymentType ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: DefaultColors.grey20,
                                              ),
                                              textAlign: TextAlign.end,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyAverageCard(BuildContext context, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Calcular dados mensais para a categoria
    final monthlyData =
        _calculateMonthlyDataForCategory(transactionController.transaction);

    // Calcular média mensal
    final activeMonths =
        monthlyData.values.where((value) => value > 0).toList();
    final monthlyAverage = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a + b) / activeMonths.length
        : 0.0;

    // Calcular maior e menor gasto
    final maxSpending = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final minSpending = activeMonths.isNotEmpty
        ? activeMonths.reduce((a, b) => a < b ? a : b)
        : 0.0;

    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Análise da Categoria',
          //   style: TextStyle(
          //     fontSize: 10.sp,
          //     fontWeight: FontWeight.w500,
          //     color: DefaultColors.grey20,
          //   ),
          // ),
          // SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média Mensal',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(monthlyAverage),
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menor Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(minSpending),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maior Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(maxSpending),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Meses Ativos',
              //         style: TextStyle(
              //           fontSize: 12.sp,
              //           fontWeight: FontWeight.w500,
              //           color: DefaultColors.grey20,
              //         ),
              //       ),
              //       SizedBox(height: 4.h),
              //       Text(
              //         '${activeMonths.length} de ${DateTime.now().month}',
              //         style: TextStyle(
              //           fontSize: 14.sp,
              //           fontWeight: FontWeight.bold,
              //           color: Get.theme.primaryColor,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyDataForCategory(
      List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, double>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    // Calcular totais por mês para a categoria específica
    for (final transaction in transactions) {
      if (transaction.paymentDay != null &&
          transaction.category == categoryId &&
          transaction.type == TransactionType.despesa) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  List<TransactionModel> _getTransactionsByCategoryForYear(int categoryId) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final DateTime today = DateTime.now();
    final int currentYear = today.year;

    final despesas = transactionController.transaction.where((e) {
      if (e.type != TransactionType.despesa || e.paymentDay == null) {
        return false;
      }
      final transactionDate = DateTime.parse(e.paymentDay!);
      return transactionDate.year == currentYear &&
          transactionDate.isBefore(today.add(const Duration(days: 1)));
    }).toList();

    return despesas
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  List<String> getAllMonths() {
    return [
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
  }
}

class CategorySummaryAnalysisPage extends StatelessWidget {
  const CategorySummaryAnalysisPage({
    super.key,
    required this.theme,
    required this.categoryName,
    required this.currencyFormatter,
    required this.totalValue,
    required this.percentual,
    required this.categoryColor,
  });

  final ThemeData theme;
  final String categoryName;
  final NumberFormat currencyFormatter;
  final double totalValue;
  final double percentual;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey20,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: 'No ano de 2025, você gastou ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: currencyFormatter.format(totalValue),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: ' na categoria ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: categoryName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: ', que representa ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
                TextSpan(
                  text: '${percentual.toStringAsFixed(1)}% ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: 'do valor total.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final double pct = (percentual.clamp(0, 100)) / 100.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct.isNaN ? 0.0 : pct.clamp(0.0, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${percentual.toStringAsFixed(1).replaceAll('.', ',')}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
