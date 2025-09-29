import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Removed generic Iconsax usage to show the actual card/bank logo

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../transaction/pages/category_page.dart';

class InvoiceCategoriesBreakdownPage extends StatelessWidget {
  const InvoiceCategoriesBreakdownPage({
    super.key,
    required this.cardName,
    required this.periodStart,
    required this.periodEnd,
  });

  final String cardName;
  final DateTime periodStart;
  final DateTime periodEnd;

  double _parseAmount(String raw) {
    String s = raw.replaceAll('R\$', '').trim();
    if (s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(s) ?? 0.0;
    }
    s = s.replaceAll(' ', '');
    return double.tryParse(s) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final TransactionController txController =
        Get.find<TransactionController>();

    // Filtra transações do cartão e período
    final List<TransactionModel> txs = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      if ((t.paymentType ?? '') != cardName) return false;
      DateTime d;
      try {
        d = DateTime.parse(t.paymentDay!);
      } catch (_) {
        return false;
      }
      return !d.isBefore(periodStart) && !d.isAfter(periodEnd);
    }).toList();

    // Agrega por categoria
    final Map<int, double> totalsByCategory = <int, double>{};
    for (final t in txs) {
      final int? catId = t.category;
      if (catId == null) continue;
      totalsByCategory.update(catId, (v) => v + _parseAmount(t.value),
          ifAbsent: () => _parseAmount(t.value));
    }

    // Monta dados para gráfico e lista
    final List<_CategorySlice> slices = totalsByCategory.entries.map((e) {
      final info = findCategoryById(e.key);
      final Color color = (info != null && info['color'] is Color)
          ? info['color'] as Color
          : theme.primaryColor;
      final String name =
          (info != null ? (info['name'] as String? ?? '') : '').toString();
      return _CategorySlice(
        categoryId: e.key,
        name: name.isEmpty ? 'Categoria ${e.key}' : name,
        value: e.value,
        color: color,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final double total =
        slices.fold(0.0, (prev, s) => prev + (s.value.isFinite ? s.value : 0));

    final List<PieChartSectionData> sections = slices
        .map(
          (s) => PieChartSectionData(
            value: s.value,
            color: s.color,
            title: '',
            radius: 52,
            showTitle: false,
          ),
        )
        .toList();

    // Comparativo com mês anterior (mesmo cartão)
    final DateTime prevMonthStart =
        DateTime(periodStart.year, periodStart.month - 1, 1);
    final DateTime prevMonthEnd =
        DateTime(prevMonthStart.year, prevMonthStart.month + 1, 0, 23, 59, 59);
    final double prevTotal = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      if ((t.paymentType ?? '') != cardName) return false;
      DateTime d;
      try {
        d = DateTime.parse(t.paymentDay!);
      } catch (_) {
        return false;
      }
      return !d.isBefore(prevMonthStart) && !d.isAfter(prevMonthEnd);
    }).fold<double>(0.0, (s, t) => s + _parseAmount(t.value));
    String prevMonthName = DateFormat('MMMM', 'pt_BR').format(prevMonthStart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias do cartão'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdsBanner(),
              SizedBox(height: 12.h),
              // Cabeçalho (ícone do cartão + nome)
              Row(
                children: [
                  _CardLogo(cardName: cardName),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
              // Bloco informativo ANTES do gráfico
              Builder(builder: (context) {
                final double diff = total - prevTotal;
                final bool increased = diff > 0;
                final String verb = increased
                    ? 'aumentou'
                    : (diff < 0 ? 'diminuiu' : 'manteve');
                final Color color = diff > 0
                    ? DefaultColors.redDark
                    : (diff < 0 ? DefaultColors.greenDark : DefaultColors.grey);
                final String prevMonthName =
                    DateFormat('MMMM', 'pt_BR').format(prevMonthStart);
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'No mês anterior você gastou ${currency.format(prevTotal)}, e neste mês foram ${currency.format(total)}; houve ${verb} de ${currency.format(diff.abs())}.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),

              SizedBox(height: 20.h),

              AdsBanner(),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 34.r,
                              centerSpaceColor: theme.cardColor,
                              sections: sections,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ${currency.format(total)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              AdsBanner(),
              SizedBox(height: 20.h),
              // Lista de categorias
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slices.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final s = slices[index];
                  final double pct = total > 0 ? (s.value / total * 100) : 0.0;
                  final int txCount =
                      txs.where((t) => t.category == s.categoryId).length;
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                pct.toStringAsFixed(1) + '% do total',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DefaultColors.grey20,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              // Barra de progresso fina
                              LayoutBuilder(builder: (context, constraints) {
                                final double widthFactor =
                                    (pct / 100.0).clamp(0, 1);
                                return Container(
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: widthFactor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: s.color,
                                          borderRadius:
                                              BorderRadius.circular(999.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currency.format(s.value),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              txCount == 1
                                  ? '1 transação'
                                  : '$txCount transações',
                              style: TextStyle(
                                  fontSize: 10.sp, color: DefaultColors.grey20),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 12.h),
              // Cards de métricas rápidas
              Builder(builder: (context) {
                final int txCount = txs.length;
                final double avg = txCount > 0 ? total / txCount : 0.0;
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total de transações',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20)),
                            SizedBox(height: 4.h),
                            Text(
                              '$txCount',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 20.h),
              AdsBanner(),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySlice {
  _CategorySlice({
    required this.categoryId,
    required this.name,
    required this.value,
    required this.color,
  });

  final int categoryId;
  final String name;
  final double value;
  final Color color;
}

class _BankAssetIcon extends StatelessWidget {
  const _BankAssetIcon({required this.cardName});

  final String cardName;

  String? _matchAssetByName(String n) {
    // Normaliza e tenta casar com nomes conhecidos
    n = n.trim().toLowerCase();
    if (n.isEmpty) return null;

    // Mapeamentos diretos comuns
    if (n.contains('nubank')) return 'assets/icon-bank/nubank.png';
    if (n.contains('itau') || n.contains('itaú'))
      return 'assets/icon-bank/itau.png';
    if (n.contains('santander')) return 'assets/icon-bank/santander.png';
    if (n.contains('bradesco')) return 'assets/icon-bank/bradesco.png';
    if (n.contains('inter')) return 'assets/icon-bank/inter.png';
    if (n.contains('c6')) return 'assets/icon-bank/c6.png';
    if (n.contains('caixa')) return 'assets/icon-bank/caixa.png';
    if (n.contains('banco do brasil') || n.contains('bb'))
      return 'assets/icon-bank/banco-do-brasil.png';
    if (n.contains('safra')) return 'assets/icon-bank/safra.png';
    if (n.contains('original')) return 'assets/icon-bank/original.png';
    if (n.contains('pagbank')) return 'assets/icon-bank/pagbank.png';
    if (n.contains('neon')) return 'assets/icon-bank/neon.png';
    if (n.contains('next')) return 'assets/icon-bank/next.png';
    if (n.contains('btg')) return 'assets/icon-bank/btg.png';
    if (n.contains('xp')) return 'assets/icon-bank/xp.png';
    if (n.contains('sicredi')) return 'assets/icon-bank/sicredi.png';
    if (n.contains('sicoob')) return 'assets/icon-bank/sicoob.png';
    if (n.contains('will bank') || n.contains('willbank'))
      return 'assets/icon-bank/will-bank.png';

    // Bandeiras e carteiras (somente as que existem nas assets)
    if (n.contains('amex') || n.contains('american express'))
      return 'assets/icon-bank/american-express.png';
    if (n.contains('paypal')) return 'assets/icon-bank/pay-pal.png';
    if (n.contains('mercado pago')) return 'assets/icon-bank/mercado-pago.png';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? asset = _matchAssetByName(cardName);
    final String path = asset ?? 'assets/icon-bank/icone-generico.png';
    return Center(
      child: Image.asset(
        path,
        width: 18.w,
        height: 18.w,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _CardLogo extends StatelessWidget {
  const _CardLogo({required this.cardName});

  final String cardName;

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    try {
      final CardController cardController = Get.find<CardController>();
      final String needle = cardName.trim().toLowerCase();
      final cards = cardController.card;
      for (final c in cards) {
        final String name = c.name.trim().toLowerCase();
        final String bank = (c.bankName ?? '').trim().toLowerCase();
        final bool matches = needle == name ||
            needle.contains(name) ||
            (bank.isNotEmpty && (needle == bank || needle.contains(bank)));
        if (matches && (c.iconPath != null && c.iconPath!.isNotEmpty)) {
          assetPath = c.iconPath;
          break;
        }
      }
    } catch (_) {
      // ignore: unused_catch_clause
    }

    if (assetPath == null || assetPath!.isEmpty) {
      return _BankAssetIcon(cardName: cardName);
    }

    return Center(
      child: Image.asset(
        assetPath!,
        width: 50.w,
        height: 50.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
