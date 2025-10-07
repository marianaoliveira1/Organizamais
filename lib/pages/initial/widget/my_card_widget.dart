import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

class MyCardsWidget extends StatefulWidget {
  const MyCardsWidget({
    super.key,
    required this.cardController,
  });

  final CardController cardController;

  @override
  State<MyCardsWidget> createState() => _MyCardsWidgetState();
}

class _MyCardsWidgetState extends State<MyCardsWidget> {
  final Set<String> _paidInvoiceKeys = <String>{};

  String _invoiceKey(String? cardIdOrNull, String cardName, _CycleDates cycle) {
    final String cardKey = cardIdOrNull ?? cardName;
    return '$cardKey-${cycle.paymentDate.year}-${cycle.paymentDate.month}';
  }

  bool _isInvoicePaid(
    String? cardIdOrNull,
    String cardName,
    _CycleDates cycle, [
    List<String>? persistedPaidKeys,
  ]) {
    final String key = _invoiceKey(cardIdOrNull, cardName, cycle);
    return _paidInvoiceKeys.contains(key) ||
        (persistedPaidKeys?.contains(key) ?? false);
  }

  Future<void> _markInvoicePaid(
    String? cardIdOrNull,
    String cardName,
    _CycleDates cycle,
  ) async {
    final String key = _invoiceKey(cardIdOrNull, cardName, cycle);
    setState(() {
      _paidInvoiceKeys.add(key);
    });
    try {
      if (cardIdOrNull != null) {
        await widget.cardController
            .markInvoicePaid(cardId: cardIdOrNull, invoiceKey: key);
      }
      Get.snackbar('Sucesso', 'Fatura marcada como paga');
    } catch (e) {
      setState(() {
        _paidInvoiceKeys.remove(key);
      });
      Get.snackbar('Erro', 'Não foi possível salvar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Obx(() {
      final cards = widget.cardController.card;
      final transactions = transactionController.transaction;

      // Data de referência
      final DateTime now = DateTime.now();

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
          // Rodapé com total gasto no crédito (dinâmico conforme estado da fatura)
          if (index == cards.length) {
            // Helpers locais para somar por período e calcular ciclo
            DateTime safeDate(String iso) {
              try {
                return DateTime.parse(iso);
              } catch (_) {
                return DateTime(1900);
              }
            }

            double sumTransactionsInRangeFooter(
              Iterable<TransactionModel> all,
              String cardName,
              DateTime start,
              DateTime end,
            ) {
              double parseAmountString(String raw) {
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
                final d = safeDate(t.paymentDay!);
                return !d.isBefore(start) && !d.isAfter(end);
              }).fold<double>(
                  0.0, (sum, t) => sum + parseAmountString(t.value));
            }

            _CycleDates computeCycleDatesFooter(
                DateTime ref, int closingDay, int paymentDay) {
              DateTime dateWithDay(int year, int month, int day) {
                final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
                final int safeDay =
                    day > lastDayOfMonth ? lastDayOfMonth : (day < 1 ? 1 : day);
                return DateTime(year, month, safeDay);
              }

              final DateTime closingThisMonth =
                  dateWithDay(ref.year, ref.month, closingDay);
              final bool afterOrOnClosingThisMonth =
                  !ref.isBefore(closingThisMonth);
              final DateTime lastClosingEvent = afterOrOnClosingThisMonth
                  ? closingThisMonth
                  : dateWithDay(ref.year, ref.month - 1, closingDay);
              final DateTime previousClosingEvent = dateWithDay(
                  lastClosingEvent.year,
                  lastClosingEvent.month - 1,
                  closingDay);
              final DateTime nextClosingEvent = dateWithDay(
                  lastClosingEvent.year,
                  lastClosingEvent.month + 1,
                  closingDay);
              final DateTime closedStart =
                  previousClosingEvent.add(const Duration(days: 1));
              final DateTime closedEnd =
                  lastClosingEvent.subtract(const Duration(days: 1));
              final DateTime openStart = lastClosingEvent;
              final DateTime openEnd =
                  nextClosingEvent.subtract(const Duration(days: 1));
              final DateTime paymentDate = paymentDay > closingDay
                  ? dateWithDay(
                      lastClosingEvent.year, lastClosingEvent.month, paymentDay)
                  : dateWithDay(lastClosingEvent.year,
                      lastClosingEvent.month + 1, paymentDay);
              return _CycleDates(
                closedStart: closedStart,
                closedEnd: closedEnd,
                openStart: openStart,
                openEnd: openEnd,
                paymentDate: paymentDate,
              );
            }

            double totalCredit = 0.0;
            for (final c in cards) {
              final int cClosing = c.closingDay ?? 1;
              final int cPayment = c.paymentDay ?? 1;
              final _CycleDates cyc =
                  computeCycleDatesFooter(now, cClosing, cPayment);
              final double cClosed = sumTransactionsInRangeFooter(
                transactions,
                c.name,
                cyc.closedStart,
                cyc.closedEnd,
              );
              final double cNext = sumTransactionsInRangeFooter(
                transactions,
                c.name,
                cyc.openStart,
                cyc.openEnd,
              );
              final bool cInvoiceClosed =
                  !now.isBefore(cyc.openStart) && !now.isAfter(cyc.paymentDate);
              final bool cWasPaid = _isInvoicePaid(c.id, c.name, cyc);
              final bool cShowClosed = cInvoiceClosed && !cWasPaid;
              final double cSpent = cShowClosed ? cClosed : cNext;
              totalCredit += cSpent;
            }

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
                    formatter.format(totalCredit),
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
          DateTime safeDate(String iso) {
            try {
              return DateTime.parse(iso);
            } catch (_) {
              return DateTime(1900);
            }
          }

          double sumTransactionsInRange(
            Iterable<TransactionModel> all,
            String cardName,
            DateTime start,
            DateTime end,
          ) {
            double parseAmountString(String raw) {
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
              final d = safeDate(t.paymentDay!);
              return !d.isBefore(start) && !d.isAfter(end);
            }).fold<double>(0.0, (sum, t) {
              final v = parseAmountString(t.value);
              return sum + v;
            });
          }

          _CycleDates computeCycleDates(
              DateTime ref, int closingDay, int paymentDay) {
            // Função para criar datas garantindo o último dia do mês quando necessário
            DateTime dateWithDay(int year, int month, int day) {
              final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
              final int safeDay =
                  day > lastDayOfMonth ? lastDayOfMonth : (day < 1 ? 1 : day);
              return DateTime(year, month, safeDay);
            }

            // Determina o último evento de fechamento relativo a 'ref'
            final DateTime closingThisMonth =
                dateWithDay(ref.year, ref.month, closingDay);
            final bool afterOrOnClosingThisMonth =
                !ref.isBefore(closingThisMonth);

            final DateTime lastClosingEvent = afterOrOnClosingThisMonth
                ? closingThisMonth
                : dateWithDay(ref.year, ref.month - 1, closingDay);

            final DateTime previousClosingEvent = dateWithDay(
                lastClosingEvent.year, lastClosingEvent.month - 1, closingDay);
            final DateTime nextClosingEvent = dateWithDay(
                lastClosingEvent.year, lastClosingEvent.month + 1, closingDay);

            // Compras no dia do fechamento pertencem à próxima fatura
            final DateTime closedStart =
                previousClosingEvent.add(const Duration(days: 1));
            final DateTime closedEnd =
                lastClosingEvent.subtract(const Duration(days: 1));

            // Próxima fatura (ciclo aberto pós-fechamento)
            final DateTime openStart = lastClosingEvent;
            final DateTime openEnd =
                nextClosingEvent.subtract(const Duration(days: 1));

            // Data de pagamento referente ao fechamento mais recente
            // Regra: se paymentDay > closingDay, pagamento ocorre no MESMO mês do fechamento; caso contrário, no mês SEGUINTE
            final DateTime paymentDate = paymentDay > closingDay
                ? dateWithDay(
                    lastClosingEvent.year, lastClosingEvent.month, paymentDay)
                : dateWithDay(lastClosingEvent.year, lastClosingEvent.month + 1,
                    paymentDay);

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
              computeCycleDates(now, closingDay, paymentDay);

          // Soma por período fechado (ciclo anterior) e próximo (ciclo aberto pós-fechamento)
          double closedAmount = sumTransactionsInRange(
            transactions,
            card.name,
            cycle.closedStart,
            cycle.closedEnd,
          );
          double nextAmount = sumTransactionsInRange(
            transactions,
            card.name,
            cycle.openStart,
            cycle.openEnd,
          );

          // Estado atual: se estamos entre o fechamento (inclusive) e o pagamento (inclusive), fatura está fechada
          final bool isAfterOrOnClosingEvent = !now.isBefore(cycle.openStart);
          final bool isBeforeOrOnPayment = !now.isAfter(cycle.paymentDate);
          final bool invoiceClosed =
              isAfterOrOnClosingEvent && isBeforeOrOnPayment;
          final bool wasMarkedPaid =
              _isInvoicePaid(card.id, card.name, cycle, card.paidInvoices);
          final bool showClosedSection = invoiceClosed && !wasMarkedPaid;

          // Para a barra de progresso e "faltam X para o limite":
          // - Quando a fatura está fechada e ainda não paga, continue exibindo o uso total do limite
          //   somando o valor fechado + o ciclo aberto (compras após o fechamento).
          // - Fora desse período, exiba apenas o ciclo aberto normalmente.
          final double spent =
              showClosedSection ? (closedAmount + nextAmount) : nextAmount;

          double normalizeLimit(double rawLimit) {
            // Normalização simples: se parece ter 1 zero a mais, divide por 10.
            if (rawLimit >= 100000 && rawLimit % 10000 == 0) {
              return rawLimit / 10.0;
            }
            return rawLimit;
          }

          final double rawLimit = card.limit ?? 0.0;
          final double limit = normalizeLimit(rawLimit);
          final bool hasLimit = limit > 0;
          final double usagePercent = hasLimit ? (spent / limit) * 100.0 : 0.0;
          final double ratio = (usagePercent / 100).clamp(0.0, 1.0);
          final double remaining = limit - spent;
          final Color progressColor = usagePercent <= 30
              ? DefaultColors.greenDark // Verde (Saudável)
              : (usagePercent <= 70
                  ? DefaultColors.orange // Laranja/Amarelo (Atenção)
                  : DefaultColors.redDark); // Vermelho (Crítico)
          final String percentLabel = '${(ratio * 100).toStringAsFixed(0)}%';
          final String? statusText = showClosedSection ? 'Fechada' : null;
          // Labels de data e vencimento no estilo "upcoming payment"
          String formatMonthDay(DateTime d) =>
              DateFormat('d MMM', 'pt_BR').format(d).toLowerCase();
          final DateTime today = DateTime(now.year, now.month, now.day);
          final int daysUntilDue = cycle.paymentDate.difference(today).inDays;
          String dueChipText;
          if (daysUntilDue < 0) {
            dueChipText =
                'vencida há ${daysUntilDue.abs()} dia${daysUntilDue.abs() == 1 ? '' : 's'}';
          } else if (daysUntilDue == 0) {
            dueChipText = 'vence hoje';
          } else if (daysUntilDue == 1) {
            dueChipText = 'vence amanhã';
          } else {
            dueChipText = 'vence em $daysUntilDue dias';
          }
          final Color dueChipColor = daysUntilDue < 0
              ? DefaultColors.redDark
              : (daysUntilDue <= 2
                  ? DefaultColors.orange
                  : DefaultColors.grey20);

          return ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Slidable(
              key: ValueKey('card-${card.id ?? card.name}'),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.60,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) {
                      Get.to(() => AddCardPage(isEditing: true, card: card));
                    },
                    backgroundColor: Colors.orange,
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Editar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SlidableAction(
                    onPressed: (_) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: theme.cardColor,
                          title: Text(
                            'Excluir cartão',
                            style: TextStyle(color: theme.primaryColor),
                          ),
                          content: Text(
                            'Tem certeza que deseja excluir o cartão ${card.name}?',
                            style: TextStyle(color: DefaultColors.grey20),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar',
                                  style: TextStyle(color: theme.primaryColor)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Excluir',
                                  style:
                                      TextStyle(color: DefaultColors.grey20)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        widget.cardController.deleteCard(card.id!);
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    label: 'Excluir',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Slidable.of(context)?.close();
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
                            widget.cardController.deleteCard(card.id!);
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
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.06),
                    ),
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
                                    width: 38.w,
                                    height: 38.h,
                                  )
                                : Icon(Icons.credit_card, size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (card.bankName != null &&
                                    (card.bankName ?? '')
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      card.bankName!,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DefaultColors.grey20,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (statusText != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: DefaultColors.redDark.withOpacity(.9),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.info_circle,
                                    color: DefaultColors.redDark,
                                    size: 12.h,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: DefaultColors.redDark,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                    gradient: LinearGradient(
                                      colors: [
                                        progressColor.withOpacity(0.85),
                                        progressColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                                // bolha do percentual
                                Positioned(
                                  left: (progressWidth - 20)
                                      .clamp(0, barWidth - 40),
                                  top: -24.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: theme.primaryColor
                                            .withOpacity(0.08),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.shadowColor
                                              .withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
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
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'de ${formatter.format(limit)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey20,
                              ),
                            ),
                          ],
                        ),
                      if (hasLimit) ...[
                        SizedBox(height: 4.h),
                        Text(
                          remaining >= 0
                              ? 'Faltam ${formatter.format(remaining)} para o limite'
                              : 'Ultrapassou o limite em ${formatter.format(-remaining)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: remaining >= 0
                                ? DefaultColors.grey20
                                : DefaultColors.redDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      SizedBox(height: 8.h),

                      // Status e valores por ciclo
                      if (showClosedSection) ...[
                        // Cabeçalho: Fatura do mês (exibir apenas quando a fatura estiver fechada e não paga)
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
                              formatter.format(closedAmount),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        // Cabeçalho tipo "upcoming payment"
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              formatMonthDay(cycle.paymentDate),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: dueChipColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                dueChipText,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'total da fatura',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.grey20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    formatter.format(closedAmount),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'próxima fatura',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.grey20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    formatter.format(nextAmount),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Datas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatMonthDay(cycle.paymentDate),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'vencimento',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatMonthDay(cycle.openStart),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'fechou em',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Botão primário "Pagar agora"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.scaffoldBackgroundColor,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: theme.cardColor,
                                  title: Text(
                                    'Confirmar pagamento',
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                  content: Text(
                                    'Sua fatura foi paga?',
                                    style:
                                        TextStyle(color: DefaultColors.grey20),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Não',
                                          style: TextStyle(
                                              color: theme.primaryColor)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Sim',
                                          style: TextStyle(
                                              color: DefaultColors.green)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                _markInvoicePaid(card.id, card.name, cycle);
                              }
                            },
                            child: Text(
                              'Já foi paga?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.sp,
                                color: theme.cardColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Links secundários
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: theme.primaryColor.withOpacity(.4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                              ),
                              onPressed: () {
                                Get.to(() => InvoiceDetailsPage(
                                      cardName: card.name,
                                      periodStart: cycle.closedStart,
                                      periodEnd: cycle.closedEnd,
                                      title: 'Fatura anterior',
                                    ));
                              },
                              child: Text(
                                'Ver fatura anterior',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: theme.primaryColor.withOpacity(.4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                              ),
                              onPressed: () {
                                Get.to(() => InvoiceDetailsPage(
                                      cardName: card.name,
                                      periodStart: cycle.openStart,
                                      periodEnd: cycle.openEnd,
                                      title: 'Próxima fatura',
                                    ));
                              },
                              child: Text(
                                'Próxima fatura',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Fora do período de fatura fechada
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
                        SizedBox(height: 10.h),
                        InkWell(
                          borderRadius: BorderRadius.circular(
                              12), // efeito ripple arredondado
                          onTap: () {
                            // Quando não está fechado, mostrar ciclo aberto (próxima fatura)
                            Get.to(() => InvoiceDetailsPage(
                                  cardName: card.name,
                                  periodStart: cycle.openStart,
                                  periodEnd: cycle.openEnd,
                                  title: 'Próxima fatura',
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Iconsax.receipt,
                                        color: theme.primaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ver fatura',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right,
                                    color: theme.primaryColor),
                              ],
                            ),
                          ),
                        )
                      ],

                      if (showClosedSection) ...[SizedBox(height: 0)],
                      SizedBox(
                        height: 10.h,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
