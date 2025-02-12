import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../../utils/color.dart';
import '../transaction_page.dart/pages/  category.dart';

class ResumePage extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: DefaultColors.background,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 16.w,
              ),
              decoration: BoxDecoration(
                color: DefaultColors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fluxo de caixa",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  TransactionCard(transactions: Get.find<TransactionController>().transaction),
                ],
              ),
            ),
          ],
        ));
  }
}

class TransactionCard extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (transactions.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  "Nenhuma conta cadastrada",
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              );
            }
            return ListView.separated(
              itemCount: transactions.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(
                height: 14.h,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          categories_expenses.firstWhere((element) => element['id'] == transaction.category)['icon'],
                          width: 24.w,
                          height: 24.h,
                        ),
                        SizedBox(width: 20.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: TextStyle(
                                color: DefaultColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              "Dia ${transaction.paymentDay} de cada mês",
                              style: TextStyle(
                                color: DefaultColors.grey,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "R\$ ${transaction.value}",
                          style: TextStyle(
                            color: DefaultColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "${transaction.paymentType}",
                          style: TextStyle(
                            color: DefaultColors.grey,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          })
        ],
      ),
    );
  }
}
