import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/pages/initial/pages/contact_us_page.dart';

import '../../../controller/auth_controller.dart';
import '../../cards/cards_page.dart';
import '../../profile/pages/fixed_accounts_page.dart';
import '../../profile/profile_page.dart';
import '../pages/monthly_expenses.dart';
import 'logout_button.dart';
import 'logout_confirmation_dialog.dart';
import 'setting_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final AuthController authController = Get.find<AuthController>();

    // Proporções responsivas
    final double drawerWidth = size.width * 0.65;
    final double horizontalPadding = size.width * 0.05;
    final double verticalPadding = size.height * 0.03;
    final double titleFont = size.width * 0.06;
    final double spacing = size.height * 0.02;

    return Drawer(
      width: drawerWidth, // ← ESSENCIAL PARA RESPONSIVIDADE
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing * 1.5),

              /// TÍTULO
              Text(
                "Organiza+",
                style: TextStyle(
                  fontSize: titleFont,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),

              SizedBox(height: spacing * 2),

              /// Itens principais
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
              _buildDivider(),

              SettingItem(
                icon: Iconsax.money,
                title: 'Organize seu orçamento mensal',
                onTap: () => Get.to(() => const MonthlyExpenses()),
              ),
              _buildDivider(),

              SettingItem(
                icon: Iconsax.message,
                title: 'Fale conosco',
                onTap: () => Get.to(() => const ContactUsPage()),
              ),

              const Spacer(),

              /// Logout
              LogoutButton(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LogoutConfirmationDialog(
                      authController: authController,
                    ),
                  );
                },
              ),

              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300,
      thickness: 1,
      height: 18,
    );
  }
}
