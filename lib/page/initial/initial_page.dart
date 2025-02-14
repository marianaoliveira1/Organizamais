import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';
import 'package:organizamais/page/initial/widget/fixed_accounts.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/fixed_accounts_controller.dart';

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
                spacing: 20.h,
                children: [
                  FinanceSummaryWidget(),
                  DefaultWidgetFixedAccounts(),
                  Container(
                    decoration: BoxDecoration(
                      color: DefaultColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Meus Cartões",
                          style: TextStyle(
                            color: DefaultColors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Get.toNamed("/credit-card");
                            },
                            icon: Icon(Icons.add))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
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
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/fixed-accounts");
                },
                child: Icon(
                  Icons.add,
                  size: 16.sp,
                  color: DefaultColors.grey,
                ),
              ),
            ],
          ),
          FixedAccounts(
            fixedAccounts: Get.find<FixedAccountsController>().fixedAccounts,
          ),
        ],
      ),
    );
  }
}
