import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/utils/color.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

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
          ],
        ),
      ),
    );
  }
}
