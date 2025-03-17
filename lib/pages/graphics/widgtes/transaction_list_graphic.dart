// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class TransactionListGraphic extends StatelessWidget {
  final RxnInt selectedCategoryId;
  final int categoryId;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;
  final ThemeData theme;
  final TransactionController transactionController;
  final RxString selectedMonth;
  final List<TransactionModel> Function(TransactionController, RxString) getFilteredTransactions;

  const TransactionListGraphic({
    super.key,
    required this.selectedCategoryId,
    required this.categoryId,
    required this.currencyFormatter,
    required this.dateFormatter,
    required this.theme,
    required this.transactionController,
    required this.selectedMonth,
    required this.getFilteredTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (selectedCategoryId.value != categoryId) {
        return const SizedBox();
      }

      var categoryTransactions = _getTransactionsByCategory();
      categoryTransactions.sort((a, b) {
        if (a.paymentDay == null || b.paymentDay == null) return 0;
        return DateTime.parse(b.paymentDay!).compareTo(DateTime.parse(a.paymentDay!));
      });

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.h,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalhes das Transações",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryTransactions.length,
              separatorBuilder: (context, index) => Divider(
                color: DefaultColors.grey20.withOpacity(
                  .5,
                ),
                height: 1,
              ),
              itemBuilder: (context, index) {
                var transaction = categoryTransactions[index];
                var transactionValue = double.parse(
                  transaction.value.replaceAll('.', '').replaceAll(',', '.'),
                );

                String formattedDate = transaction.paymentDay != null
                    ? dateFormatter.format(
                        DateTime.parse(transaction.paymentDay!),
                      )
                    : "Data não informada";

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140.w,
                            child: Text(
                              transaction.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(transactionValue),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          SizedBox(
                            width: 100.w,
                            child: Text(
                              transaction.paymentType!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    });
  }

  List<TransactionModel> _getTransactionsByCategory() {
    var filteredTransactions = getFilteredTransactions(transactionController, selectedMonth);
    return filteredTransactions.where((transaction) => transaction.category == categoryId).toList();
  }
}
