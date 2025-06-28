import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/initial/widget/title_card.dart';
import 'package:organizamais/utils/color.dart';
import '../../../controller/transaction_controller.dart';

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: theme.cardColor,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 14.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final currentMonth = DateTime.now().month;
            final currentYear = DateTime.now().year;

            final parcelamentosCount = _transactionController.transaction
                .where((t) => t.title.contains('Parcela'))
                .where((t) {
              if (t.paymentDay == null) return false;
              final date = DateTime.parse(t.paymentDay!);
              return date.month == currentMonth && date.year == currentYear;
            }).length;

            return DefaultTitleCard(
              text: parcelamentosCount > 0
                  ? 'Parcelas do Mês ($parcelamentosCount)'
                  : 'Parcelas do Mês',
              onTap: () {},
            );
          }),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 1.h,
              horizontal: 1.w,
            ),
            child: Obx(() {
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nenhuma parcela este mês',
                      style: TextStyle(
                        color: DefaultColors.grey20,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Suas parcelas aparecerão aqui',
                      style: TextStyle(
                        color: DefaultColors.grey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }

              // Calcular o valor total das parcelas
              final totalParcelasValue =
                  parcelamentos.fold(0.0, (sum, parcela) {
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

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                      ),
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
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tituloOriginal,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        color: theme.primaryColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatCurrency(
                                          _parseCurrencyValue(parcela.value)),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        color: theme.primaryColor,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(parcela.paymentDay!),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp,
                                        color: DefaultColors.grey20,
                                      ),
                                    ),
                                    if (parcela.paymentType != null &&
                                        parcela.paymentType!.isNotEmpty)
                                      Text(
                                        parcela.paymentType!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10.sp,
                                          color: DefaultColors.grey20,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
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
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
