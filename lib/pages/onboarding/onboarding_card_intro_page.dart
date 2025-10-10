import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../../routes/route.dart';
import '../../controller/auth_controller.dart';
import '../initial/pages/add_card_page.dart';

class OnboardingCardIntroPage extends StatelessWidget {
  const OnboardingCardIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.primaryColor),
          onPressed: () {
            AuthController.instance.isOnboarding = false;
            Get.offAllNamed(Routes.HOME);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Adicione seu cartão e comece a enxergar pra onde seu dinheiro realmente vai — com clareza e sem esforço. 📊',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Seus gastos, todos organizados em um só lugar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 36.h),
            ElevatedButton(
              onPressed: () => Get.to(() =>
                  const AddCardPage(isEditing: false, fromOnboarding: true)),
              style: ElevatedButton.styleFrom(
                backgroundColor: DefaultColors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Adicionar cartão',
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
