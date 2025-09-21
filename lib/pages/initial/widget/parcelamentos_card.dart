import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
// import 'package:organizamais/pages/initial/widget/title_card.dart';
import 'package:organizamais/widgetes/info_card.dart';
import 'package:organizamais/utils/color.dart';
import '../../../controller/transaction_controller.dart';
import '../pages/parcelas_details_page.dart';

class ParcelamentosCard extends StatelessWidget {
  final TransactionController _transactionController =
      Get.find<TransactionController>();

  ParcelamentosCard({super.key});

  // Função para formatar valores em Real brasileiro
  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  // Função para converter string de valor para double
  double _parseCurrencyValue(String value) {
    return double.tryParse(
          value
              .replaceAll('R\$', '')
              .trim()
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (_transactionController.isLoading) {
        return _buildShimmerSkeleton(theme);
      }

      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      final parcelamentos = _transactionController.transaction
          .where((t) => t.title.contains('Parcela'))
          .where((t) {
        if (t.paymentDay == null) return false;
        final date = DateTime.parse(t.paymentDay!);
        return date.month == currentMonth && date.year == currentYear;
      }).toList();

      if (parcelamentos.isEmpty) {
        return const SizedBox.shrink();
      }

      final parcelamentosCount = parcelamentos.length;

      return InfoCard(
        title: 'Parcelas do Mês ($parcelamentosCount)',
        icon: Icons.add,
        onTap: () {
          Get.to(() => TransactionPage());
        },
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParcelamentosContent(theme),
          ],
        ),
      );
    });
  }

  Widget _buildParcelamentosContent(ThemeData theme) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    // Filtra transações que são parcelamentos (título contém "Parcela")
    final parcelamentos = _transactionController.transaction
        .where((t) => t.title.contains('Parcela'))
        .where((t) {
      if (t.paymentDay == null) return false;
      final date = DateTime.parse(t.paymentDay!);
      return date.month == currentMonth && date.year == currentYear;
    }).toList();

    // Ordena por data (do menor para o maior)
    parcelamentos.sort((a, b) {
      final dateA = DateTime.parse(a.paymentDay!);
      final dateB = DateTime.parse(b.paymentDay!);
      return dateA.compareTo(dateB);
    });

    if (parcelamentos.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma parcela este mês',
          style: TextStyle(
            color: DefaultColors.grey20,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Calcular o valor total das parcelas
    final totalParcelasValue = parcelamentos.fold(0.0, (sum, parcela) {
      return sum + _parseCurrencyValue(parcela.value);
    });

    // Contar quantas parcelas únicas (produtos diferentes) existem
    final produtosUnicos = <String>{};
    for (final parcela in parcelamentos) {
      final regex = RegExp(r'Parcela (\d+): (.+)');
      final match = regex.firstMatch(parcela.title);
      if (match != null) {
        produtosUnicos.add(match.group(2)!);
      }
    }

    return Column(
      children: [
        ...parcelamentos.map((parcela) {
          // Extrai informações da parcela do título
          final regex = RegExp(r'Parcela (\d+): (.+)');
          final match = regex.firstMatch(parcela.title);
          final parcelaAtual = match?.group(1) ?? '1';
          final tituloOriginal = match?.group(2) ?? parcela.title;

          // Busca quantas parcelas totais existem para este item
          final totalParcelas = _transactionController.transaction
              .where((t) => t.title.contains(': $tituloOriginal'))
              .length;

          return InkWell(
            onTap: () {
              Get.to(() => ParcelasDetailsPage(productName: tituloOriginal));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parcela $parcelaAtual de $totalParcelas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                          color: DefaultColors.grey20,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 140.w,
                            child: Text(
                              tituloOriginal,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 110.w,
                            child: Text(
                              _formatCurrency(
                                  _parseCurrencyValue(parcela.value)),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      if (parcela.paymentDay != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(parcela.paymentDay!),
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                                color: DefaultColors.grey20,
                              ),
                            ),
                            if (parcela.paymentType != null &&
                                parcela.paymentType!.isNotEmpty)
                              SizedBox(
                                width: 115.w,
                                child: Text(
                                  parcela.paymentType!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 12.h),
        // Total das parcelas
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(totalParcelasValue),
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerSkeleton(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer for title
        Shimmer(
          duration: const Duration(milliseconds: 1400),
          color: Colors.white.withOpacity(0.6),
          child: Container(
            height: 20.h,
            width: 150.w,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Shimmer for parcelamentos items
        Column(
          children: [
            _buildShimmerItem(),
            _buildShimmerItem(),
            _buildShimmerItem(),
          ],
        ),
        SizedBox(height: 12.h),
        // Shimmer for total
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Shimmer(
              duration: const Duration(milliseconds: 1400),
              color: Colors.white.withOpacity(0.6),
              child: Container(
                height: 11.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer for "Parcela X de Y"
                  Shimmer(
                    duration: const Duration(milliseconds: 1400),
                    color: Colors.white.withOpacity(0.6),
                    child: Container(
                      height: 10.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Shimmer for product name and value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 13.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 13.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Shimmer for date and payment type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 11.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                      Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 11.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
