import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../routes/route.dart';
import '../../services/analytics_service.dart';

class OnboardingWelcomePage extends StatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView('onboarding_welcome_page');
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
              Image.asset(
                'assets/icon/icon.png',
                width: 70.w,
                height: 70.h,
              ),
              SizedBox(height: 32.h),
              Text(
                'Bem-vindo ao Organiza+',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Um painel completo para organizar gastos, metas e cartões em um só lugar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 28.h),
              _FeatureTile(
                icon: Iconsax.activity,
                title: 'Comparações inteligentes',
                subtitle:
                    'Veja saldo, receitas, despesas e categorias lado a lado para entender cada variação do mês.',
              ),
              SizedBox(height: 12.h),
              _FeatureTile(
                icon: Iconsax.card,
                title: 'Cartões e parcelamentos',
                subtitle:
                    'Limites, faturas e parcelas futuras em um único painel, com alertas antes do vencimento.',
              ),
              SizedBox(height: 12.h),
              _FeatureTile(
                icon: Iconsax.chart_2,
                title: 'Dashboards e gráficos',
                subtitle:
                    'Diversos gráficos e relatórios mostram tendências, categorias em destaque e projeções.',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  _analyticsService.logEvent(name: 'onboarding_started');
                  Get.offAllNamed(Routes.CARD_INTRO);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Começar agora',
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
                  _analyticsService.logEvent(name: 'onboarding_skipped');
                  AuthController.instance.isOnboarding = false;
                  Get.offAllNamed(Routes.HOME);
                },
                child: Text(
                  'Pular por enquanto',
                  style: TextStyle(
                    color: DefaultColors.grey20,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
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

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
