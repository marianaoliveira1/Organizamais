import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
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

    return Obx(() {
      final cards = cardController.card;
      final transactions = transactionController.transaction;

      // Cálculo do total gasto no mês em todos os cartões de crédito
      final DateTime now = DateTime.now();
      final Set<String> cardNames = cards.map((c) => c.name).toSet();
      final double totalSpent = transactions.where((t) {
        if (t.paymentDay == null) return false;
        if (t.type != TransactionType.despesa) return false;
        if (!cardNames.contains(t.paymentType ?? '')) return false;
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

      if (cards.isEmpty) {
        return Center(
          child: Text(
            'Nenhum cartão adicionado',
            style: TextStyle(
              color: DefaultColors.grey20,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          // Rodapé com total gasto no crédito
          if (index == cards.length) {
            return Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total no crédito',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    formatter.format(totalSpent),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          final card = cards[index];

          // calcular gasto atual do mês
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
            return Container(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Defina o limite para acompanhar o uso',
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final double usagePercent = (spent / limit) * 100.0;
          final double ratio = (usagePercent / 100).clamp(0.0, 1.0);
          final Color progressColor = usagePercent <= 30
              ? DefaultColors.greenDark // Verde (Saudável)
              : (usagePercent <= 70
                  ? DefaultColors.orange // Laranja/Amarelo (Atenção)
                  : DefaultColors.redDark); // Vermelho (Crítico)
          final String percentLabel = '${(ratio * 100).toStringAsFixed(0)}%';

          return GestureDetector(
            onTap: () {
              Get.to(() => AddCardPage(isEditing: true, card: card));
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  content: Text(
                      'Tem certeza que deseja excluir o cartão ${card.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar',
                          style: TextStyle(color: theme.primaryColor)),
                    ),
                    TextButton(
                      onPressed: () {
                        cardController.deleteCard(card.id!);
                        Navigator.of(context).pop();
                      },
                      child: Text('Excluir',
                          style: TextStyle(color: DefaultColors.grey20)),
                    ),
                  ],
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  children: [
                    Center(
                      child: card.iconPath != null
                          ? Image.asset(
                              card.iconPath!,
                              width: 32.w,
                              height: 32.h,
                            )
                          : Icon(Icons.credit_card, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        card.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                // 🔥 Barra de progresso igual ao print
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    final progressWidth = barWidth * ratio;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // fundo da barra
                        Container(
                          height: 10.h,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        // progresso preenchido
                        Container(
                          height: 10.h,
                          width: progressWidth,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        // bolha do percentual
                        Positioned(
                          left: (progressWidth - 20).clamp(0, barWidth - 40),
                          top: -24.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              percentLabel,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 12.h),

                // status do uso por faixa
                // Text(
                //   statusLabel,
                //   style: TextStyle(
                //     fontSize: 11.sp,
                //     color: progressColor,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),

                // SizedBox(height: 8.h),

                // valores dinâmicos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(spent),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'de ${formatter.format(limit)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DefaultColors.grey20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
