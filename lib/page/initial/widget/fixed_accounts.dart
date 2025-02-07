import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/utils/color.dart';

class FixedAccounts extends GetView<FixedAccountsController> {
  const FixedAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller using GetX dependency injection
    Get.put(FixedAccountsController());

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
              GestureDetector(
                onTap: () => controller.showBottomSheet(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          GetX<FixedAccountsController>(
            builder: (controller) {
              return Column(
                children: controller.fixedAccounts.map((expense) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
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
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
