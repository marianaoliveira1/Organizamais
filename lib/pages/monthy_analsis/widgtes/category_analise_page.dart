import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../graphics/graphics_page.dart';

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
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    List<TransactionModel> transactions =
        _getTransactionsByCategoryAndMonth(categoryId, monthName);

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo da categoria
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${percentual.toStringAsFixed(1)}% do total',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormatter.format(totalValue),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Lista de transações
                  Text(
                    'Transações em $monthName',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: DefaultColors.grey20,
                    ),
                  ),

                  if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Text(
                          "Nenhuma transação encontrada",
                          style: TextStyle(
                            fontSize: 14.sp,
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
                      // ignore: deprecated_member_use
                      color: DefaultColors.grey20.withOpacity(.5),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
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

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 180.w,
                                    child: Text(
                                      transaction.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Get.theme.primaryColor,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: DefaultColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(transactionValue),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Get.theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  transaction.paymentType ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: DefaultColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;
          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];
          return transactionMonthName == monthName;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }
}
