import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// import 'package:organizamais/utils/color.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../pages/monthy_analsis/portfolio_details_page.dart';
import 'portfolio_card_analsis.dart';
import '../../../widgetes/info_card.dart';

class FinancialSummaryCards extends StatelessWidget {
  final int selectedYear;

  const FinancialSummaryCards({super.key, required this.selectedYear});

  double _parseValue(String value) {
    try {
      final cleaned = value.replaceAll('R\$', '').trim();
      if (cleaned.contains(',')) {
        return double.parse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
      }
      return double.parse(cleaned.replaceAll(' ', ''));
    } catch (_) {
      return 0.0;
    }
  }

  double _calculateTotalReceitaAno(TransactionController controller, int year) {
    final now = DateTime.now();
    final currentYear = now.year;
    final today = DateTime(now.year, now.month, now.day);

    return controller.transaction.where((t) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (t.type != TransactionType.receita || date.year != year)
          return false;

        // Se o ano selecionado for o ano atual, filtrar apenas até hoje
        if (year == currentYear) {
          final transactionDate = DateTime(date.year, date.month, date.day);
          return transactionDate.isBefore(today) ||
              transactionDate.isAtSameMomentAs(today);
        }

        return true;
      }
      return false;
    }).fold(0.0, (sum, t) => sum + _parseValue(t.value));
  }

  double _calculateTotalDespesasAno(
      TransactionController controller, int year) {
    final now = DateTime.now();
    final currentYear = now.year;
    final today = DateTime(now.year, now.month, now.day);

    return controller.transaction.where((t) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (t.type != TransactionType.despesa || date.year != year)
          return false;

        // Se o ano selecionado for o ano atual, filtrar apenas até hoje
        if (year == currentYear) {
          final transactionDate = DateTime(date.year, date.month, date.day);
          return transactionDate.isBefore(today) ||
              transactionDate.isAtSameMomentAs(today);
        }

        return true;
      }
      return false;
    }).fold(0.0, (sum, t) => sum + _parseValue(t.value));
  }

  double _calculateMediaReceitaMensal(
      TransactionController controller, int year) {
    final now = DateTime.now();
    final currentYear = now.year;
    final today = DateTime(now.year, now.month, now.day);

    Map<int, double> receitasPorMes = {};
    Map<int, double> despesasPorMes = {};

    for (final t in controller.transaction) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (date.year == year) {
          // Se o ano selecionado for o ano atual, filtrar apenas até hoje
          if (year == currentYear) {
            final transactionDate = DateTime(date.year, date.month, date.day);
            if (transactionDate.isAfter(today)) continue;
          }

          final month = date.month;
          final value = _parseValue(t.value);

          if (t.type == TransactionType.receita) {
            receitasPorMes[month] = (receitasPorMes[month] ?? 0) + value;
          } else if (t.type == TransactionType.despesa) {
            despesasPorMes[month] = (despesasPorMes[month] ?? 0) + value;
          }
        }
      }
    }

    final mesesCompletos = receitasPorMes.keys
        .where((mes) => despesasPorMes.containsKey(mes))
        .toList();

    if (mesesCompletos.isEmpty) return 0.0;

    final totalReceitas =
        mesesCompletos.fold(0.0, (sum, mes) => sum + receitasPorMes[mes]!);
    return totalReceitas / mesesCompletos.length;
  }

  double _calculateMediaDespesaMensal(
      TransactionController controller, int year) {
    final now = DateTime.now();
    final currentYear = now.year;
    final today = DateTime(now.year, now.month, now.day);

    Map<int, double> receitasPorMes = {};
    Map<int, double> despesasPorMes = {};

    for (final t in controller.transaction) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (date.year == year) {
          // Se o ano selecionado for o ano atual, filtrar apenas até hoje
          if (year == currentYear) {
            final transactionDate = DateTime(date.year, date.month, date.day);
            if (transactionDate.isAfter(today)) continue;
          }

          final month = date.month;
          final value = _parseValue(t.value);

          if (t.type == TransactionType.receita) {
            receitasPorMes[month] = (receitasPorMes[month] ?? 0) + value;
          } else if (t.type == TransactionType.despesa) {
            despesasPorMes[month] = (despesasPorMes[month] ?? 0) + value;
          }
        }
      }
    }

    final mesesCompletos = despesasPorMes.keys
        .where((mes) => receitasPorMes.containsKey(mes))
        .toList();

    if (mesesCompletos.isEmpty) return 0.0;

    final totalDespesas =
        mesesCompletos.fold(0.0, (sum, mes) => sum + despesasPorMes[mes]!);
    return totalDespesas / mesesCompletos.length;
  }

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      if (controller.isLoading) {
        return _buildShimmerSkeleton();
      }

      final totalReceita = _calculateTotalReceitaAno(controller, selectedYear);
      final totalDespesas =
          _calculateTotalDespesasAno(controller, selectedYear);
      final saldo = totalReceita - totalDespesas;
      final mediaReceita =
          _calculateMediaReceitaMensal(controller, selectedYear);
      final mediaDespesa =
          _calculateMediaDespesaMensal(controller, selectedYear);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: 'Análise anual de $selectedYear',
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
