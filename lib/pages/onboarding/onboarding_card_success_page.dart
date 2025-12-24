import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../routes/route.dart';
import '../initial/pages/fixed_accotuns_page.dart';

class OnboardingCardSuccessPage extends StatelessWidget {
  const OnboardingCardSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.h),
              Image.asset(
                'assets/icon/verificar.png',
                width: 70.w,
                height: 70.h,
              ),
              SizedBox(height: 32.h),
              Text(
                'Cartão conectado! 🎯',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Vamos dar o próximo passo? Adicione suas contas fixas para ter uma visão completa do que está por vir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              _SuccessTip(
                icon: Iconsax.receipt_1,
                text:
                    'Monitore aluguel, assinaturas e despesas essenciais em um só lugar.',
              ),
              SizedBox(height: 12.h),
              _SuccessTip(
                icon: Iconsax.alarm,
                text:
                    'Receba alertas antes do vencimento para nunca mais esquecer.',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Get.to(
                  () => const AddFixedAccountsFormPage(fromOnboarding: true),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Adicionar conta fixa',
                  style: TextStyle(
                    color: theme.cardColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  AuthController.instance.isOnboarding = false;
                  Get.offAllNamed(Routes.HOME);
                },
                child: Text(
                  'Pular por agora',
                  style: TextStyle(
                    color: DefaultColors.grey20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SuccessTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: DefaultColors.green, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
