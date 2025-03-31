import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/initial/widget/title_card.dart';
import 'package:organizamais/utils/color.dart';
import '../../../controller/transaction_controller.dart';

class ParcelamentosCard extends StatelessWidget {
  final TransactionController _transactionController = Get.find<TransactionController>();

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
          value.replaceAll('R\$', '').trim().replaceAll('.', '').replaceAll(',', '.'),
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
          DefaultTitleCard(
            text: 'Parcelamentos do Mês',
            onTap: () {},
          ),
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
              final parcelamentos = _transactionController.transaction.where((t) => t.title.contains('Parcela')).where((t) {
                if (t.paymentDay == null) return false;
                final date = DateTime.parse(t.paymentDay!);
                return date.month == currentMonth && date.year == currentYear;
              }).toList();

              if (parcelamentos.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum parcelamento este mês',
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              // Calcular o valor total das parcelas
              final totalParcelasValue = parcelamentos.fold(0.0, (sum, parcela) {
                return sum + _parseCurrencyValue(parcela.value);
              });

              return Column(
                children: [
                  ...parcelamentos.map((parcela) {
                    // Extrai informações da parcela do título
                    final regex = RegExp(r'Parcela (\d+) de (\d+): (.+)');
                    final match = regex.firstMatch(parcela.title);
                    final tituloOriginal = match?.group(3) ?? parcela.title;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 130.w,
                                child: Text(
                                  tituloOriginal,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: theme.primaryColor,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (parcela.paymentDay != null)
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
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 130.w,
                                child: Text(
                                  _formatCurrency(_parseCurrencyValue(parcela.value)),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width: 100.w,
                                child: Text(
                                  parcela.paymentType ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 8.h),
                  // Total das parcelas
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
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
