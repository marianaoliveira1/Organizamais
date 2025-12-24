import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../routes/route.dart';
import '../../services/analytics_service.dart';

class OnboardingFixedSuccessPage extends StatefulWidget {
  const OnboardingFixedSuccessPage({super.key});

  @override
  State<OnboardingFixedSuccessPage> createState() =>
      _OnboardingFixedSuccessPageState();
}

class _OnboardingFixedSuccessPageState
    extends State<OnboardingFixedSuccessPage> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView('onboarding_fixed_success_page');
  }

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
              Image.asset('assets/icon/premio.png', width: 70.w, height: 70.h),
              SizedBox(height: 32.h),
              Text(
                'Controle nas suas mãos!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Cartões e contas fixas cadastrados. Agora o Organiza+ cuida dos lembretes, relatórios e análises pra você focar no que importa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              _CelebrationRow(
                icon: Iconsax.activity5,
                title: 'Rotina automatizada',
                subtitle:
                    'Alertas de faturas, parcelas e contas fixas chegando no período certo.',
              ),
              SizedBox(height: 12.h),
              _CelebrationRow(
                icon: Iconsax.chart_1,
                title: 'Insights mensais',
                subtitle:
                    'Acompanhe a evolução dos gastos com relatórios claros e ações sugeridas.',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  _analyticsService.logOnboardingCompleted();
                  AuthController.instance.isOnboarding = false;
                  Get.offAllNamed(Routes.HOME);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Ir para o app 🚀',
                  style: TextStyle(
                    color: theme.cardColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebrationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CelebrationRow({
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
          Icon(icon, color: DefaultColors.green, size: 22.sp),
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
