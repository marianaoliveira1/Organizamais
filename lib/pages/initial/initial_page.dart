import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/pages/profile/profile_page.dart';

import '../../controller/auth_controller.dart';
import '../../controller/fixed_accounts_controller.dart';

import '../cards/cards_page.dart';
import '../profile/pages/fixed_accounts_page.dart';
import 'widget/credit_card_selection.dart';

import 'widget/finance_summary.dart';

import 'widget/logout_button.dart';
import 'widget/logout_confirmation_dialog.dart';
import 'widget/setting_item.dart';
import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Obx(() {
              //   final user = authController.firebaseUser.value;
              //   return InfoItem(
              //     value: user?.email ?? "Email não disponível",
              //   );
              // }),
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
              Spacer(),
              LogoutButton(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutConfirmationDialog(
                    authController: authController,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
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
                    FinanceSummaryWidget(),
                    DefaultWidgetFixedAccounts(),
                    CreditCardSection(),
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

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }
}
