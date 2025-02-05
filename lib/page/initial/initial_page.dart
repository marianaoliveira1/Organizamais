import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';
import 'package:organizamais/utils/color.dart';

import 'widget/fixed_accounts.dart';
import 'widget/goal_progress_card.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: ListView(
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
                FixedAccounts(),
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
                            "Parcelas do cartão",
                            style: TextStyle(
                              color: DefaultColors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                          Icon(Icons.add),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 30.h,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Brusinha",
                                    style: TextStyle(
                                      color: DefaultColors.black,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    "Pix",
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
                              Row(
                                children: [
                                  Text(
                                    "2/3",
                                    style: TextStyle(
                                      color: DefaultColors.black,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "R\$ 40,00",
                                    style: TextStyle(
                                      color: DefaultColors.black,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "15 jan 2025",
                                style: TextStyle(
                                  color: DefaultColors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
