import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'package:organizamais/utils/color.dart';

import '../../../controller/transaction_controller.dart';
import '../../../pages/monthy_analsis/portfolio_details_page.dart';

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
          GestureDetector(
            onTap: () {
              Get.to(() => const PortfolioDetailsPage());
            },
            child: PortfolioCard(
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

class PortfolioCard extends StatelessWidget {
  final double saldo;
  final double valueReceita;
  final double valueDespesa;
  final double mediaDespesa;
  final double mediaReceita;

  const PortfolioCard(
      {super.key,
      required this.saldo,
      required this.valueReceita,
      required this.valueDespesa,
      required this.mediaDespesa,
      required this.mediaReceita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Análise anual de ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: DefaultColors.grey20,
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                size: 8.sp,
                color: DefaultColors.grey,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(
                    saldo), // Removido o .abs() para mostrar valores negativos
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.bold,
                  color: saldo < 0
                      ? DefaultColors.red
                      : DefaultColors.green, // Cor vermelha para saldo negativo
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receitas',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatCurrency(valueReceita),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: DefaultColors.greyLight,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Despesas",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatCurrency(valueDespesa),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média de Receitas',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatCurrency(mediaReceita),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: DefaultColors.greyLight,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Média de Despesas",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatCurrency(mediaDespesa),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted =
        absValue.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );

    return '${isNegative ? '-' : ''}R\$ $formatted';
  }
}

// Donut visualização removida a pedido do usuário.
