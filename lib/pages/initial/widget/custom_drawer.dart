import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/pages/initial/pages/economic_types_page.dart';

import '../../../controller/auth_controller.dart';
import '../../cards/cards_page.dart';
import '../../profile/pages/fixed_accounts_page.dart';
import '../../profile/profile_page.dart';
import '../../spending_goals/spending_goals_page.dart';
import 'logout_button.dart';
import 'logout_confirmation_dialog.dart';
import 'setting_item.dart';

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
            Text(
              "Organiza+",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
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
            // _buildDivider(),
            // SettingItem(
            //   icon: Iconsax.chart_2,
            //   title: 'Metas de Gasto',
            //   onTap: () => Get.to(() => SpendingGoalsPage()),
            // ),
            _buildDivider(),
            SettingItem(
              icon: Iconsax.lamp,
              title: 'Dicas',
              onTap: () => Get.to(() => const EconomicTipsPage()),
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
