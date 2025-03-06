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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 20.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Iconsax.profile_circle,
                size: 50.sp,
                color: DefaultColors.grey20,
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() {
              final user = authController.firebaseUser.value;
              if (user == null) {
                return const Text("Usuário não encontrado", style: TextStyle(fontSize: 18));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Nome",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DefaultColors.grey20,
                    ),
                  ),
                  Text(
                    user.displayName ?? "Usuário",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DefaultColors.grey20,
                    ),
                  ),
                  Text(
                    user.email ?? "Email não disponível", // Email do usuário
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 30.h),
            _buildOptionButton(
              context,
              'Meus Cartões',
              Iconsax.card,
              () {
                // Navegar para a página de cartões
                Get.to(
                  () => CardsPage(),
                );
              },
            ),
            SizedBox(height: 15.h),
            _buildOptionButton(
              context,
              'Minhas Contas Fixas',
              Iconsax.receipt_1,
              () {
                Get.to(() => FixedAccountsPage());
              },
            ),
            Spacer(), // Empurra o botão de sair para o final da tela
            _buildLogoutButton(context, _showLogoutConfirmation),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            const Spacer(),
            Icon(
              Iconsax.arrow_right_3,
              color: DefaultColors.grey20,
              size: 20.sp,
            ),
          ],
        ),
      ),
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
