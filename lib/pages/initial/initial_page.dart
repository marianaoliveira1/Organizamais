import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../controller/transaction_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/goal_controller.dart';

import 'widget/credit_card_selection.dart';
import 'widget/custom_drawer.dart';
import 'widget/finance_summary.dart';

import 'widget/goals_card.dart';
import 'widget/parcelamentos_card.dart';

import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());
    final GoalController goalController = Get.put(GoalController());
    if (goalController.goalStream == null) {
      goalController.startGoalStream();
    }

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
        title: Obx(() {
          final auth = Get.find<AuthController>();
          final user = auth.firebaseUser.value;
          if (user == null) return const SizedBox.shrink();
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final firestoreName = snapshot.data?.data()?['name'] as String?;
              final effectiveName =
                  (firestoreName != null && firestoreName.trim().isNotEmpty)
                      ? firestoreName
                      : (user.displayName ?? '');
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oi,',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "$effectiveName 👋",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
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
                      const GoalsCard(),
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
