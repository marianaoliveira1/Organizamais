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
                              children: [
                                Builder(builder: (context) {
                                  final double pctExpenses = totalValue > 0
                                      ? (valor / totalValue * 100)
                                      : 0.0;
                                  return Text(
                                    '${pctExpenses.toStringAsFixed(0)}% das despesas',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: DefaultColors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
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

            // Lista de transações da categoria expandida
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
                      _buildCategoryMonthComparison(categoryId, theme),
                      SizedBox(
                        height: 10.h,
                      ),

                      _buildExpenseOverIncomeLine(categoryId, theme),
                      SizedBox(height: 6.h),

                      AdsBanner(),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        "Transações recentes (${categoryTransactions.length})",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: DefaultColors.grey20,
                        ),
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

  Widget _buildCategoryMonthComparison(int categoryId, ThemeData theme) {
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

    final selectedIndex = months.indexOf(selMonthName);
    final int selMonth =
        selectedIndex >= 0 ? selectedIndex + 1 : DateTime.now().month;
    currentMonthStart = DateTime(selYear, selMonth, 1);
    final daysInSelected = DateTime(selYear, selMonth + 1, 0).day;
    // Detectar se o mês selecionado já foi finalizado (fechado)
    final DateTime now = DateTime.now();
    final bool isMonthClosed = DateTime(selYear, selMonth + 1, 1)
        .isBefore(DateTime(now.year, now.month, 1));
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

    // Calcular a diferença absoluta em R$
    final absoluteDifference = (currentValue - previousValue).abs();

    // Criar texto explicativo baseado na comparação real dos valores
    String explanationText = '';

    String _formatPreviousMonthDate() {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1, now.day);

      final months = [
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

      return '${now.day} de ${months[previousMonth.month - 1]}';
    }

    // Texto: mês fechado usa "No mês passado... e agora em {mês}..."; caso contrário, usa comparação por mesmo dia
    String _monthNamePt(int m) {
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
    final bool isMonthClosed2 = DateTime(selYear, selMonth + 1, 1)
        .isBefore(DateTime(now2.year, now2.month, 1));

    if (comparison.type == PercentageType.newData) {
      explanationText =
          'Nova categoria: R\$ ${_formatCurrency(currentValue)} (sem dados no mês passado)';
    } else if (comparison.type == PercentageType.neutral) {
      if (isMonthClosed2) {
        explanationText =
            'Você gastou o mesmo valor em ${_monthNamePt(selMonth)} '
            'que no mês anterior: R\$ ${_formatCurrency(currentValue)}';
      } else {
        explanationText =
            'Mesmo valor: R\$ ${_formatCurrency(currentValue)} (igual ao mês passado, R\$ ${_formatCurrency(previousValue)})';
      }
    } else {
      if (isMonthClosed2) {
        final diff = (currentValue - previousValue).abs();
        final pct = previousValue == 0
            ? 100.0
            : ((currentValue - previousValue) / previousValue) * 100;
        final monthLabel = _monthNamePt(selMonth);
        if (currentValue > previousValue) {
          explanationText =
              'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
              'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
              'um gasto maior de R\$ ${_formatCurrency(diff)} (+${pct.abs().toStringAsFixed(1)}%).';
        } else {
          explanationText =
              'No mês passado você gastou R\$ ${_formatCurrency(previousValue)}, '
              'e agora em $monthLabel gastou R\$ ${_formatCurrency(currentValue)}, '
              'um gasto menor de R\$ ${_formatCurrency(diff)} (-${pct.abs().toStringAsFixed(1)}%).';
        }
      } else {
        if (currentValue < previousValue) {
          explanationText =
              'Gasto menor: -${comparison.percentage.toStringAsFixed(1)}% (R\$ ${_formatCurrency(absoluteDifference)}) em relação ao mesmo dia do mês passado (${_formatPreviousMonthDate()}). Antes: R\$ ${_formatCurrency(previousValue)}, agora: R\$ ${_formatCurrency(currentValue)}';
        } else if (currentValue > previousValue) {
          explanationText =
              'Gasto maior: +${comparison.percentage.toStringAsFixed(1)}% (R\$ ${_formatCurrency(absoluteDifference)}) em relação ao mesmo dia do mês passado (${_formatPreviousMonthDate()}). Antes: R\$ ${_formatCurrency(previousValue)}, agora: R\$ ${_formatCurrency(currentValue)}';
        } else {
          explanationText =
              'Mesmo valor: R\$ ${_formatCurrency(currentValue)} em comparação ao mês passado (${_formatPreviousMonthDate()})';
        }
      }
    }

    late final Color circleColor2;
    late final IconData dirIcon2;
    switch (comparison.type) {
      case PercentageType.positive:
        circleColor2 = DefaultColors.greenDark;
        dirIcon2 = Iconsax.arrow_circle_down;
        break;
      case PercentageType.negative:
        circleColor2 = DefaultColors.redDark;
        dirIcon2 = Iconsax.arrow_circle_up;
        break;
      case PercentageType.neutral:
        circleColor2 = DefaultColors.grey;
        dirIcon2 = Iconsax.more_circle;
        break;
      case PercentageType.newData:
        circleColor2 = DefaultColors.grey;
        dirIcon2 = Iconsax.star_1;
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
            child: Text(
              explanationText,
              style: TextStyle(
                fontSize: 12.sp,
                color: circleColor2,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  // Remover os métodos duplicados e usar apenas o serviço
  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}

// (Removido) _buildCollapsedComparisonPercent e _buildDeltaChip não são mais usados.

class _BudgetDonut extends StatelessWidget {
  final double percent; // 0..100
  final Color color;

  const _BudgetDonut({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double clamped = percent.clamp(0, 100);
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.primaryColor.withOpacity(.15)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (clamped / 100.0),
            strokeWidth: 6.w,
            color: color,
            backgroundColor: theme.primaryColor.withOpacity(.08),
          ),
          Text(
            '${clamped.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
