import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import 'package:intl/intl.dart';
import '../../../utils/color.dart';
import '../pages/add_card_page.dart';

class MyCardsWidget extends StatelessWidget {
  const MyCardsWidget({
    super.key,
    required this.cardController,
  });

  final CardController cardController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            // Dependências reativas: cartões e transações
            final cards = cardController.card;
            final _txCount = transactionController.transactionRx.length;
            // Usa a lista ajustada (considera fechamento de fatura)
            final transactions = transactionController.transaction;
            if (cards.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum cartão adicionado',
                  style: TextStyle(
                    color: DefaultColors.grey20,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (context, index) => SizedBox(
                height: 12.h,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        content: Text(
                            'Tem certeza que deseja excluir o cartão ${card.name}?'),
                        actions: [
                          TextButton(
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Excluir',
                              style: TextStyle(
                                color: DefaultColors.grey20,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              cardController.deleteCard(card.id!);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () {
                    Get.to(
                      () => AddCardPage(
                        isEditing: true,
                        card: card,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (card.iconPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.asset(
                                card.iconPath!,
                                width: 36.w,
                                height: 36.h,
                              ),
                            ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Text(
                              card.name,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Builder(builder: (context) {
                        // Alinhar com páginas de Resumo/Gráficos: usar mês-calendário atual
                        final DateTime now = DateTime.now();
                        double spent = transactions.where((t) {
                          if (t.paymentDay == null) return false;
                          if (t.type != TransactionType.despesa) return false;
                          if ((t.paymentType ?? '') != card.name) return false;
                          try {
                            final d = DateTime.parse(t.paymentDay!);
                            return d.year == now.year && d.month == now.month;
                          } catch (_) {
                            return false;
                          }
                        }).fold<double>(0.0, (sum, t) {
                          try {
                            final v = double.parse(t.value
                                .replaceAll('R\$', '')
                                .trim()
                                .replaceAll('.', '')
                                .replaceAll(',', '.'));
                            return sum + v;
                          } catch (_) {
                            return sum;
                          }
                        });

                        final double? limit = card.limit;
                        if (limit == null || limit <= 0) {
                          return Text(
                            'Defina o limite para acompanhar o uso',
                            style: TextStyle(
                              color: DefaultColors.grey20,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }

                        final double ratio = (spent / limit).clamp(0.0, 1.0);
                        final String percentLabel =
                            '${(ratio * 100).toStringAsFixed(0)}%';
                        final Color barColor = ratio < 0.6
                            ? DefaultColors.green
                            : (ratio < 0.9 ? Colors.orange : DefaultColors.red);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8.h,
                                backgroundColor:
                                    theme.primaryColor.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  barColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${formatter.format(spent)} de ${formatter.format(limit)}',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  percentLabel,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
