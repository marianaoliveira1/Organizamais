import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../controller/transaction_controller.dart';

import 'widget/credit_card_selection.dart';
import 'widget/custom_drawer.dart';
import 'widget/finance_summary.dart';

import 'widget/parcelamentos_card.dart';

import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    transactionController.transaction
        .where((t) => t.title.contains('Parcela'))
        .where((t) {
      if (t.paymentDay == null) return false;
      final date = DateTime.parse(t.paymentDay!);
      return date.month == currentMonth && date.year == currentYear;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.h,
                  ),
                  child: Column(
                    spacing: 20.h,
                    children: [
                      const FinanceSummaryWidget(),
                      const DefaultWidgetFixedAccounts(),
                      ParcelamentosCard(),
                      CreditCardSection(),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
