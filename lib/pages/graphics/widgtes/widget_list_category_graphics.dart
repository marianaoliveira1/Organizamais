// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final String monthName;
  final RxnInt selectedCategoryId;
  final ThemeData theme;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

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
        var percentual = (valor / totalValue * 100);
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
                  decoration: BoxDecoration(
                    color: selectedCategoryId.value == categoryId
                        ? categoryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
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
                            SizedBox(
                              width: 120.w,
                              child: Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Text(
                              "${percentual.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                            // Porcentagem de comparação com mês anterior
                            _buildMonthComparisonPercentage(
                              categoryId,
                              theme,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(valor),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            selectedCategoryId.value == categoryId
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: DefaultColors.grey,
                            size: 16.h,
                          ),
                        ],
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
                        height: 4.h,
                      ),
                      _buildCategoryMonthComparison(categoryId, theme),
                      Text(
                        "Detalhes das Transações",
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
                                          transaction.title,
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
        final int currentYear = DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;

          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];
          return transactionMonthName == monthName &&
              transactionDate.year == currentYear;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  Widget _buildMonthComparisonPercentage(int categoryId, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Calcular a comparação com o mês anterior
    final comparison =
        PercentageCalculationService.calculateCategoryExpenseComparison(
      transactionController.transaction,
      categoryId,
      DateTime.now(),
    );

    // Debug: verificar por que não está funcionando
    if (!comparison.hasData) {
      // Tentar calcular manualmente para debug
      final currentValue =
          PercentageCalculationService.getCategoryExpensesForPeriod(
              transactionController.transaction,
              categoryId,
              DateTime(DateTime.now().year, DateTime.now().month, 1),
              DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day, 23, 59, 59));

      // Se há dados atuais, mostrar como "Novo"
      if (currentValue > 0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fiber_new,
              size: 12.h,
              color: DefaultColors.grey,
            ),
            SizedBox(width: 4.w),
            Text(
              'Novo',
              style: TextStyle(
                fontSize: 9.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }

      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          comparison.icon,
          size: 12.h,
          color: comparison.color,
        ),
        SizedBox(width: 4.w),
        Text(
          comparison.displayText,
          style: TextStyle(
            fontSize: 9.sp,
            color: comparison.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryMonthComparison(int categoryId, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    // Calcular a comparação com o mês anterior
    final comparison =
        PercentageCalculationService.calculateCategoryExpenseComparison(
      transactionController.transaction,
      categoryId,
      DateTime.now(),
    );

    if (!comparison.hasData) {
      return const SizedBox.shrink();
    }

    // Calcular valores em R$ para comparação usando o serviço
    final currentValue =
        PercentageCalculationService.getCategoryExpensesForPeriod(
            transactionController.transaction,
            categoryId,
            DateTime(DateTime.now().year, DateTime.now().month, 1),
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, 23, 59, 59));

    final previousMonth =
        DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
    final previousYear = DateTime.now().month == 1
        ? DateTime.now().year - 1
        : DateTime.now().year;
    final daysInPreviousMonth =
        DateTime(previousYear, previousMonth + 1, 0).day;
    final previousMonthDay = DateTime.now().day > daysInPreviousMonth
        ? daysInPreviousMonth
        : DateTime.now().day;

    final previousValue =
        PercentageCalculationService.getCategoryExpensesForPeriod(
            transactionController.transaction,
            categoryId,
            DateTime(previousYear, previousMonth, 1),
            DateTime(
                previousYear, previousMonth, previousMonthDay, 23, 59, 59));

    // Calcular a diferença absoluta em R$
    final absoluteDifference = (currentValue - previousValue).abs();

    // Criar texto explicativo baseado no tipo de comparação
    String explanationText = '';
    switch (comparison.type) {
      case PercentageType.positive:
        explanationText =
            'Diminuiu ${comparison.percentage.toStringAsFixed(1)}% (R\$ ${_formatCurrency(absoluteDifference)}) em comparação ao mesmo dia do mês anterior (R\$ ${_formatCurrency(previousValue)}), hoje R\$ ${_formatCurrency(currentValue)}';
        break;
      case PercentageType.negative:
        explanationText =
            'Aumentou ${comparison.percentage.toStringAsFixed(1)}% (R\$ ${_formatCurrency(absoluteDifference)}) em comparação ao mesmo dia do mês anterior (R\$ ${_formatCurrency(previousValue)}), hoje R\$ ${_formatCurrency(currentValue)}';
        break;
      case PercentageType.neutral:
        explanationText =
            'Manteve o mesmo valor: R\$ ${_formatCurrency(currentValue)}';
        break;
      case PercentageType.newData:
        explanationText =
            'Nova categoria - R\$ ${_formatCurrency(currentValue)} (não há dados do mês anterior)';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            comparison.icon,
            size: 14.h,
            color: comparison.color,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              explanationText,
              style: TextStyle(
                fontSize: 10.sp,
                color: comparison.color,
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
