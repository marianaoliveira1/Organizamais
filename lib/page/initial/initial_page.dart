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
                  subtitle: "vence em dia 15",
                  progress: 0.55, // 55%
                  startDate: "0",
                  endDate: "4000",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
