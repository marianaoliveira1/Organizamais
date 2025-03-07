// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/pages/cards/cards_page.dart';
import 'package:organizamais/pages/profile/pages/fixed_accounts_page.dart';
import 'package:organizamais/utils/color.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    void _showLogoutConfirmation() {
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deseja sair?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Não',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: DefaultColors.grey20,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      authController.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Sim',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final user = authController.firebaseUser.value;
                return _buildInfoItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Nome',
                  value: user?.displayName ?? "Usuário",
                );
              }),
              _buildDivider(),

              // Email do usuário
              Obx(() {
                final user = authController.firebaseUser.value;
                return _buildInfoItem(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user?.email ?? "Email não disponível",
                );
              }),

              SizedBox(height: 30.h),

              // Seção de Configurações
              _buildSectionTitle('Configurações'),
              SizedBox(height: 15.h),

              // Meus Cartões
              _buildSettingItem(
                context: context,
                icon: Iconsax.card,
                title: 'Meus Cartões',
                onTap: () {
                  Get.to(() => CardsPage());
                },
              ),
              _buildDivider(),

              // Minhas Contas Fixas
              _buildSettingItem(
                context: context,
                icon: Iconsax.receipt_1,
                title: 'Minhas Contas Fixas',
                onTap: () {
                  Get.to(() => FixedAccountsPage());
                },
              ),

              SizedBox(height: 30.h),

              // Botão Sair
              _buildLogoutButton(context, _showLogoutConfirmation),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: DefaultColors.grey20,
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          // const Spacer(),
          // Icon(
          //   Icons.arrow_forward_ios,
          //   size: 16.sp,
          //   color: Colors.grey.shade400,
          // ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 15.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey.shade400,
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

  Widget _buildLogoutButton(BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.logout,
              color: Colors.red.shade400,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Sair',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
