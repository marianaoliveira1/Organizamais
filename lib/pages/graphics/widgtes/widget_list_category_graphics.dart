// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/graphics/graphics_page.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/services/percentage_calculation_service.dart';
import 'package:organizamais/model/percentage_result.dart';

import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../../ads_banner/ads_banner.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class WidgetListCategoryGraphics extends StatelessWidget {
  const WidgetListCategoryGraphics({
    super.key,
    required this.data,
    required this.monthName,
    required this.totalValue,
    required this.selectedCategoryId,
    required this.theme,
    required this.currencyFormatter,
    required this.dateFormatter,
    this.budgets = const {},
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final String monthName;
  final RxnInt selectedCategoryId;
  final ThemeData theme;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;
  final Map<int, double> budgets;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        var categoryId = item['category'] as int;
        var valor = item['value'] as double;
        // percentual removido (não utilizado após o redesign do header)
        var categoryColor = item['color'] as Color;
        var categoryIcon =
            item['icon'] as String?; // Obtém o ícone da categoria

        return Column(
          children: [
            // Item da categoria - Adicionado ícone
            GestureDetector(
              onTap: () {
                if (selectedCategoryId.value == categoryId) {
                  selectedCategoryId.value = null;
                } else {
                  selectedCategoryId.value = categoryId;
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            categoryIcon ?? 'assets/icons/category.png',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Builder(builder: (context) {
                                  final bool hasBudget =
                                      budgets.containsKey(categoryId);
                                  final double? budget = budgets[categoryId];
                                  if (hasBudget && budget != null) {
                                    return RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                currencyFormatter.format(valor),
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' de ',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: DefaultColors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: currencyFormatter
                                                .format(budget),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: DefaultColors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return Text(
                                    currencyFormatter.format(valor),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.end,
                                  );
                                }),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(builder: (context) {
                                  final double pctExpenses = totalValue > 0
                                      ? (valor / totalValue * 100)
                                      : 0.0;
                                  // % da receita do mês selecionado
                                  // final TransactionController controller =
                                  //     Get.find<TransactionController>();
                                  final parts = monthName.split('/');
                                  String selMonthName =
                                      parts.isNotEmpty ? parts[0] : monthName;
                                  // final int selYear = parts.length == 2
                                  //     ? int.tryParse(parts[1]) ??
                                  //         DateTime.now().year
                                  //     : DateTime.now().year;
                                  // normaliza abreviações (jan, fev, ...)
                                  const abbr = {
                                    'jan': 'Janeiro',
                                    'fev': 'Fevereiro',
                                    'mar': 'Março',
                                    'abr': 'Abril',
                                    'mai': 'Maio',
                                    'jun': 'Junho',
                                    'jul': 'Julho',
                                    'ago': 'Agosto',
                                    'set': 'Setembro',
                                    'out': 'Outubro',
                                    'nov': 'Novembro',
                                    'dez': 'Dezembro',
                                  };
                                  final key = selMonthName.trim().toLowerCase();
                                  if (abbr.containsKey(key)) {
                                    selMonthName = abbr[key]!;
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${pctExpenses.toStringAsFixed(0)}% das despesas',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: DefaultColors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                Obx(() => Icon(
                                      selectedCategoryId.value == categoryId
                                          ? Iconsax.arrow_up_24
                                          : Iconsax.arrow_down_1,
                                      size: 14.sp,
                                      color: DefaultColors.grey,
                                    )),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Builder(builder: (context) {
                              final tc = Get.find<TransactionController>();
                              // Usar o mês/ano selecionado (suporta "Mês" e "Mês/AAAA" e abreviações)
                              final now = DateTime.now();
                              final months = getAllMonths();
                              String selName = monthName;
                              int selYear = now.year;
                              if (selName.contains('/')) {
                                final p = selName.split('/');
                                selName = p[0];
                                selYear = int.tryParse(p[1]) ?? now.year;
                              }
                              // Normalizar abreviações
                              final Map<String, String> map = {
                                'jan': 'Janeiro',
                                'fev': 'Fevereiro',
                                'mar': 'Março',
                                'abr': 'Abril',
                                'mai': 'Maio',
                                'jun': 'Junho',
                                'jul': 'Julho',
                                'ago': 'Agosto',
                                'set': 'Setembro',
                                'out': 'Outubro',
                                'nov': 'Novembro',
                                'dez': 'Dezembro',
                              };
                              final key = selName.trim().toLowerCase();
                              if (map.containsKey(key)) selName = map[key]!;
                              final int idx = months.indexOf(selName);
                              final bool isCurrentMonthSelected =
                                  (selYear == now.year &&
                                      idx == (now.month - 1));

                              DateTime effectiveDate;
                              if (isCurrentMonthSelected) {
                                effectiveDate = DateTime(
                                    now.year, now.month, now.day, 23, 59, 59);
                              } else {
                                final int selectedMonth =
                                    (idx >= 0 ? idx + 1 : now.month);
                                final int daysInSelected =
                                    DateTime(selYear, selectedMonth + 1, 0).day;
                                effectiveDate = DateTime(
                                  selYear,
                                  selectedMonth,
                                  daysInSelected,
                                  23,
                                  59,
                                  59,
                                );
                              }

                              final cmp = PercentageCalculationService
                                  .calculateCategoryExpenseComparison(
                                tc.transaction,
                                categoryId,
                                effectiveDate,
                              );

                              Color cmpColor;
                              IconData cmpIcon;
                              String cmpText;
                              if (!cmp.hasData) {
                                cmpColor = DefaultColors.grey;
                                cmpIcon = Iconsax.more_circle;
                                cmpText = '0,0%';
                              } else {
                                cmpText = cmp.displayText;
                                switch (cmp.type) {
                                  case PercentageType.positive:
                                    // Para despesas: positive = diminuiu (bom) -> seta para baixo
                                    cmpColor = DefaultColors.greenDark;
                                    cmpIcon = Iconsax.arrow_circle_down;
                                    break;
                                  case PercentageType.negative:
                                    // Para despesas: negative = aumentou (ruim) -> seta para cima
                                    cmpColor = DefaultColors.redDark;
                                    cmpIcon = Iconsax.arrow_circle_up;
                                    break;
                                  case PercentageType.neutral:
                                    cmpColor = DefaultColors.grey;
                                    cmpIcon = Iconsax.more_circle;
                                    break;
                                  case PercentageType.newData:
                                    cmpColor = DefaultColors.grey;
                                    cmpIcon = Iconsax.star_1;
                                    break;
                                }
                              }

                              // Linha 3 no cabeçalho: somente o percentual + ícone
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cmpIcon, size: 12.sp, color: cmpColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    cmpText,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: cmpColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de transações da categoria expandida na pagina de gráfico a parte que clica
            Obx(
              () {
                if (selectedCategoryId.value != categoryId) {
                  return const SizedBox();
                }

                var categoryTransactions =
                    getTransactionsByCategoryAndMonth(categoryId, monthName);
                categoryTransactions.sort((a, b) {
                  if (a.paymentDay == null || b.paymentDay == null) return 0;
                  return DateTime.parse(b.paymentDay!)
                      .compareTo(DateTime.parse(a.paymentDay!));
                });

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.h,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdsBanner(),
                      SizedBox(
                        height: 10.h,
                      ),
                      if (budgets.containsKey(categoryId)) ...[
                        Builder(builder: (context) {
                          final double b = budgets[categoryId] ?? 0.0;
                          final double pct = b > 0 ? (valor / b) * 100 : 0.0;
                          final double clampedPct =
                              pct.isNaN ? 0 : pct.clamp(0, 100);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${clampedPct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: categoryColor,
                                    ),
                                  ),
                                ],
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final double widthFactor =
                                      (clampedPct / 100.0);
                                  return Container(
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: widthFactor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: categoryColor,
                                            borderRadius:
                                                BorderRadius.circular(999.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                currencyFormatter.format(valor),
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                'de ${currencyFormatter.format(b)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: DefaultColors.grey,
                                ),
                              ),
                              SizedBox(height: 6.h),
                            ],
                          );
                        }),
                        SizedBox(height: 12.h),
                      ],
                      // Resumo da meta mensal (se existir)
                      if (budgets.containsKey(categoryId)) ...[
                        Builder(builder: (context) {
                          final double budget = budgets[categoryId] ?? 0.0;
                          double totalCategoria = 0.0;
                          final txs = getTransactionsByCategoryAndMonth(
                              categoryId, monthName);
                          for (final t in txs) {
                            totalCategoria += double.parse(
                              t.value.replaceAll('.', '').replaceAll(',', '.'),
                            );
                          }
                          final double remaining = (budget - totalCategoria);
                          final bool exceeded = remaining < 0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              exceeded
                                  ? 'Você ultrapassou seu valor de gasto mensal em R\$ ${currencyFormatter.format(remaining.abs())}.'
                                  : 'Sua meta mensal é de R\$ ${currencyFormatter.format(budget)} e faltam R\$ ${currencyFormatter.format(remaining)} para chegar ao total.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: exceeded
                                    ? DefaultColors.redDark
                                    : theme.primaryColor,
                              ),
                            ),
                          );
                        }),
                      ],
                      _buildCategoryMonthComparison(
                        context,
                        categoryId,
                        theme,
                        categoryName: (item['name'] as String? ?? ''),
                        categoryIcon: item['icon'] as String?,
                        categoryColor: categoryColor,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),

                      _buildExpenseOverIncomeLine(categoryId, theme),
                      SizedBox(height: 6.h),

                      AdsBanner(),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transações recentes (${categoryTransactions.length})",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: DefaultColors.grey20,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                await AdsInterstitial.preload();
                                final shown =
                                    await AdsInterstitial.showIfReady();
                                if (!shown) {
                                  await AdsInterstitial.show();
                                }
                              } catch (_) {}
                              Get.to(() => _CategoryMonthComparePage(
                                    categoryId: categoryId,
                                    categoryName:
                                        (item['name'] as String? ?? ''),
                                    categoryColor: categoryColor,
                                    selectedMonthName: monthName,
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.primaryColor.withOpacity(.3)),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                'Ver mês atual e anterior',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryTransactions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: DefaultColors.grey20.withOpacity(.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          var transaction = categoryTransactions[index];
                          var transactionValue = double.parse(
                            transaction.value
                                .replaceAll('.', '')
                                .replaceAll(',', '.'),
                          );

                          String formattedDate = transaction.paymentDay != null
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
                                  controller
                                      .updateTransaction(updatedTransaction);
                                },
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120.w,
                                        child: Text(
                                          _withInstallmentLabel(
                                              transaction,
                                              Get.find<TransactionController>()
                                                  .transaction),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: theme.primaryColor,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: DefaultColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter
                                            .format(transactionValue),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: theme.primaryColor,
                                          letterSpacing: -0.5,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(
                                        width: 120.w,
                                        child: Text(
                                          transaction.paymentType ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: DefaultColors.grey,
                                            letterSpacing: -0.5,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
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
                      if (categoryTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Text(
                              "Nenhuma transação encontrada",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<TransactionModel> getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        final parts = monthName.split('/');
        final String targetMonthName = parts.isNotEmpty ? parts[0] : monthName;
        final int targetYear = parts.length == 2
            ? int.tryParse(parts[1]) ?? DateTime.now().year
            : DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];
          return transactionMonthName == targetMonthName &&
              transactionDate.year == targetYear;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  String _withInstallmentLabel(TransactionModel t, List<TransactionModel> all) {
    final regex = RegExp(r'^Parcela\s+(\d+)\s*:\s*(.+)$');
    final match = regex.firstMatch(t.title);
    if (match == null) return t.title;
    final current = int.tryParse(match.group(1) ?? '') ?? 0;
    final baseTitle = match.group(2) ?? '';
    final total = all.where((x) {
      final m = regex.firstMatch(x.title);
      if (m == null) return false;
      return (m.group(2) ?? '') == baseTitle;
    }).length;
    if (total <= 0) return t.title;
    return 'Parcela $current de $total — $baseTitle';
  }

  Widget _buildExpenseOverIncomeLine(int categoryId, ThemeData theme) {
    final TransactionController controller = Get.find<TransactionController>();

    // Receita total do mês selecionado
    double totalReceitaMes = 0.0;
    for (final t in controller.transaction) {
      if (t.paymentDay == null) continue;
      if (t.type != TransactionType.receita) continue;
      final d = DateTime.parse(t.paymentDay!);
      final parts = monthName.split('/');
      final String selMonthName = parts.isNotEmpty ? parts[0] : monthName;
      final int selYear = parts.length == 2
          ? int.tryParse(parts[1]) ?? DateTime.now().year
          : DateTime.now().year;
      final String mName = getAllMonths()[d.month - 1];
      if (mName != selMonthName || d.year != selYear) continue;
      totalReceitaMes +=
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
    }

    if (totalReceitaMes <= 0) return const SizedBox.shrink();

    // Despesa total da categoria no mês selecionado
    double totalCategoria = 0.0;
    final txs = getTransactionsByCategoryAndMonth(categoryId, monthName);
    for (final t in txs) {
      totalCategoria +=
          double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
    }

    if (totalCategoria <= 0) return const SizedBox.shrink();

    final pct = (totalCategoria / totalReceitaMes) * 100.0;

    return Text(
      'Corresponde a ${pct.toStringAsFixed(1)}% do valor que você recebe no mês.',
      style: TextStyle(
        fontSize: 12.sp,
        color: theme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryMonthComparison(
      BuildContext context, int categoryId, ThemeData theme,
      {String? categoryName, String? categoryIcon, Color? categoryColor}) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Definir datas conforme o mês/ano selecionado
    final months = getAllMonths();
    final partsSel = monthName.split('/');
    final String selMonthName = partsSel.isNotEmpty ? partsSel[0] : monthName;
    final int selYear = partsSel.length == 2
        ? int.tryParse(partsSel[1]) ?? DateTime.now().year
        : DateTime.now().year;
    DateTime currentMonthStart;
    DateTime currentMonthEnd;
    DateTime previousMonthStart;
    DateTime previousMonthEnd;

    String normalizeMonthNameLocal(String name) {
      final map = {
        'jan': 'Janeiro',
        'fev': 'Fevereiro',
        'mar': 'Março',
        'abr': 'Abril',
        'mai': 'Maio',
        'jun': 'Junho',
        'jul': 'Julho',
        'ago': 'Agosto',
        'set': 'Setembro',
        'out': 'Outubro',
        'nov': 'Novembro',
        'dez': 'Dezembro',
      };
      final lower = name.trim().toLowerCase();
      for (final m in months) {
        if (m.toLowerCase() == lower) return m;
      }
      return map[lower] ?? name;
    }

    final String selMonthNameNorm = normalizeMonthNameLocal(selMonthName);
    final selectedIndex = months.indexOf(selMonthNameNorm);
    final int selMonth =
        selectedIndex >= 0 ? selectedIndex + 1 : DateTime.now().month;
    currentMonthStart = DateTime(selYear, selMonth, 1);
    final daysInSelected = DateTime(selYear, selMonth + 1, 0).day;
    // Detectar se o mês selecionado já foi finalizado (fechado)
    final DateTime now = DateTime.now();
    final bool isMonthClosed =
        (selYear < now.year) || (selYear == now.year && selMonth < now.month);
    final bool isCurrentOrFuture = !isMonthClosed;

    final int currentEndDay =
        isCurrentOrFuture ? now.day.clamp(1, daysInSelected) : daysInSelected;
    currentMonthEnd = DateTime(selYear, selMonth, currentEndDay, 23, 59, 59);

    final prevMonth = selMonth == 1 ? 12 : selMonth - 1;
    final prevYear = selMonth == 1 ? selYear - 1 : selYear;
    previousMonthStart = DateTime(prevYear, prevMonth, 1);
    final daysInPrev = DateTime(prevYear, prevMonth + 1, 0).day;
    final int prevEndDay =
        isCurrentOrFuture ? (now.day.clamp(1, daysInPrev)) : daysInPrev;
    previousMonthEnd = DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);

    // Calcular a comparação com base na data efetiva (fim do período atual)
    final effectiveCurrentDate = currentMonthEnd;
    final comparison =
        PercentageCalculationService.calculateCategoryExpenseComparison(
      transactionController.transaction,
      categoryId,
      effectiveCurrentDate,
    );

    // Calcular valores em R$ para comparação usando as janelas definidas
    final currentValue =
        PercentageCalculationService.getCategoryExpensesForPeriod(
            transactionController.transaction,
            categoryId,
            currentMonthStart,
            currentMonthEnd);

    final previousValue =
        PercentageCalculationService.getCategoryExpensesForPeriod(
            transactionController.transaction,
            categoryId,
            previousMonthStart,
            previousMonthEnd);

    if (!comparison.hasData) {
      // Se o serviço não trouxe dados comparáveis, verificar cenário "Novo":
      final prevMonthFullEnd = DateTime(
          previousMonthEnd.year, previousMonthEnd.month + 1, 0, 23, 59, 59);
      final previousFullMonthValue =
          PercentageCalculationService.getCategoryExpensesForPeriod(
        transactionController.transaction,
        categoryId,
        previousMonthStart,
        prevMonthFullEnd,
      );

      if (currentValue > 0 && previousFullMonthValue == 0) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: DefaultColors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18.h,
                height: 18.h,
                decoration: BoxDecoration(
                  color: DefaultColors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Iconsax.more_circle,
                    size: 12.sp,
                    color: theme.cardColor,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'Novo',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: DefaultColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    }

    // Calcular a diferença absoluta em R$ (não mais usada diretamente no texto)
    // final absoluteDifference = (currentValue - previousValue).abs();

    // Criar texto explicativo baseado na comparação real dos valores
    String explanationText = '';

    // Removido o detalhamento de data específica do mês anterior do texto

    // Texto: mês fechado usa "No mês passado... e agora em {mês}..."; caso contrário, usa comparação por mesmo dia
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

    final DateTime now2 = DateTime.now();
    final bool isMonthClosed2 = (selYear < now2.year) ||
        (selYear == now2.year && selMonth < now2.month);

    if (comparison.type == PercentageType.newData) {
      explanationText =
          'Nova categoria adicionada: R\$ ${_formatCurrency(currentValue)} (sem registros no mês anterior)';
    } else if (comparison.type == PercentageType.neutral) {
      if (isMonthClosed2) {
        explanationText =
            'Você gastou o mesmo valor em ${monthNamePt(selMonth)} '
            'que no mês anterior: R\$ ${_formatCurrency(currentValue)}';
      } else {
        explanationText =
            'Mesmo valor neste mês: R\$ ${_formatCurrency(currentValue)} '
            '(igual ao mês passado, R\$ ${_formatCurrency(previousValue)})';
      }
    } else {
      if (isMonthClosed2) {
        final diff = (currentValue - previousValue).abs();
        final pct = previousValue == 0
            ? 100.0
            : ((currentValue - previousValue) / previousValue) * 100;
        final monthLabel = monthNamePt(selMonth);
        if (currentValue > previousValue) {
          explanationText =
              'Em $monthLabel, seus gastos foram de R\$ ${_formatCurrency(currentValue)}, '
              'um aumento de R\$ ${_formatCurrency(diff)} em relação ao mês anterior '
              '(+${pct.abs().toStringAsFixed(1)}%).';
        } else {
          explanationText =
              'Em $monthLabel, seus gastos foram de R\$ ${_formatCurrency(currentValue)}, '
              'uma redução de R\$ ${_formatCurrency(diff)} em relação ao mês anterior '
              '(-${pct.abs().toStringAsFixed(1)}%).';
        }
      } else {
        final bool isCurrentSelected =
            (selYear == now2.year && selMonth == now2.month);
        final diff = (currentValue - previousValue).abs();
        final pct2 = previousValue == 0
            ? 100.0
            : ((currentValue - previousValue) / previousValue) * 100;
        final monthLabel = monthNamePt(selMonth);

        if (isCurrentSelected) {
          final sameDayLabel =
              '${previousMonthEnd.day} de ${monthNamePt(previousMonthEnd.month)}';
          if (currentValue > previousValue) {
            explanationText =
                'No mesmo dia do mês passado ($sameDayLabel), você havia gasto R\$ ${_formatCurrency(previousValue)}. '
                'Agora, o valor é R\$ ${_formatCurrency(currentValue)}, um aumento de ${pct2.abs().toStringAsFixed(1)}% '
                '(R\$ ${_formatCurrency(diff)} a mais).';
          } else if (currentValue < previousValue) {
            explanationText =
                'No mesmo dia do mês passado ($sameDayLabel), você havia gasto R\$ ${_formatCurrency(previousValue)}. '
                'Agora, o valor é R\$ ${_formatCurrency(currentValue)}, uma redução de ${pct2.abs().toStringAsFixed(1)}% '
                '(R\$ ${_formatCurrency(diff)} a menos).';
          } else {
            explanationText =
                'No mesmo dia do mês passado ($sameDayLabel), você gastou R\$ ${_formatCurrency(previousValue)}, '
                'o mesmo valor que agora.';
          }
        } else {
          if (currentValue > previousValue) {
            explanationText =
                'Em $monthLabel, seus gastos foram de R\$ ${_formatCurrency(currentValue)}, '
                'um aumento de R\$ ${_formatCurrency(diff)} em relação ao mês anterior '
                '(+${pct2.abs().toStringAsFixed(1)}%).';
          } else if (currentValue < previousValue) {
            explanationText =
                'Em $monthLabel, seus gastos foram de R\$ ${_formatCurrency(currentValue)}, '
                'uma redução de R\$ ${_formatCurrency(diff)} em relação ao mês anterior '
                '(-${pct2.abs().toStringAsFixed(1)}%).';
          } else {
            explanationText =
                'Em $monthLabel, seus gastos permaneceram iguais ao mês anterior: R\$ ${_formatCurrency(currentValue)}.';
          }
        }
      }
    }

    late final Color circleColor2;
    // late final IconData dirIcon2; // não utilizado
    switch (comparison.type) {
      case PercentageType.positive:
        circleColor2 = DefaultColors.greenDark;
        break;
      case PercentageType.negative:
        circleColor2 = DefaultColors.redDark;
        break;
      case PercentageType.neutral:
        circleColor2 = DefaultColors.grey;
        break;
      case PercentageType.newData:
        circleColor2 = DefaultColors.grey;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 3.w, color: circleColor2),
          SizedBox(width: 6.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanationText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: circleColor2,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.r)),
                        ),
                        builder: (ctx) {
                          bool isLoading = false;
                          return StatefulBuilder(
                            builder: (ctx, setState) {
                              Future<void> handleWatch() async {
                                if (isLoading) return;
                                setState(() => isLoading = true);
                                final ok = await AdsRewardedPremium.show();
                                setState(() => isLoading = false);
                                if (ok) {
                                  Navigator.of(ctx).pop();
                                  Get.to(() => _SameDayComparePage(
                                        categoryId: categoryId,
                                        monthName: monthName,
                                        categoryName: (categoryName ?? ''),
                                        categoryIcon: categoryIcon,
                                        categoryColor: categoryColor,
                                      ));
                                }
                              }

                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    16.h,
                                    16.w,
                                    16.h +
                                        MediaQuery.of(ctx).viewInsets.bottom),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 16.h),
                                      AdsBanner(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 18.h),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 50.w,
                                              height: 50.h,
                                              decoration: BoxDecoration(
                                                color: (categoryColor ??
                                                    theme.primaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Icon(Iconsax.lock,
                                                  color: Colors.white,
                                                  size: 22.sp),
                                            ),
                                            SizedBox(width: 10.w),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Comparação mensal',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  '(mesmo dia)'.toLowerCase(),
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: theme.primaryColor
                                                        .withOpacity(.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Entenda como seus hábitos financeiros evoluem a cada mês. 🚀',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w800,
                                          color: theme.primaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Assista a um vídeo rápido e descubra como comparar seus gastos mês a mês para tomar decisões financeiras mais inteligentes',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: DefaultColors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 14.h),
                                      InkWell(
                                        onTap: isLoading ? null : handleWatch,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: (categoryColor ??
                                                theme.primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!isLoading)
                                                Image.asset(
                                                  'assets/images/video.png',
                                                  width: 18.w,
                                                  height: 18.h,
                                                  errorBuilder: (_, __, ___) =>
                                                      Icon(
                                                    Iconsax.play,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  ),
                                                )
                                              else
                                                SizedBox(
                                                  width: 18.w,
                                                  height: 18.h,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                isLoading
                                                    ? 'Carregando...'
                                                    : 'Assistir vídeo (30s)',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      AdsBanner(),
                                      SizedBox(height: 16.h),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _ModalBullet(
                                              text:
                                                  'Compare resultados - Veja como seus gastos evoluem',
                                              color: const Color(0xFF7C3AED)),
                                          SizedBox(height: 8.h),
                                          _ModalBullet(
                                              text:
                                                  'Reconheça padrões - Tome controle total do seu dinheiro',
                                              color: const Color(0xFF0EA5E9)),
                                          SizedBox(height: 8.h),
                                          _ModalBullet(
                                              text:
                                                  'Economize mais - Descubra onde pode reduzir custos',
                                              color: const Color(0xFF10B981)),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text(
                                          'Agora não',
                                          style: TextStyle(
                                            color: DefaultColors.grey,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.primaryColor.withOpacity(.3)),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver comparação completa',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: DefaultColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Iconsax.arrow_right_1,
                            color: DefaultColors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Remover os métodos duplicados e usar apenas o serviço
  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    return formatter.format(value);
  }
}

class _CategoryMonthComparePage extends StatelessWidget {
  const _CategoryMonthComparePage(
      {required this.categoryId,
      required this.categoryName,
      this.categoryColor,
      this.selectedMonthName});

  final int categoryId;
  final String categoryName;
  final Color? categoryColor;
  final String? selectedMonthName;

  String _monthLabel(DateTime date) {
    final months = getAllMonths();
    return '${months[date.month - 1]} / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Header/AppBar color fixed to grey20 as requested
    const Color headerColor = DefaultColors.grey20;

    // Determine selected month/year based on the provided label
    final DateTime now = DateTime.now();
    final String raw = (selectedMonthName ?? '').trim();
    final List<String> parts = raw.isNotEmpty ? raw.split('/') : <String>[];
    final String selMonthName = parts.isNotEmpty ? parts[0].trim() : raw;
    final int selYear = parts.length >= 2
        ? int.tryParse(parts[1].trim()) ?? now.year
        : now.year;
    final months = getAllMonths();
    int monthIdx = months.indexOf(selMonthName);
    if (monthIdx < 0) monthIdx = now.month - 1;

    // Build ranges relative to the selected month
    final DateTime currentStart = DateTime(selYear, monthIdx + 1, 1);
    final DateTime previousStart = DateTime(selYear, monthIdx, 1);
    final DateTime previousEnd = DateTime(selYear, monthIdx + 1, 0);
    final TransactionController txController =
        Get.find<TransactionController>();

    List<TransactionModel> forRange(DateTime start, DateTime end) {
      return txController.transaction.where((t) {
        if (t.type != TransactionType.despesa) return false;
        if (t.category != categoryId) return false;
        if (t.paymentDay == null) return false;
        final d = DateTime.parse(t.paymentDay!);
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList()
        ..sort((a, b) {
          if (a.paymentDay == null || b.paymentDay == null) return 0;
          return DateTime.parse(b.paymentDay!)
              .compareTo(DateTime.parse(a.paymentDay!));
        });
    }

    final List<TransactionModel> currentMonth = forRange(
      currentStart,
      // Use the end of the selected month, not the current month
      DateTime(selYear, monthIdx + 2, 0),
    );
    final List<TransactionModel> previousMonth = forRange(
      previousStart,
      previousEnd,
    );

    String formatDate(String? iso) {
      if (iso == null) return '';
      final d = DateTime.parse(iso);
      return DateFormat('dd').format(d); // ex.: 09
    }

    String formatValue(String v) {
      final n =
          double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
      final NumberFormat f =
          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      return f.format(n);
    }

    // old buildColumn removed in favor of styled monthCard UI

    double sum(List<TransactionModel> txs) {
      double s = 0;
      for (final t in txs) {
        s +=
            double.tryParse(t.value.replaceAll('.', '').replaceAll(',', '.')) ??
                0.0;
      }
      return s;
    }

    final double totalPrev = sum(previousMonth);
    final double totalCurr = sum(currentMonth);
    final double totalAll = totalPrev + totalCurr;
    final int totalCount = previousMonth.length + currentMonth.length;
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    Widget statCard(IconData icon, String label, String value) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 12.sp, color: DefaultColors.grey20),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget monthHeader(String title, double total) {
      return Container(
        decoration: BoxDecoration(
          color: DefaultColors.backgroundgreyDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text(title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                )),
            SizedBox(height: 4.h),
            Text(currency.format(total),
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                )),
          ],
        ),
      );
    }

    Widget monthItem(TransactionModel t) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.calendar_1, size: 14.h),
                    SizedBox(width: 8.w),
                    Text(
                      formatDate(t.paymentDay),
                      style: TextStyle(
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatValue(t.value),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(
              height: 1,
              color: DefaultColors.grey20.withOpacity(.3),
            ),
          ],
        ),
      );
    }

    Widget monthCard(String title, List<TransactionModel> txs, double total) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              monthHeader(title, total),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ...txs.map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: monthItem(t),
                        )),
                    if (txs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Sem transações'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                Expanded(
                    child:
                        statCard(Iconsax.box, 'Total Entregas', '$totalCount')),
                SizedBox(width: 12.w),
                Expanded(
                    child: statCard(Iconsax.activity, 'Total Geral',
                        currency.format(totalAll))),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                monthCard(_monthLabel(previousStart), previousMonth, totalPrev),
                const SizedBox(width: 16),
                monthCard(_monthLabel(currentStart), currentMonth, totalCurr),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            AdsBanner(),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }
}

class _SameDayComparePage extends StatelessWidget {
  final int categoryId;
  final String monthName;
  final String? categoryName;
  final String? categoryIcon;
  final Color? categoryColor;
  const _SameDayComparePage(
      {required this.categoryId,
      required this.monthName,
      this.categoryName,
      this.categoryIcon,
      this.categoryColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();
    final now = DateTime.now();
    final parts = monthName.split('/');
    String selMonth = parts.isNotEmpty ? parts[0] : monthName;
    int selYear =
        parts.length == 2 ? int.tryParse(parts[1]) ?? now.year : now.year;
    final months = getAllMonths();
    final map = {
      'jan': 'Janeiro',
      'fev': 'Fevereiro',
      'mar': 'Março',
      'abr': 'Abril',
      'mai': 'Maio',
      'jun': 'Junho',
      'jul': 'Julho',
      'ago': 'Agosto',
      'set': 'Setembro',
      'out': 'Outubro',
      'nov': 'Novembro',
      'dez': 'Dezembro',
    };
    final key = selMonth.trim().toLowerCase();
    if (map.containsKey(key)) selMonth = map[key]!;
    int monthIdx = months.indexOf(selMonth);
    if (monthIdx < 0) monthIdx = now.month - 1;
    final day = now.day; // mesmo dia

    // Gera lista somando do dia 1 até o mesmo dia para cada mês
    final List<Map<String, dynamic>> rowsAll = [];
    for (int i = 0; i < 12; i++) {
      final m = monthIdx + 1 - i;
      final y = selYear - ((m <= 0) ? ((-m) ~/ 12) + 1 : 0);
      final normM = ((m - 1) % 12) + 1;
      final int lastDay = DateTime(y, normM + 1, 0).day;
      final int selDay = day.clamp(1, lastDay);
      final DateTime start = DateTime(y, normM, 1);
      final DateTime end = DateTime(y, normM, selDay, 23, 59, 59);
      final double total = controller.transaction.where((t) {
        if (t.paymentDay == null) return false;
        if (t.type != TransactionType.despesa) return false;
        if (t.category != categoryId) return false;
        final d = DateTime.parse(t.paymentDay!);
        return !d.isBefore(start) && !d.isAfter(end);
      }).fold<double>(
          0.0,
          (s, t) =>
              s +
              double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
      rowsAll.add({
        'label':
            '1–${selDay.toString().padLeft(2, '0')} de ${months[normM - 1]} de $y',
        'value': total,
        'date': end,
      });
    }

    // Manter somente os meses do ano atual
    final List<Map<String, dynamic>> rows =
        rowsAll.where((e) => (e['date'] as DateTime).year == now.year).toList();

    // Calcula variações em relação ao mês seguinte na lista (comparação mês a mês)
    for (int i = 0; i < rows.length - 1; i++) {
      final cur = rows[i]['value'] as double;
      final prev = rows[i + 1]['value'] as double;
      rows[i]['diff'] = cur - prev;
      rows[i]['pct'] =
          prev == 0 ? (cur > 0 ? 100.0 : 0.0) : ((cur - prev) / prev) * 100.0;
    }

    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final String categoryTitle = (categoryName ?? '');
    final String? categoryIconPath = categoryIcon;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Comparação por dia',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (categoryColor ?? theme.primaryColor),
                    (categoryColor ?? theme.primaryColor).withOpacity(0.80),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: (categoryIconPath != null &&
                              categoryIconPath.isNotEmpty)
                          ? Image.asset(categoryIconPath,
                              width: 28.w, height: 28.h)
                          : Icon(Iconsax.category,
                              size: 20.sp, color: theme.primaryColor),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryTitle.isEmpty ? 'Categoria' : categoryTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Acompanhe seus gastos mensais',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            AdsBanner(),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: rows.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final r = rows[i];
                  final double v = r['value'] as double;
                  final double? pct = r['pct'] as double?;
                  final double? diff = r['diff'] as double?;
                  Color c;
                  IconData icon;
                  String delta;
                  if (pct == null || diff == null) {
                    c = DefaultColors.grey;
                    icon = Iconsax.more_circle;
                    delta = '0,0%';
                  } else if (diff > 0) {
                    c = DefaultColors.redDark;
                    icon = Iconsax.arrow_circle_up;
                    delta = '+${pct.abs().toStringAsFixed(1)}%';
                  } else if (diff < 0) {
                    c = DefaultColors.greenDark;
                    icon = Iconsax.arrow_circle_down;
                    delta = '-${pct.abs().toStringAsFixed(1)}%';
                  } else {
                    c = DefaultColors.grey;
                    icon = Iconsax.more_circle;
                    delta = '0,0%';
                  }
                  final String diffValueText = diff == null
                      ? currency.format(0)
                      : '${diff > 0 ? '+' : diff < 0 ? '-' : ''}${currency.format((diff).abs())}';

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border(
                        left: BorderSide(
                          color: theme.primaryColor.withOpacity(0.7),
                          width: 3,
                        ),
                      ),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['label'] as String,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: c.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 12.sp, color: c),
                                    SizedBox(width: 6.w),
                                    Text(
                                      delta,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: c,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '($diffValueText)',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: c,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(v),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalBullet extends StatelessWidget {
  final String text;
  final Color color;
  const _ModalBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = text.split(' - ');
    final String title = parts.isNotEmpty ? parts.first : text;
    final String desc = parts.length > 1 ? parts.sublist(1).join(' - ') : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                if (desc.isNotEmpty)
                  TextSpan(
                    text: ' - $desc',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: DefaultColors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// (Removido) _buildCollapsedComparisonPercent e _buildDeltaChip não são mais usados.

// _BudgetDonut removido por não ser utilizado
