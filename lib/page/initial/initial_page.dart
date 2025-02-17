import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';

import 'package:organizamais/utils/color.dart';

import '../../controller/fixed_accounts_controller.dart';

import 'widget/credit_card_selection.dart';
import 'widget/widghet_fixed_accoutns.dart';

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
                  CreditCardSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
