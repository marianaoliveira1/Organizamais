import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// import 'package:organizamais/utils/color.dart';

import '../../../controller/transaction_controller.dart';
import '../../../pages/monthy_analsis/portfolio_details_page.dart';
import 'portfolio_card_analsis.dart';
import '../../../widgetes/info_card.dart';

class FinancialSummaryCards extends StatelessWidget {
  const FinancialSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      if (controller.isLoading) {
        return _buildShimmerSkeleton();
      }

      final totalReceita = controller.totalReceitaAno;
      final totalDespesas = controller.totalDespesasAno;
      final saldo = totalReceita - totalDespesas;
      final mediaReceita = controller.mediaReceitaMensal;
      final mediaDespesa = controller.mediaDespesaMensal;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: 'Análise anual de 2025',
            icon: Iconsax.arrow_right_3,
            onTap: () {
              Get.to(() => const PortfolioDetailsPage());
            },
            content: PortfolioCard(
              saldo: saldo,
              valueReceita: totalReceita,
              valueDespesa: totalDespesas,
              mediaReceita: mediaReceita,
              mediaDespesa: mediaDespesa,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
        ],
      );
    });
  }

  Widget _buildShimmerSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer for title
        Shimmer(
          duration: const Duration(milliseconds: 1400),
          color: Colors.white.withValues(alpha: 0.6),
          child: Container(
            height: 12.h,
            width: 200.w,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Shimmer for first row of cards (Receitas/Despesas)
        Row(
          children: [
            Expanded(child: _buildCardSkeleton()),
            SizedBox(width: 12.h),
            Expanded(child: _buildCardSkeleton()),
          ],
        ),

        SizedBox(height: 16.h),

        // Shimmer for second title
        Shimmer(
          duration: const Duration(milliseconds: 1400),
          color: Colors.white.withValues(alpha: 0.6),
          child: Container(
            height: 12.h,
            width: 180.w,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Shimmer for second row of cards (Médias)
        Row(
          children: [
            Expanded(child: _buildCardSkeleton()),
            SizedBox(width: 12.h),
            Expanded(child: _buildCardSkeleton()),
          ],
        ),

        SizedBox(height: 16.h),

        // Shimmer for saldo card
        _buildSaldoCardSkeleton(),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Title shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withValues(alpha: 0.6),
            child: Container(
              height: 14.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          // Value shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withValues(alpha: 0.6),
            child: Container(
              height: 20.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Icon shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1400),
            color: Colors.white.withOpacity(0.6),
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                Shimmer(
                  duration: const Duration(milliseconds: 1400),
                  color: Colors.white.withValues(alpha: 0.6),
                  child: Container(
                    height: 14.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                // Value shimmer
                Shimmer(
                  duration: const Duration(milliseconds: 1400),
                  color: Colors.white.withValues(alpha: 0.6),
                  child: Container(
                    height: 20.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
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
