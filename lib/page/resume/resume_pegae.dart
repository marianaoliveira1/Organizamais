import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/utils/color.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          children: [
            Obx(() {
              if (transactionController.transaction.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhuma transação encontrada",
                    style: TextStyle(
                      color: DefaultColors.primary,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(
                  height: 14.h,
                ),
                itemCount: transactionController.transaction.length,
                itemBuilder: (context, index) {
                  final transaction = transactionController.transaction[index];
                  return Column(
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          color: DefaultColors.primary,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        transaction.value.toString(),
                        style: TextStyle(
                          color: DefaultColors.primary,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        transaction.paymentDay.toString(),
                        style: TextStyle(
                          color: DefaultColors.primary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  );
                },
              );
            })
          ],
        ),
      ),
    );
  }
}
