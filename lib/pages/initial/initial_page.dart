import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controller/auth_controller.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../controller/transaction_controller.dart';
import '../cards/cards_page.dart';
import '../profile/pages/fixed_accounts_page.dart';
import '../profile/profile_page.dart';
import 'widget/credit_card_selection.dart';
import 'widget/finance_summary.dart';
import 'widget/logout_button.dart';
import 'widget/logout_confirmation_dialog.dart';
import 'widget/parcelamentos_card.dart';
import 'widget/setting_item.dart';
import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);
    final TransactionController transactionController = Get.find<TransactionController>();
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    transactionController.transaction.where((t) => t.title.contains('Parcela')).where((t) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.h,
                ),
                child: Column(
                  spacing: 20.h,
                  children: [
                    const FinanceSummaryWidget(),
                    const DefaultWidgetFixedAccounts(),
                    CreditCardSection(),
                    ParcelamentosCard(),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20.h,
            ),
            SettingItem(
              icon: Iconsax.user,
              title: 'Perfil',
              onTap: () => Get.to(() => const ProfilePage()),
            ),
            _buildDivider(),
            SettingItem(
              icon: Iconsax.card,
              title: 'Meus Cartões',
              onTap: () => Get.to(() => const CardsPage()),
            ),
            _buildDivider(),
            SettingItem(
              icon: Iconsax.receipt_1,
              title: 'Minhas Contas Fixas',
              onTap: () => Get.to(() => const FixedAccountsPage()),
            ),
            const Spacer(),
            LogoutButton(
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutConfirmationDialog(
                        authController: authController,
                      )),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }
}
