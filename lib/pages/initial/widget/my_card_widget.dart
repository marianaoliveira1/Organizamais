import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../pages/add_card_page.dart';
import '../pages/invoice_details_page.dart';

class _CycleDates {
  final DateTime closedStart;
  final DateTime closedEnd;
  final DateTime openStart;
  final DateTime openEnd;
  final DateTime paymentDate;

  _CycleDates({
    required this.closedStart,
    required this.closedEnd,
    required this.openStart,
    required this.openEnd,
    required this.paymentDate,
  });
}

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
      double _parseAmountGlobal(String raw) {
        String s = raw.replaceAll('R\$', '').trim();
        if (s.contains(',')) {
          s = s.replaceAll('.', '').replaceAll(',', '.');
          return double.tryParse(s) ?? 0.0;
        }
        s = s.replaceAll(' ', '');
        return double.tryParse(s) ?? 0.0;
      }

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
      }).fold<double>(0.0, (sum, t) => sum + _parseAmountGlobal(t.value));

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
          // Helpers
          DateTime _safeDate(String iso) {
            try {
              return DateTime.parse(iso);
            } catch (_) {
              return DateTime(1900);
            }
          }

          double _sumTransactionsInRange(
            Iterable<TransactionModel> all,
            String cardName,
            DateTime start,
            DateTime end,
          ) {
            double _parseAmountString(String raw) {
              String s = raw.replaceAll('R\$', '').trim();
              if (s.contains(',')) {
                s = s.replaceAll('.', '').replaceAll(',', '.');
                return double.tryParse(s) ?? 0.0;
              }
              s = s.replaceAll(' ', '');
              return double.tryParse(s) ?? 0.0;
            }

            return all.where((t) {
              if (t.paymentDay == null) return false;
              if (t.type != TransactionType.despesa) return false;
              if ((t.paymentType ?? '') != cardName) return false;
              final d = _safeDate(t.paymentDay!);
              return !d.isBefore(start) && !d.isAfter(end);
            }).fold<double>(0.0, (sum, t) {
              final v = _parseAmountString(t.value);
              return sum + v;
            });
          }

          _CycleDates _computeCycleDates(
              DateTime ref, int closingDay, int paymentDay) {
            // Ajuste de ciclo: compras no dia do fechamento pertencem à próxima fatura
            final DateTime lastMonth = DateTime(ref.year, ref.month - 1, 1);
            final DateTime thisClosing =
                DateTime(ref.year, ref.month, closingDay);
            final DateTime prevClosing =
                DateTime(lastMonth.year, lastMonth.month, closingDay);

            // Fatura fechada (ciclo anterior): (prevClosing+1) .. (thisClosing-1)
            final DateTime closedStart =
                prevClosing.add(const Duration(days: 1));
            final DateTime closedEnd =
                thisClosing.subtract(const Duration(days: 1));

            // Próxima fatura (ciclo aberto): thisClosing .. (nextClosing-1)
            final DateTime openStart = thisClosing;
            final DateTime nextMonth = DateTime(ref.year, ref.month + 1, 1);
            final DateTime nextClosing =
                DateTime(nextMonth.year, nextMonth.month, closingDay);
            final DateTime openEnd =
                nextClosing.subtract(const Duration(days: 1));

            // Data de pagamento referente à fatura fechada deste mês
            final DateTime paymentDate =
                DateTime(ref.year, ref.month, paymentDay);

            return _CycleDates(
              closedStart: closedStart,
              closedEnd: closedEnd,
              openStart: openStart,
              openEnd: openEnd,
              paymentDate: paymentDate,
            );
          }

          // ===== Cálculo por ciclo de fatura (fechamento e pagamento) =====
          final int closingDay = card.closingDay ?? 1;
          final int paymentDay = card.paymentDay ?? 1;

          final _CycleDates cycle =
              _computeCycleDates(now, closingDay, paymentDay);

          // Soma por período fechado (ciclo anterior) e próximo (ciclo aberto pós-fechamento)
          double closedAmount = _sumTransactionsInRange(
            transactions,
            card.name,
            cycle.closedStart,
            cycle.closedEnd,
          );
          double nextAmount = _sumTransactionsInRange(
            transactions,
            card.name,
            cycle.openStart,
            cycle.openEnd,
          );

          // Estado atual: se estamos após fechamento e antes/do pagamento, a fatura está fechada
          final bool isAfterClosing = now.isAfter(cycle.closedEnd);
          final bool isBeforeOrOnPayment = !now.isAfter(cycle.paymentDate);
          final bool invoiceClosed = isAfterClosing && isBeforeOrOnPayment;

          // Valor ativo usado na barra: antes do pagamento e após fechamento usa-se o fechado,
          // caso contrário usa-se o valor do ciclo em aberto (acumulando para a próxima fatura)
          final double spent = invoiceClosed ? closedAmount : nextAmount;

          double _normalizeLimit(double rawLimit) {
            // Normalização simples: se parece ter 1 zero a mais, divide por 10.
            if (rawLimit >= 100000 && rawLimit % 10000 == 0) {
              return rawLimit / 10.0;
            }
            return rawLimit;
          }

          final double rawLimit = card.limit ?? 0.0;
          final double limit = _normalizeLimit(rawLimit);
          final bool hasLimit = limit > 0;
          final double usagePercent = hasLimit ? (spent / limit) * 100.0 : 0.0;
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
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 14.w,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
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

                  // 🔥 Barra de progresso (ou dica para definir limite)
                  if (hasLimit)
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
                              left:
                                  (progressWidth - 20).clamp(0, barWidth - 40),
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
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Text(
                        'Defina o limite para acompanhar o uso',
                        style: TextStyle(
                          color: DefaultColors.grey20,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                  if (hasLimit)
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

                  SizedBox(height: 8.h),

                  // Status e valores por ciclo
                  if (invoiceClosed) ...[
                    // Fatura fechada (entre fechamento e pagamento)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fatura fechada',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatter.format(closedAmount),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Próxima fatura',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatter.format(nextAmount),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fecha dia $closingDay',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Paga dia $paymentDay',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Fora do período de fatura fechada: exibir fatura do ciclo em aberto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fatura do mês',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatter.format(nextAmount),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fecha dia $closingDay',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Paga dia $paymentDay',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.grey20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () {
                        // Quando não está fechado, mostrar ciclo aberto (próxima fatura)
                        Get.to(() => InvoiceDetailsPage(
                              cardName: card.name,
                              periodStart: cycle.openStart,
                              periodEnd: cycle.openEnd,
                              title: 'Próxima fatura',
                            ));
                      },
                      child: Row(
                        children: [
                          Text(
                            'Ver fatura',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          Icon(Icons.chevron_right, color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ],

                  if (invoiceClosed) ...[
                    SizedBox(height: 6.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Quando fechado, mostrar a fatura fechada
                          Get.to(() => InvoiceDetailsPage(
                                cardName: card.name,
                                periodStart: cycle.closedStart,
                                periodEnd: cycle.closedEnd,
                                title: 'Fatura fechada',
                              ));
                        },
                        child: Text(
                          'Ver fatura',
                          style: TextStyle(
                            color: DefaultColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 10.h,
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
