import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';
import 'package:organizamais/page/initial/widget/fixed_accounts.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/fixed_accounts_controller.dart';
import 'widget/goal_progress_card.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20.w,
                horizontal: 20.h,
              ),
              child: Column(
                children: [
                  FinanceSummaryWidget(),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
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
                            IconButton(
                              onPressed: () {
                                Get.toNamed("/fixed-accounts");
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        FixedAccounts(
                          fixedAccounts: Get.find<FixedAccountsController>().fixedAccounts,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 20.h,
                  ),
                  GoalProgressCard(
                    title: "Nubank",
                    subtitle: "vence dia 15",
                    progress: 0.55, // 55%
                    startDate: "0",
                    endDate: "4000",
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
