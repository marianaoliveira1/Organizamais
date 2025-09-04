import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../initial/pages/fixed_accotuns_page.dart';

class OnboardingCardSuccessPage extends StatelessWidget {
  const OnboardingCardSuccessPage({super.key});

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
              '🎯 Cartão adicionado com sucesso! Seu dinheiro já tá mais organizado que fila de banco em segunda-feira.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '💡 Agora, que tal uma conta fixa? Para aquelas despesas que são tão certas quanto chorar em filme da Disney! 🥲',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => Get.to(
                () => const AddFixedAccountsFormPage(fromOnboarding: true),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DefaultColors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Criar minha conta fixa! 🛡️',
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
