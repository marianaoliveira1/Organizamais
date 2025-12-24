import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../routes/route.dart';
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
          icon: Icon(Iconsax.close_circle, color: theme.primaryColor),
          onPressed: () {
            AuthController.instance.isOnboarding = false;
            Get.offAllNamed(Routes.HOME);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/icon-bank/icone-generico.png',
                width: 70.w,
                height: 70.h,
              ),
              SizedBox(height: 28.h),
              Text(
                'Conecte seus cartões',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Organize limites, faturas e parcelas automaticamente em um painel visual.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              _CardFeature(
                icon: Iconsax.trend_up,
                title: 'Uso inteligente',
                subtitle:
                    'Veja quanto do limite já foi comprometido e onde gastar melhor.',
              ),
              SizedBox(height: 12.h),
              _CardFeature(
                icon: Iconsax.calendar,
                title: 'Datas sem surpresas',
                subtitle:
                    'Alertas de fechamento, vencimento e parcelas futuras.',
              ),
              SizedBox(height: 12.h),
              _CardFeature(
                icon: Iconsax.receipt_disscount,
                title: 'Parcelas organizadas',
                subtitle: 'Visualize cada compra parcelada mês a mês.',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Get.to(
                  () =>
                      const AddCardPage(isEditing: false, fromOnboarding: true),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Adicionar cartão agora',
                  style: TextStyle(
                    color: theme.cardColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.HOME),
                child: Text(
                  'Fazer isso depois',
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

class _CardFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CardFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              color: DefaultColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: DefaultColors.green, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: DefaultColors.grey20,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
