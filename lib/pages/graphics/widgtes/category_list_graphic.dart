// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

import 'transaction_list_graphic.dart';

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double totalValue;
  final RxnInt selectedCategoryId;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;
  final ThemeData theme;
  final TransactionController transactionController;
  final RxString selectedMonth;
  final List<TransactionModel> Function(TransactionController, RxString) getFilteredTransactions;

  const CategoryList({
    super.key,
    required this.data,
    required this.totalValue,
    required this.selectedCategoryId,
    required this.currencyFormatter,
    required this.dateFormatter,
    required this.theme,
    required this.transactionController,
    required this.selectedMonth,
    required this.getFilteredTransactions,
  });

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

        return Column(
          children: [
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
                  bottom: 10.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: selectedCategoryId.value == categoryId
                        ? (item['color'] as Color).withOpacity(
                            0.1,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item['icon'] as String,
                        width: 30.w,
                        height: 30.h,
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130.w,
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
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                              ),
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
                            selectedCategoryId.value == categoryId ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: DefaultColors.grey,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            TransactionListGraphic(
              selectedCategoryId: selectedCategoryId,
              categoryId: categoryId,
              currencyFormatter: currencyFormatter,
              dateFormatter: dateFormatter,
              theme: theme,
              transactionController: transactionController,
              selectedMonth: selectedMonth,
              getFilteredTransactions: getFilteredTransactions,
            ),
          ],
        );
      },
    );
  }
}
