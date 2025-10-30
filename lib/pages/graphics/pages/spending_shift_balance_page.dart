// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';

import '../../../ads_banner/ads_banner.dart';

class SpendingShiftBalancePage extends StatefulWidget {
  final String selectedMonth;

  const SpendingShiftBalancePage({super.key, required this.selectedMonth});

  @override
  State<SpendingShiftBalancePage> createState() =>
      _SpendingShiftBalancePageState();
}

class _SpendingShiftBalancePageState extends State<SpendingShiftBalancePage> {
  // Todas as categorias do mês serão coletadas dinamicamente
  final Map<String, String> _macroToHeader = const {
    'Moradia e Casa': '🏠 Moradia',
    'Alimentação': '🍎 Alimentação',
    'Transporte': '🚗 Transporte',
    'Saúde e Bem-estar': '🏥 Saúde & Bem-estar',
    'Educação': '📚 Educação',
    'Lazer e Entretenimento': '🎭 Lazer & Entretenimento',
    'Compras': '🛍️ Compras & Estilo',
    'Pets': '🐾 Pets',
    'Finanças': '💰 Finanças & Impostos',
    'Impostos': '💰 Finanças & Impostos',
    'Família': '👨‍👩‍👧‍👦 Família & Social',
    'Trabalho': '💼 Trabalho',
    'Imprevistos': '🚨 Imprevistos',
    'Outros': '❓ Outros',
  };

  final List<String> _headerOrder = const [
    '🏠 Moradia',
    '🍎 Alimentação',
    '🚗 Transporte',
    '🏥 Saúde & Bem-estar',
    '📚 Educação',
    '🎭 Lazer & Entretenimento',
    '🛍️ Compras & Estilo',
    '🐾 Pets',
    '💰 Finanças & Impostos',
    '👨‍👩‍👧‍👦 Família & Social',
    '💼 Trabalho',
    '🚨 Imprevistos',
    '❓ Outros',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.put(TransactionController());

    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final int currentYearMonth = _resolveYearMonth(widget.selectedMonth);
    final int previousYearMonth = _previousYearMonth(currentYearMonth);

    final _FoodShiftData data = _computeFoodShift(
      transactionController,
      currentYearMonth,
      previousYearMonth,
    );

    final double netDelta = data.totalCurrent - data.totalPrevious;
    final bool saved = netDelta < 0;

    // Receita e saldo (mês atual)
    final int cy = currentYearMonth ~/ 100;
    final int cm = currentYearMonth % 100;
    double incomeCurrent = 0.0;
    double incomePrevious = 0.0;
    for (final t in transactionController.transaction) {
      if (t.paymentDay == null) continue;
      if (t.type != TransactionType.receita) continue;
      final DateTime d = DateTime.parse(t.paymentDay!);
      if (d.year == cy && d.month == cm) {
        incomeCurrent +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
      final int py = previousYearMonth ~/ 100;
      final int pm = previousYearMonth % 100;
      if (d.year == py && d.month == pm) {
        incomePrevious +=
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
      }
    }
    final double saldoCurrent = incomeCurrent - data.totalCurrent;
    final double saldoPrevious = incomePrevious - data.totalPrevious;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Balanço de Gastos'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdsBanner(),
                SizedBox(height: 16.h),
                _buildSummaryCard(
                    theme,
                    currencyFormatter,
                    netDelta,
                    saved,
                    data,
                    incomeCurrent,
                    incomePrevious,
                    saldoCurrent,
                    saldoPrevious,
                    _months()[(previousYearMonth % 100) - 1]),
                SizedBox(height: 16.h),
                AdsBanner(),
                SizedBox(height: 16.h),
                _buildCompensationsSection(theme, currencyFormatter, data),
                SizedBox(height: 16.h),
                // _buildMonthComparisonCard(theme, currencyFormatter, data),
                // SizedBox(height: 16.h),
                _buildHighlightsCard(theme, data),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompensationsSection(
      ThemeData theme, NumberFormat currencyFormatter, _FoodShiftData data) {
    if (data.items.isEmpty) return const SizedBox.shrink();

    // Nome do mês anterior com base na seleção da tela
    final int ym = _resolveYearMonth(widget.selectedMonth);
    final int pym = _previousYearMonth(ym);
    final String prevMonthName = _months()[(pym % 100) - 1];

    // Index by category name to aggregate curated comparisons
    final Map<String, _FoodItemShift> byName = {
      for (final it in data.items) it.name: it
    };

    // Group items by macro header and build savings/increases lists per header
    final Map<String, List<_FoodItemShift>> decByHeader = {};
    final Map<String, List<_FoodItemShift>> incByHeader = {};
    for (final it in data.items) {
      final info = findCategoryById(it.id);
      final String macro = (info?['macrocategoria'] as String?) ?? 'Outros';
      final String header = _macroToHeader[macro] ?? macro;
      if (it.current < it.previous) {
        decByHeader.putIfAbsent(header, () => <_FoodItemShift>[]).add(it);
      } else if (it.current > it.previous) {
        incByHeader.putIfAbsent(header, () => <_FoodItemShift>[]).add(it);
      }
    }
    decByHeader.forEach((_, list) => list.sort(
        (a, b) => (b.previous - b.current).compareTo(a.previous - a.current)));
    incByHeader.forEach((_, list) => list.sort(
        (a, b) => (b.current - b.previous).compareTo(a.current - a.previous)));

    if (decByHeader.isEmpty && incByHeader.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create pairs within the same header where possible
    final List<({String header, _FoodItemShift saveIt, _FoodItemShift incIt})>
        pairs = [];
    final Set<_FoodItemShift> usedDec = {};
    final Set<_FoodItemShift> usedInc = {};
    // Pair using preferred order first
    for (final header in _headerOrder) {
      final List<_FoodItemShift> decs = decByHeader[header] ?? const [];
      final List<_FoodItemShift> incs = incByHeader[header] ?? const [];
      final int cnt = decs.length < incs.length ? decs.length : incs.length;
      for (int k = 0; k < cnt; k++) {
        final _FoodItemShift d = decs[k];
        final _FoodItemShift i = incs[k];
        pairs.add((header: header, saveIt: d, incIt: i));
        usedDec.add(d);
        usedInc.add(i);
      }
    }
    // Pair for any remaining headers not in preferred order
    final Set<String> allHeaders = {
      ...decByHeader.keys,
      ...incByHeader.keys,
    };
    for (final header in allHeaders) {
      if (_headerOrder.contains(header)) continue;
      final List<_FoodItemShift> decs = decByHeader[header] ?? const [];
      final List<_FoodItemShift> incs = incByHeader[header] ?? const [];
      final int cnt = decs.length < incs.length ? decs.length : incs.length;
      for (int k = 0; k < cnt; k++) {
        final _FoodItemShift d = decs[k];
        final _FoodItemShift i = incs[k];
        pairs.add((header: header, saveIt: d, incIt: i));
        usedDec.add(d);
        usedInc.add(i);
      }
    }

    final List<_FoodItemShift> leftoverInc = incByHeader.values
        .expand((l) => l)
        .where((it) => !usedInc.contains(it))
        .toList();
    final List<_FoodItemShift> leftoverDec = decByHeader.values
        .expand((l) => l)
        .where((it) => !usedDec.contains(it))
        .toList();

    final List<Widget> rows = [];

    // Title
    rows.add(Text(
      ' Compensações de gastos',
      style: TextStyle(
        fontSize: 12.sp,
        color: DefaultColors.grey20,
        fontWeight: FontWeight.w500,
      ),
    ));
    rows.add(SizedBox(height: 10.h));

    // Curated comparisons that make sense (lists will be expanded em pares 1x1)
    final List<({String header, List<String> left, List<String> right})>
        curated = [
      (
        header: '🏠 Moradia',
        left: ['Coisas para Casa'],
        right: ['Manutenção e reparos'],
      ),
      (
        header: '🍎 Alimentação',
        left: ['Restaurantes'],
        right: ['Delivery'],
      ),
      (
        header: '🍎 Alimentação',
        left: ['Mercado'],
        right: ['Restaurantes', 'Delivery'],
      ),
      (
        header: '🍎 Alimentação',
        left: ['Lanches'],
        right: ['Padaria'],
      ),
      (
        header: '🚗 Transporte',
        left: ['Transporte por Aplicativo'],
        right: ['Combustível'],
      ),
      (
        header: '🚗 Transporte',
        left: ['Pedágio/Estacionamento'],
        right: ['Transporte por Aplicativo'],
      ),
      (
        header: '🚗 Transporte',
        left: ['Seguro do Carro'],
        right: ['Multas', 'IPVA'],
      ),
      (
        header: '🏥 Saúde & Bem-estar',
        left: ['Farmácia'],
        right: ['Consultas Médicas', 'Exames'],
      ),
      (
        header: '🏥 Saúde & Bem-estar',
        left: ['Academia'],
        right: ['Cuidados pessoais', 'Salão/Barbearia'],
      ),
      (
        header: '🎭 Lazer & Entretenimento',
        left: ['Cinema'],
        right: ['Streaming'],
      ),
      (
        header: '🎭 Lazer & Entretenimento',
        left: ['Viagens'],
        right: ['Passeios'],
      ),
      (
        header: '🎭 Lazer & Entretenimento',
        left: ['Bares'],
        right: ['Restaurantes', 'Lanches'],
      ),
      (
        header: '🛍️ Compras & Estilo',
        left: ['Roupas e acessórios'],
        right: ['Eletrônicos', 'Presentes'],
      ),
      (
        header: '🛍️ Compras & Estilo',
        left: ['Compras'],
        right: ['Vestuário'],
      ),
      (
        header: '🐾 Pets',
        left: ['Pets'],
        right: ['Veterinário'],
      ),
      (
        header: '💰 Finanças & Impostos',
        left: ['Assinaturas e serviços'],
        right: ['Streaming', 'Aplicativos'],
      ),
      (
        header: '💰 Finanças & Impostos',
        left: ['Financiamento'],
        right: ['Empréstimos'],
      ),
      (
        header: '👨‍👩‍👧‍👦 Família & Social',
        left: ['Família e filhos'],
        right: ['Doações/Caridade'],
      ),
    ];

    // Removed _sumPrev: now comparisons use only current month totals

    double sumCurr(List<String> names) {
      double s = 0.0;
      for (final n in names) {
        final it = byName[n];
        if (it != null) s += it.current;
      }
      return s;
    }

    // Expande cada regra em pares 1x1 (uma categoria vs outra)
    final List<({String header, String left, String right})> pairRules = [];
    for (final rule in curated) {
      for (final l in rule.left) {
        for (final r in rule.right) {
          pairRules.add((header: rule.header, left: l, right: r));
        }
      }
    }

    double netSum = 0.0;
    double baseSum = 0.0;
    for (final pr in pairRules) {
      final String leftName = pr.left;
      final String rightName = pr.right;
      final double lc = sumCurr([leftName]);
      final double rc = sumCurr([rightName]);

      if (lc == 0 && rc == 0) continue;

      final double diff = rc - lc; // >0: gastou mais à direita; <0: à esquerda
      final bool neutral = diff.abs() < 0.5;
      final bool positive = diff > 0.5;
      final String impacto = neutral
          ? 'Impacto final: neutro'
          : 'Impacto final: ${diff.isNegative ? '-' : '+'}${currencyFormatter.format(diff.abs())}';
      final double base = (lc + rc);
      final double? diffPct = base > 0 ? (diff.abs() / base) * 100.0 : null;
      final double leftShare = base > 0 ? (lc / base) * 100.0 : 0.0;
      final double rightShare = base > 0 ? (rc / base) * 100.0 : 0.0;

      netSum += diff;
      baseSum += base;

      rows.add(Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leftName,
                        softWrap: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DefaultColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        currencyFormatter.format(lc),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Iconsax.arrow_swap_horizontal,
                  size: 16.sp,
                  color: DefaultColors.grey,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        rightName,
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DefaultColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        currencyFormatter.format(rc),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '$prevMonthName vs atual: ${currencyFormatter.format(lc)} ↔️ ${currencyFormatter.format(rc)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Builder(builder: (_) {
              final double leftPrev = (byName[leftName]?.previous ?? 0.0);
              final double leftCurr = lc;
              final double rightPrev = (byName[rightName]?.previous ?? 0.0);
              final double rightCurr = rc;

              final double leftDelta =
                  leftCurr - leftPrev; // >0 aumentou, <0 economizou
              final double rightDelta = rightCurr - rightPrev; // >0 aumentou
              final double netDeltaPair =
                  (leftCurr + rightCurr) - (leftPrev + rightPrev);

              final String partLeft =
                  'No mês passado você gastou ${currencyFormatter.format(leftPrev)} em $leftName e este mês ${currencyFormatter.format(leftCurr)}';
              final String partLeftChange = leftDelta < -0.5
                  ? ', economizando ${currencyFormatter.format((-leftDelta).abs())}'
                  : (leftDelta > 0.5
                      ? ', gastando ${currencyFormatter.format(leftDelta.abs())} a mais'
                      : ', mantendo praticamente igual');

              String partRight;
              if (rightDelta > 0.5) {
                partRight =
                    ', porém essa economia foi compensada pelo aumento em $rightName, que passou de ${currencyFormatter.format(rightPrev)} no mês passado para ${currencyFormatter.format(rightCurr)} (+${currencyFormatter.format(rightDelta.abs())}).';
              } else if (rightDelta < -0.5) {
                partRight =
                    ', além disso, houve redução em $rightName: de ${currencyFormatter.format(rightPrev)} para ${currencyFormatter.format(rightCurr)} (-${currencyFormatter.format((-rightDelta).abs())}).';
              } else {
                partRight = ', enquanto em $rightName ficou estável.';
              }

              String conclusion;
              if (netDeltaPair.abs() < 0.5) {
                conclusion =
                    ' Ou seja, apesar das mudanças, o gasto total não diminuiu.';
              } else if (netDeltaPair > 0.5) {
                conclusion =
                    ' Ou seja, mesmo com a redução, o gasto combinado aumentou ${currencyFormatter.format(netDeltaPair.abs())}.';
              } else {
                conclusion =
                    ' Ou seja, o gasto combinado diminuiu ${currencyFormatter.format(netDeltaPair.abs())}.';
              }

              return Text(
                partLeft + partLeftChange + partRight + conclusion,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      ));
    }

    // Paired items grouped by header
    for (final pair in pairs) {
      final _FoodItemShift saveIt = pair.saveIt;
      final _FoodItemShift incIt = pair.incIt;
      final double save = (saveIt.previous - saveIt.current);
      final double extra = (incIt.current - incIt.previous);
      final double net = extra - save;
      final bool neutral = net.abs() < 0.5;
      final bool positive = net > 0.5;
      final String impacto = neutral
          ? 'Impacto final: neutro'
          : 'Impacto final: ${net.isNegative ? '-' : '+'}${currencyFormatter.format(net.abs())}';
    }

    final double netDelta = netSum;
    final bool netPositive = netDelta > 0.5;
    final bool netNeutral = netDelta.abs() < 0.5;
    final String resumo = netNeutral
        ? 'No conjunto dessas comparações, ficou elas por elas neste mês.'
        : (netPositive
            ? 'No conjunto dessas comparações, o saldo foi de +${currencyFormatter.format(netDelta.abs())} neste mês.'
            : 'No conjunto dessas comparações, o saldo foi de -${currencyFormatter.format(netDelta.abs())} neste mês.');

    rows.add(SizedBox(height: 6.h));

    rows.add(SizedBox(height: 8.h));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildSummaryCard(
      ThemeData theme,
      NumberFormat currencyFormatter,
      double netDelta,
      bool saved,
      _FoodShiftData data,
      double incomeCurrent,
      double incomePrevious,
      double saldoCurrent,
      double saldoPrevious,
      String prevMonthName) {
    // Cálculos de variações
    final String receitaPct = (() {
      if (incomePrevious <= 0 && incomeCurrent <= 0) return '0%';
      if (incomePrevious <= 0 && incomeCurrent > 0) return '+100%';
      final double p =
          ((incomeCurrent - incomePrevious) / incomePrevious) * 100.0;
      final String sign = p >= 0.5 ? '+' : '';
      return '$sign${p.toStringAsFixed(1)}%';
    })();

    final String despesaPct = (() {
      if (data.totalPrevious <= 0 && data.totalCurrent <= 0) return '0%';
      if (data.totalPrevious <= 0 && data.totalCurrent > 0) return '+100%';
      final double p =
          ((data.totalCurrent - data.totalPrevious) / data.totalPrevious) *
              100.0;
      final String sign = p >= 0.5 ? '+' : '';
      return '$sign${p.toStringAsFixed(1)}%';
    })();

    final double saldoDelta = saldoCurrent - saldoPrevious;
    final String saldoPct = (() {
      if (saldoPrevious == 0 && saldoCurrent == 0) return '0%';
      if (saldoPrevious == 0 && saldoCurrent != 0) return '+100%';
      final double p = ((saldoCurrent - saldoPrevious) / saldoPrevious) * 100.0;
      final String sign = p >= 0.5 ? '+' : '';
      return '$sign${p.toStringAsFixed(1)}%';
    })();
    final String saldoTxt = saldoDelta >= 0 ? 'melhorou' : 'piorou';
    final double receitaDelta = incomeCurrent - incomePrevious;
    final double despesaDelta = data.totalCurrent - data.totalPrevious;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: theme.primaryColor.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Saldo",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: DefaultColors.grey,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Text(
                  'vs $prevMonthName',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            currencyFormatter.format(saldoCurrent),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: saldoCurrent >= 0
                  ? DefaultColors.greenDark
                  : DefaultColors.redDark,
              fontSize: 30.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                saldoDelta >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 14.sp,
                color: saldoDelta >= 0
                    ? DefaultColors.greenDark
                    : DefaultColors.redDark,
              ),
              SizedBox(width: 6.w),
              Text(
                'Saldo $saldoTxt em ${currencyFormatter.format(saldoDelta.abs())}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: saldoDelta >= 0
                      ? DefaultColors.greenDark
                      : DefaultColors.redDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                " ($saldoPct)",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: saldoDelta >= 0
                      ? DefaultColors.greenDark
                      : DefaultColors.redDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      theme,
                      title: 'Receita',
                      value: currencyFormatter.format(incomeCurrent),
                      pctText: receitaPct,
                      deltaCurrencyText:
                          '${receitaDelta >= 0 ? '+' : '-'}${currencyFormatter.format(receitaDelta.abs())}',
                      color: receitaDelta >= 0
                          ? DefaultColors.greenDark
                          : DefaultColors.redDark,
                      arrowIcon: receitaDelta >= 0
                          ? Icons.north_east
                          : Icons.south_east,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildKpiCard(
                      theme,
                      title: 'Despesas',
                      value: currencyFormatter.format(data.totalCurrent),
                      pctText: despesaPct,
                      deltaCurrencyText:
                          '${despesaDelta >= 0 ? '+' : '-'}${currencyFormatter.format(despesaDelta.abs())}',
                      color: despesaDelta >= 0
                          ? DefaultColors.redDark
                          : DefaultColors.greenDark,
                      arrowIcon: despesaDelta >= 0
                          ? Icons.north_east
                          : Icons.south_east,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Builder(builder: (_) {
                if (data.items.isEmpty || data.totalCurrent <= 0) {
                  return const SizedBox.shrink();
                }

                // Insight 1: maior gasto (participação no mês atual)
                final _FoodItemShift top =
                    data.items.reduce((a, b) => a.current >= b.current ? a : b);
                final double topShare =
                    (top.current / data.totalCurrent) * 100.0;
                final String insightTop =
                    'Seu maior gasto foi com ${top.name}, representando ${topShare.toStringAsFixed(0)}% do total.';

                // Insight 2: onde mais economizou (maior queda absoluta)
                _FoodItemShift? bestSaveItem;
                double bestSaveValue = 0.0;
                for (final it in data.items) {
                  final double save = it.previous - it.current;
                  if (save > bestSaveValue) {
                    bestSaveValue = save;
                    bestSaveItem = it;
                  }
                }
                final String? insightSave =
                    bestSaveValue > 0 && bestSaveItem != null
                        ? 'Você economizou mais em ${bestSaveItem.name}.'
                        : null;

                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: insightTop,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (insightSave != null)
                          TextSpan(
                            text: ' $insightSave',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                );
              }),
              Builder(builder: (_) {
                if (data.items.isEmpty || data.totalCurrent <= 0) {
                  return const SizedBox.shrink();
                }

                final List<_FoodItemShift> sorted =
                    List<_FoodItemShift>.from(data.items)
                      ..sort((a, b) => b.current.compareTo(a.current));
                final int showCount = sorted.length >= 5 ? 5 : sorted.length;
                final List<_FoodItemShift> topItems =
                    sorted.take(showCount).toList();
                final List<String> parts = topItems.map((it) {
                  final double pct = (it.current / data.totalCurrent) * 100.0;
                  return '${it.name} ${pct.toStringAsFixed(0)}%';
                }).toList();
                final double othersShare = 100.0 -
                    topItems.fold(
                        0.0,
                        (s, it) =>
                            s + ((it.current / data.totalCurrent) * 100.0));
                if (sorted.length > showCount && othersShare > 0.5) {
                  parts.add('Outras ${othersShare.toStringAsFixed(0)}%');
                }

                return Padding(
                  padding: EdgeInsets.only(top: 8.h, left: 2.w, right: 2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Participação por categoria',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DefaultColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        parts.join(', '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthComparisonCard(
      ThemeData theme, NumberFormat currencyFormatter, _FoodShiftData data) {
    if (data.items.isEmpty) return const SizedBox.shrink();

    // Determinar máximos para escala
    final double maxValue = data.items.fold<double>(0.0,
        (m, e) => [m, e.previous, e.current].reduce((a, b) => a > b ? a : b));
    final double safeMax = maxValue <= 0 ? 1.0 : maxValue;

    // Encontrar maior aumento e maior economia
    _FoodItemShift? incItem;
    double incPct = -1e9;
    _FoodItemShift? decItem;
    double decPct = -1e9;
    for (final it in data.items) {
      final double prev = it.previous;
      final double curr = it.current;
      double pctChange;
      if (prev <= 0 && curr > 0) {
        pctChange = 100.0;
      } else if (prev <= 0 && curr <= 0) {
        pctChange = 0.0;
      } else {
        pctChange = ((curr - prev) / prev) * 100.0;
      }
      if (pctChange > incPct) {
        incPct = pctChange;
        incItem = it;
      }
      if (-pctChange > decPct) {
        decPct = -pctChange;
        decItem = it;
      }
    }

    String buildInsight() {
      String left = '';
      if (decItem != null && decPct > 0.5) {
        left =
            'Você gastou ${decPct.toStringAsFixed(0)}% menos em ${decItem.name} em relação ao mês passado';
      }
      String right = '';
      if (incItem != null && incPct > 0.5) {
        right = 'aumentou ${incPct.toStringAsFixed(0)}% em ${incItem.name}';
      }
      if (left.isEmpty && right.isEmpty) {
        return 'Seus gastos ficaram estáveis em relação ao mês passado.';
      }
      if (left.isNotEmpty && right.isNotEmpty) return '$left, mas $right.';
      return left.isNotEmpty ? '$left.' : 'Você $right.';
    }

    List<Widget> lines = [];
    lines.add(Text(
      'Comparação por categoria (mês atual x mês anterior)',
      style: TextStyle(
        fontSize: 12.sp,
        color: DefaultColors.grey,
        fontWeight: FontWeight.w600,
      ),
    ));
    lines.add(SizedBox(height: 8.h));

    // Legenda
    lines.add(Row(
      children: [
        Container(width: 12.w, height: 6.h, color: DefaultColors.blueGrey),
        SizedBox(width: 6.w),
        Text('Mês anterior',
            style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
        SizedBox(width: 16.w),
        Container(width: 12.w, height: 6.h, color: DefaultColors.greenDark),
        SizedBox(width: 6.w),
        Text('Mês atual',
            style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey)),
      ],
    ));
    lines.add(SizedBox(height: 8.h));

    for (final it in data.items) {
      lines.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              it.name,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            LayoutBuilder(builder: (context, constraints) {
              final double full = constraints.maxWidth;
              final double prevW = (it.previous / safeMax) * full;
              final double currW = (it.current / safeMax) * full;
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: DefaultColors.blueGrey,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      width: prevW.clamp(0, full),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: DefaultColors.greenDark,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      width: currW.clamp(0, full),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Anterior: ${currencyFormatter.format(it.previous)}',
                    style:
                        TextStyle(fontSize: 11.sp, color: DefaultColors.grey)),
                Text('Atual: ${currencyFormatter.format(it.current)}',
                    style:
                        TextStyle(fontSize: 11.sp, color: DefaultColors.grey)),
              ],
            ),
            SizedBox(height: 2.h),
            Builder(builder: (_) {
              final double diff = it.current - it.previous;
              double pctChange;
              if (it.previous <= 0 && it.current > 0) {
                pctChange = 100.0;
              } else if (it.previous <= 0 && it.current <= 0) {
                pctChange = 0.0;
              } else {
                pctChange = ((it.current - it.previous) / it.previous) * 100.0;
              }
              final bool up = diff > 0.5;
              final String sign = diff >= 0 ? '+' : '-';
              return Text(
                'Variação: $sign${currencyFormatter.format(diff.abs())} (${up ? '+' : ''}${pctChange.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: up ? DefaultColors.redDark : DefaultColors.green,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      ));
    }

    // Insight textual
    lines.add(SizedBox(height: 8.h));
    lines.add(Text(
      buildInsight(),
      style: TextStyle(
        fontSize: 12.sp,
        color: theme.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    ));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      ),
    );
  }

  Widget _buildHighlightsCard(ThemeData theme, _FoodShiftData data) {
    if (data.items.isEmpty) return const SizedBox.shrink();
    _FoodItemShift? incItem;
    double incPct = -1e9;
    _FoodItemShift? decItem;
    double decPct = -1e9;
    for (final it in data.items) {
      final double prev = it.previous;
      final double curr = it.current;
      double pctChange;
      if (prev <= 0 && curr > 0) {
        pctChange = 100.0;
      } else if (prev <= 0 && curr <= 0) {
        pctChange = 0.0;
      } else {
        pctChange = ((curr - prev) / prev) * 100.0;
      }
      if (pctChange > incPct) {
        incPct = pctChange;
        incItem = it;
      }
      if (-pctChange > decPct) {
        decPct = -pctChange;
        decItem = it;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destaques',
            style: TextStyle(
              fontSize: 12.sp,
              color: DefaultColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          if (incItem != null)
            Row(
              children: [
                Text('📈', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Maior aumento: ${incItem.name} (+${incPct.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          if (decItem != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Text('📉', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Maior economia: ${decItem.name} (-${decPct.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // _buildSummaryPill removido (substituído por _buildKpiCard)

  Widget _buildKpiCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String pctText,
    String? deltaCurrencyText,
    required Color color,
    required IconData arrowIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      // decoration: BoxDecoration(
      //   color: theme.cardColor,
      //   borderRadius: BorderRadius.circular(14.r),
      //   border:
      //       Border.all(color: theme.primaryColor.withOpacity(0.06), width: 1),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.03),
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: DefaultColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(arrowIcon, size: 10.sp, color: Colors.white),
              ),
              SizedBox(width: 6.w),
              Text(
                pctText,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (deltaCurrencyText != null) ...[
                SizedBox(width: 6.w),
                Text(
                  deltaCurrencyText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(
      ThemeData theme, NumberFormat currencyFormatter, _FoodShiftData data) {
    // Mapeia macrocategorias do modelo -> cabeçalhos com emojis
    final Map<String, String> macroToHeader = _macroToHeader;

    final List<String> headerOrder = _headerOrder;

    // Agrupa itens por cabeçalho
    final Map<String, List<_FoodItemShift>> groups = {};
    for (final item in data.items) {
      final info = findCategoryById(item.id);
      final String macro = (info?['macrocategoria'] as String?) ?? 'Outros';
      final String header = macroToHeader[macro] ?? macro;
      groups.putIfAbsent(header, () => <_FoodItemShift>[]).add(item);
    }

    // Determina ordem final, incluindo grupos não mapeados
    final List<String> finalHeaders = [
      ...headerOrder.where((h) => groups.containsKey(h)),
      ...groups.keys.where((k) => !headerOrder.contains(k)).toList()..sort(),
    ];

    List<Widget> children = [
      Text(
        'Detalhes por categoria',
        style: TextStyle(
          fontSize: 16.sp,
          color: theme.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 10.h),
    ];

    for (final header in finalHeaders) {
      final items = groups[header]!;
      children.add(
        Container(
          margin: EdgeInsets.only(top: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              ...items.map((item) {
                final double delta = item.current - item.previous;
                final bool saved = delta < 0;
                final double share = data.totalCurrent > 0
                    ? (item.current / data.totalCurrent) * 100.0
                    : 0.0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(4.r)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${currencyFormatter.format(item.previous)} → ${currencyFormatter.format(item.current)}',
                              style: TextStyle(
                                  fontSize: 12.sp, color: DefaultColors.grey),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Participação no mês: ${share.toStringAsFixed(0)}% do total',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              saved
                                  ? 'Economizou ${currencyFormatter.format(delta.abs())}'
                                  : 'Gastou a mais ${currencyFormatter.format(delta)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: saved
                                    ? DefaultColors.green
                                    : DefaultColors.redDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 6.h),
              SizedBox(height: 6.h),
              Builder(builder: (_) {
                final List<_FoodItemShift> decreased = items
                    .where((i) => i.current < i.previous)
                    .toList()
                  ..sort((a, b) => (a.previous - a.current)
                      .compareTo(b.previous - b.current));
                final List<_FoodItemShift> increased = items
                    .where((i) => i.current > i.previous)
                    .toList()
                  ..sort((a, b) => (b.current - b.previous)
                      .compareTo(a.current - a.previous));
                final List<_FoodItemShift> unchanged = items
                    .where((i) => i.current == i.previous)
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

                String fmtDiff(_FoodItemShift it) {
                  final double diff = (it.current - it.previous).abs();
                  final double? pct =
                      it.previous > 0 ? (diff / it.previous) * 100.0 : null;
                  return pct == null
                      ? '${currencyFormatter.format(diff)} (novo)'
                      : '${currencyFormatter.format(diff)} (+${pct.toStringAsFixed(1)}%)';
                }

                List<Widget> lines = [];
                if (decreased.isNotEmpty) {
                  lines.add(Text(
                    'Você economizou nas categorias:',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: DefaultColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ));
                  lines.addAll(decreased.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}: -${currencyFormatter.format((it.previous - it.current).abs())}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }
                if (increased.isNotEmpty) {
                  lines.add(Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'Você gastou mais nas categorias:',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ));
                  lines.addAll(increased.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}: +${fmtDiff(it)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }
                if (unchanged.isNotEmpty) {
                  lines.add(Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'Mantiveram o mesmo valor:',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ));
                  lines.addAll(unchanged.map((it) => Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          '- ${it.name}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: DefaultColors.grey,
                          ),
                        ),
                      )));
                }

                if (lines.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines,
                );
              }),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  int _resolveYearMonth(String selectedMonth) {
    int month;
    if (selectedMonth.isEmpty) {
      month = DateTime.now().month;
    } else {
      final months = _months();
      final idx = months.indexOf(selectedMonth);
      month = idx >= 0 ? idx + 1 : DateTime.now().month;
    }
    final int year = DateTime.now().year;
    return year * 100 + month;
  }

  int _previousYearMonth(int yearMonth) {
    final int year = yearMonth ~/ 100;
    final int month = yearMonth % 100;
    if (month == 1) return (year - 1) * 100 + 12;
    return year * 100 + (month - 1);
  }

  _FoodShiftData _computeFoodShift(
      TransactionController controller, int currentYm, int previousYm) {
    final List<TransactionModel> expenses = controller.transaction
        .where((e) => e.type == TransactionType.despesa)
        .toList();

    double sumFor(int ym, int categoryId) {
      final int year = ym ~/ 100;
      final int month = ym % 100;
      double total = 0.0;
      for (final t in expenses) {
        if (t.paymentDay == null) continue;
        if (t.category != categoryId) continue;
        final DateTime date = DateTime.parse(t.paymentDay!);
        if (date.year == year && date.month == month) {
          total +=
              double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
        }
      }
      return total;
    }

    final int year = currentYm ~/ 100;
    final int month = currentYm % 100;
    final Set<int> usedIds = <int>{};
    for (final t in expenses) {
      if (t.paymentDay == null) continue;
      if (t.category == null) continue;
      final DateTime d = DateTime.parse(t.paymentDay!);
      if (d.year == year && d.month == month) {
        usedIds.add(t.category!);
      }
    }

    final List<_FoodItemShift> items = [];
    for (final id in usedIds) {
      final info = findCategoryById(id);
      final String name = (info?['name'] as String?) ?? 'Categoria';
      final Color color = (info?['color'] as Color?) ?? DefaultColors.green;
      final double previous = sumFor(previousYm, id);
      final double current = sumFor(currentYm, id);
      items.add(_FoodItemShift(
          id: id,
          name: name,
          color: color,
          previous: previous,
          current: current));
    }

    items.sort((a, b) => b.current.compareTo(a.current));

    final double totalPrevious = items.fold(0.0, (s, e) => s + e.previous);
    final double totalCurrent = items.fold(0.0, (s, e) => s + e.current);

    return _FoodShiftData(
        items: items, totalPrevious: totalPrevious, totalCurrent: totalCurrent);
  }

  List<String> _months() => const [
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
        'Dezembro',
      ];
}

class _FoodShiftData {
  final List<_FoodItemShift> items;
  final double totalPrevious;
  final double totalCurrent;

  _FoodShiftData(
      {required this.items,
      required this.totalPrevious,
      required this.totalCurrent});
}

class _FoodItemShift {
  final int id;
  final String name;
  final Color color;
  final double previous;
  final double current;

  _FoodItemShift({
    required this.id,
    required this.name,
    required this.color,
    required this.previous,
    required this.current,
  });
}
