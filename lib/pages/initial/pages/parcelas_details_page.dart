import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';

class ParcelasDetailsPage extends StatelessWidget {
  final String productName;
  final String? filterPaymentType; // normalizado no chamador
  final double? installmentValue; // valor por parcela
  final String? seriesStartKey; // formato yyyy-MM
  final TransactionController _transactionController =
      Get.find<TransactionController>();

  ParcelasDetailsPage({
    super.key,
    required this.productName,
    this.filterPaymentType,
    this.installmentValue,
    this.seriesStartKey,
  });

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
            Icons.arrow_back,
            color: theme.primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Detalhes das Parcelas',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
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

            // Lista de parcelas
            Expanded(
              child: Obx(() {
                // Filtra todas as parcelas deste produto com critérios adicionais do grupo
                final all = _transactionController.transaction;
                final regexBase = RegExp(r'^Parcela\s+(\d+)\s*:\s*(.+)$');
                final String? normalizedPaymentType =
                    filterPaymentType?.trim().toLowerCase();

                // Função para normalizar paymentType
                String _normPay(String? s) => (s ?? '').trim().toLowerCase();

                // Função que retorna a chave yyyy-MM do primeiro vencimento da série
                String _seriesStartKeyFor(TransactionModel t) {
                  final mt = regexBase.firstMatch(t.title);
                  final base = mt != null ? mt.group(2) ?? '' : '';
                  final sameGroup = all.where((x) {
                    final mx = regexBase.firstMatch(x.title);
                    final bx = mx != null ? mx.group(2) ?? '' : '';
                    if (bx != base) return false;
                    if (normalizedPaymentType != null &&
                        _normPay(x.paymentType) != normalizedPaymentType) {
                      return false;
                    }
                    if (installmentValue != null) {
                      final vx = _parseCurrencyValue(x.value);
                      if ((vx - installmentValue!).abs() > 0.005) return false;
                    }
                    return true;
                  }).toList();
                  DateTime? firstDate;
                  for (final x in sameGroup) {
                    if (x.paymentDay == null) continue;
                    final d = DateTime.tryParse(x.paymentDay!);
                    if (d == null) continue;
                    if (firstDate == null || d.isBefore(firstDate)) {
                      firstDate = d;
                    }
                  }
                  if (firstDate == null) return '';
                  return '${firstDate.year}-${firstDate.month.toString().padLeft(2, '0')}';
                }

                var parcelasProduct = all.where((t) {
                  final m = regexBase.firstMatch(t.title);
                  if (m == null) return false;
                  final base = m.group(2) ?? '';
                  if (base != productName) return false;
                  if (normalizedPaymentType != null &&
                      _normPay(t.paymentType) != normalizedPaymentType) {
                    return false;
                  }
                  if (installmentValue != null) {
                    final v = _parseCurrencyValue(t.value);
                    if ((v - installmentValue!).abs() > 0.005) return false;
                  }
                  if (seriesStartKey != null && seriesStartKey!.isNotEmpty) {
                    return _seriesStartKeyFor(t) == seriesStartKey;
                  }
                  return true;
                }).toList();

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

                // Remove possíveis duplicatas (mesmo título e mesma data)
                final seenKeys = <String>{};
                final parcelasUnique = <dynamic>[];
                for (final p in parcelasProduct) {
                  final key = '${p.title}|${p.paymentDay ?? ''}';
                  if (seenKeys.add(key)) {
                    parcelasUnique.add(p);
                  }
                }

                if (parcelasUnique.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 48.sp,
                          color: DefaultColors.grey20,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Nenhuma parcela encontrada',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calcular valor total, quantidade de parcelas e datas
                final valorTotal = parcelasUnique.fold(0.0, (sum, parcela) {
                  return sum + _parseCurrencyValue(parcela.value);
                });
                final int qtdParcelas = parcelasUnique.length;
                final now = DateTime.now();
                int pagasCount = 0;
                double valorPago = 0.0;
                DateTime? primeiraData;
                DateTime? ultimaData;
                for (final p in parcelasUnique) {
                  if (p.paymentDay == null) continue;
                  final d = DateTime.tryParse(p.paymentDay!);
                  if (d == null) continue;
                  if (primeiraData == null || d.isBefore(primeiraData)) {
                    primeiraData = d;
                  }
                  if (ultimaData == null || d.isAfter(ultimaData)) {
                    ultimaData = d;
                  }
                  if (d.isBefore(now)) {
                    pagasCount += 1;
                    valorPago += _parseCurrencyValue(p.value);
                  }
                }
                final double progresso = valorTotal > 0
                    ? (valorPago / valorTotal).clamp(0.0, 1.0)
                    : 0.0;

                // Banco: vindo do filtro ou da primeira parcela
                String bankName = (filterPaymentType ?? '').trim();
                if (bankName.isEmpty && parcelasUnique.isNotEmpty) {
                  bankName = (parcelasUnique.first.paymentType ?? '').trim();
                }

                // Encontrar próxima parcela (primeira não paga)
                TransactionModel? proximaParcela;
                for (final p in parcelasUnique) {
                  if (p.paymentDay == null) continue;
                  final d = DateTime.tryParse(p.paymentDay!);
                  if (d == null) continue;
                  if (!d.isBefore(now)) {
                    proximaParcela = p;
                    break;
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumo da compra (antes da lista)
                      Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text(
                                  primeiraData != null
                                      ? 'Comprado em ${DateFormat('dd/MM/yyyy').format(primeiraData)}'
                                      : 'Comprado em —',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (bankName.isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Text(
                                    '• $bankName',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: DefaultColors.grey20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total parcelado',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: DefaultColors.grey20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _formatCurrency(valorTotal),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total já pago',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: DefaultColors.grey20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _formatCurrency(valorPago),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: DefaultColors.greenDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progresso',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(progresso * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Stack(
                              children: [
                                Container(
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: DefaultColors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                ),
                                LayoutBuilder(builder: (context, c) {
                                  final double w = c.maxWidth * progresso;
                                  return Container(
                                    width: w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      color: DefaultColors.greenDark,
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Parcelas: ${pagasCount}x / ${qtdParcelas}x',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (proximaParcela != null &&
                                    proximaParcela.paymentDay != null)
                                  Text(
                                    'Próxima: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(proximaParcela.paymentDay!))}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: DefaultColors.grey20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Cabeçalho da lista
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Text(
                          'Parcelas (${parcelasUnique.length})',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Lista das parcelas
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: parcelasUnique.length,
                        itemBuilder: (context, index) {
                          final parcela = parcelasUnique[index];

                          // Extrai número da parcela
                          final regex = RegExp(r'Parcela (\d+):');
                          final match = regex.firstMatch(parcela.title);
                          final numeroParcela =
                              match?.group(1) ?? '${index + 1}';

                          // Verifica se a parcela já foi paga (data no passado)
                          final isPaga = parcela.paymentDay != null &&
                              DateTime.parse(parcela.paymentDay!)
                                  .isBefore(DateTime.now());
                          final isProxima = proximaParcela != null &&
                              parcela.id == proximaParcela.id;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Parcela $numeroParcela',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              if (isPaga)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        DefaultColors.greenDark,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.r),
                                                  ),
                                                  child: Text(
                                                    'Pago',
                                                    style: TextStyle(
                                                      fontSize: 9.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                )
                                              else if (isProxima)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.r),
                                                  ),
                                                  child: Text(
                                                    'Próxima',
                                                    style: TextStyle(
                                                      fontSize: 9.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          if (parcela.paymentDay != null)
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(
                                                    parcela.paymentDay!),
                                              ),
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: DefaultColors.grey20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatCurrency(_parseCurrencyValue(
                                              parcela.value)),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isPaga
                                                ? DefaultColors.greenDark
                                                : theme.primaryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (parcela.paymentType != null &&
                                            parcela.paymentType!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: Text(
                                              parcela.paymentType!,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: DefaultColors.grey20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (parcela.id != null) {
                                          _showDeleteConfirmation(
                                            context,
                                            parcela.id!,
                                            'Parcela $numeroParcela',
                                          );
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Excluir',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
