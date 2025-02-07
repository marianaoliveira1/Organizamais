import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/utils/color.dart';

class FixedAccounts extends StatelessWidget {
  final String id;
  final String name;
  final String date;
  final String category;
  final String amount;
  final String paymentMethod;

  FixedAccounts({
    super.key,
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
  });

  final FixedAccountsController controller = Get.put(FixedAccountsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contas fixas",
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 12.sp,
                ),
              ),
              IconButton(
                onPressed: controller.showBottomSheet,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Obx(() {
            if (controller.fixedAccounts.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  "Nenhuma conta fixa cadastrada",
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.fixedAccounts.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final expense = controller.fixedAccounts[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.home, size: 30.h),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.name,
                              style: TextStyle(
                                color: DefaultColors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              expense.paymentMethod,
                              style: TextStyle(
                                color: DefaultColors.grey,
                                fontSize: 12.sp,
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
                          "R\$ ${expense.amount}",
                          style: TextStyle(
                            color: DefaultColors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          expense.date,
                          style: TextStyle(
                            color: DefaultColors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
