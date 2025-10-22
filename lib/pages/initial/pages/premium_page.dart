import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utils/color.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja Premium'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(theme),
            SizedBox(height: 16.h),
            _planCard(
              theme: theme,
              title: 'Plano Grátis',
              price: currency.format(0),
              subtitle: 'Para começar sem custo',
              color: DefaultColors.grey20.withOpacity(.15),
              icon: Iconsax.play_circle,
              benefits: const [
                'Com anúncios',
                'Até 2 cartões',
                'Até 5 contas fixas',
              ],
              actionLabel: 'Continuar no grátis',
              primary: false,
            ),
            SizedBox(height: 12.h),
            _planCard(
              theme: theme,
              title: 'Plano Plus',
              price: currency.format(10),
              subtitle: 'Mais recursos, sem anúncios',
              color: DefaultColors.vibrantPurple,
              icon: Iconsax.crown,
              benefits: const [
                'Sem anúncios',
                'Até 5 cartões',
                'Até 10 contas fixas',
              ],
              actionLabel: 'Assinar por R\$ 10,00',
              primary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: DefaultColors.grey20.withOpacity(.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: DefaultColors.vibrantPurple.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.crown,
                color: DefaultColors.vibrantPurple, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbloqueie o melhor do Organiza+',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Escolha o melhor plano para você: continue grátis ou assine o Plus.',
                  style: TextStyle(fontSize: 12.sp, color: DefaultColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required ThemeData theme,
    required String title,
    required String price,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<String> benefits,
    required String actionLabel,
    required bool primary,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primary ? DefaultColors.vibrantPurple : theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primary
              ? DefaultColors.vibrantPurple
              : DefaultColors.grey20.withOpacity(.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withOpacity(.15)
                      : color.withOpacity(.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: primary ? Colors.white : color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: primary ? Colors.white : theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: primary
                          ? Colors.white.withOpacity(.9)
                          : DefaultColors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                price,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: primary ? Colors.white : theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final b in benefits)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(Iconsax.verify,
                          size: 16.sp,
                          color: primary ? Colors.white : DefaultColors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: primary ? Colors.white : theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primary ? Colors.white : DefaultColors.vibrantPurple,
                foregroundColor:
                    primary ? DefaultColors.vibrantPurple : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {},
              child: Text(
                actionLabel,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
