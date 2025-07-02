import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';

class ParcelasDetailsPage extends StatelessWidget {
  final String productName;
  final TransactionController _transactionController =
      Get.find<TransactionController>();

  ParcelasDetailsPage({super.key, required this.productName});

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

  // Função para mostrar dialog de confirmação de exclusão
  void _showDeleteConfirmation(
      BuildContext context, String transactionId, String parcelaInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Excluir Parcela',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir a $parcelaInfo?',
            style: TextStyle(
              fontSize: 14.sp,
              color: DefaultColors.grey20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _transactionController.deleteTransaction(transactionId);
                Navigator.of(context).pop();
                Get.snackbar(
                  'Sucesso',
                  'Parcela excluída com sucesso!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Excluir',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.primaryColor,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        // title: Text(
        //   'Detalhes das Parcelas',
        //   style: TextStyle(
        //     color: theme.primaryColor,
        //     fontSize: 18.sp,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            // Header com nome do produto
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produto',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DefaultColors.grey20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Lista de parcelas
            Expanded(
              child: Obx(() {
                // Filtra todas as parcelas deste produto
                final parcelasProduct = _transactionController.transaction
                    .where((t) => t.title.contains(': $productName'))
                    .toList();

                // Ordena por número da parcela
                parcelasProduct.sort((a, b) {
                  final regexA = RegExp(r'Parcela (\d+):');
                  final regexB = RegExp(r'Parcela (\d+):');
                  final matchA = regexA.firstMatch(a.title);
                  final matchB = regexB.firstMatch(b.title);

                  final parcelaA = int.tryParse(matchA?.group(1) ?? '0') ?? 0;
                  final parcelaB = int.tryParse(matchB?.group(1) ?? '0') ?? 0;

                  return parcelaA.compareTo(parcelaB);
                });

                if (parcelasProduct.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 64.sp,
                          color: DefaultColors.grey.withOpacity(0.5),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Nenhuma parcela encontrada',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calcular valor total
                final valorTotal = parcelasProduct.fold(0.0, (sum, parcela) {
                  return sum + _parseCurrencyValue(parcela.value);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho da lista
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Parcelas (${parcelasProduct.length})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total: ${_formatCurrency(valorTotal)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Lista das parcelas
                    Expanded(
                      child: ListView.builder(
                        itemCount: parcelasProduct.length,
                        itemBuilder: (context, index) {
                          final parcela = parcelasProduct[index];

                          // Extrai número da parcela
                          final regex = RegExp(r'Parcela (\d+):');
                          final match = regex.firstMatch(parcela.title);
                          final numeroParcela =
                              match?.group(1) ?? '${index + 1}';

                          // Verifica se a parcela já foi paga (data no passado)
                          final isPaga = parcela.paymentDay != null &&
                              DateTime.parse(parcela.paymentDay!)
                                  .isBefore(DateTime.now());

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isPaga
                                    ? Colors.green.withOpacity(0.3)
                                    : DefaultColors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Conteúdo principal da parcela
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Row(
                                      children: [
                                        // Indicador de status
                                        Container(
                                          width: 4.w,
                                          height: 40.h,
                                          decoration: BoxDecoration(
                                            color: isPaga
                                                ? Colors.green
                                                : theme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(2.r),
                                          ),
                                        ),

                                        SizedBox(width: 12.w),

                                        // Informações da parcela
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Parcela $numeroParcela',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: theme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatCurrency(
                                                        _parseCurrencyValue(
                                                            parcela.value)),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: theme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4.h),
                                              if (parcela.paymentDay != null)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      isPaga
                                                          ? Icons.check_circle
                                                          : Icons.schedule,
                                                      size: 14.sp,
                                                      color: isPaga
                                                          ? Colors.green
                                                          : DefaultColors
                                                              .grey20,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(
                                                        DateTime.parse(parcela
                                                            .paymentDay!),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: isPaga
                                                            ? Colors.green
                                                            : DefaultColors
                                                                .grey20,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    // Text(
                                                    //   isPaga
                                                    //       ? 'Paga'
                                                    //       : 'Pendente',
                                                    //   style: TextStyle(
                                                    //     fontSize: 11.sp,
                                                    //     color: isPaga
                                                    //         ? Colors.green
                                                    //         : Colors.orange,
                                                    //     fontWeight:
                                                    //         FontWeight.w600,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              if (parcela.paymentType != null &&
                                                  parcela
                                                      .paymentType!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 4.h),
                                                  child: Text(
                                                    parcela.paymentType!,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          DefaultColors.grey20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Botão de excluir
                                SizedBox(
                                  width: 60.w,
                                  height: 80.h,
                                  child: InkWell(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                    onTap: () {
                                      if (parcela.id != null) {
                                        _showDeleteConfirmation(
                                          context,
                                          parcela.id!,
                                          'Parcela $numeroParcela',
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
