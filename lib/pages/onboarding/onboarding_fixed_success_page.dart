import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../../routes/route.dart';
import '../../controller/auth_controller.dart';

class OnboardingFixedSuccessPage extends StatelessWidget {
  const OnboardingFixedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tudo certo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sua configuração inicial está pronta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                AuthController.instance.isOnboarding = false;
                Get.offAllNamed(Routes.HOME);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DefaultColors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Tudo pronto',
                style: TextStyle(
                  color: theme.cardColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
