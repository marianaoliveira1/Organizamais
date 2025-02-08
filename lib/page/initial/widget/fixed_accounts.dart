import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/page/transaction_page.dart/pages/%20%20category.dart';
import 'package:organizamais/utils/color.dart';

class FixedAccounts extends StatelessWidget {
  final List<FixedAccount> fixedAccounts;

  const FixedAccounts({
    super.key,
    required this.fixedAccounts,
  });

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
          Obx(() {
            if (fixedAccounts.isEmpty) {
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
              itemCount: fixedAccounts.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final fixedAccount = fixedAccounts[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          categories.firstWhere((element) => element['id'] == fixedAccount.category)['icon'],
                          width: 30.w,
                          height: 30.h,
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fixedAccount.title,
                              style: TextStyle(
                                color: DefaultColors.black,
                                fontSize: 14.sp,
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
                          "R\$ ${fixedAccount.value}",
                          style: TextStyle(
                            color: DefaultColors.black,
                            fontSize: 14.sp,
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
