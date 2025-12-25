import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../utils/color.dart';
import '../../../utils/snackbar_helper.dart';
import '../pages/add_card_page.dart';

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

  bool _isInvoicePaid(
    String? cardIdOrNull,
    String cardName,
    CardCycleDates cycle, [
    List<String>? persistedPaidKeys,
  ]) {
    final String key =
        widget.cardController.generateInvoiceKey(cardIdOrNull, cardName, cycle);
    return _paidInvoiceKeys.contains(key) ||
        (persistedPaidKeys?.contains(key) ?? false);
  }

  Future<void> _markInvoicePaid(
    String? cardIdOrNull,
    String cardName,
    CardCycleDates cycle,
  ) async {
    final String key =
        widget.cardController.generateInvoiceKey(cardIdOrNull, cardName, cycle);
    setState(() {
      _paidInvoiceKeys.add(key);
    });
    try {
      if (cardIdOrNull != null) {
        await widget.cardController
            .markInvoicePaid(cardId: cardIdOrNull, invoiceKey: key);
      }
      SnackbarHelper.showSuccess('Fatura marcada como paga');
    } catch (e) {
      setState(() {
        _paidInvoiceKeys.remove(key);
      });
      SnackbarHelper.showError('Não foi possível salvar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bool isTablet = mediaQuery.size.width >= 600;
    final double adjustedTextScaleFactor = isTablet
        ? (mediaQuery.textScaleFactor * 0.65).clamp(0.6, 0.9)
        : mediaQuery.textScaleFactor;
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return MediaQuery(
        data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(adjustedTextScaleFactor)),
        child: RepaintBoundary(
          child: Obx(() {
            final cards = widget.cardController.card;
            final transactions = transactionController.transaction;

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

            final DateTime now = DateTime.now();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == cards.length) {
                  double totalCredit = 0.0;
                  for (final c in cards) {
                    final summary = widget.cardController.getCardSummary(
                      allTransactions: transactions,
                      card: c,
                    );

                    final CardCycleDates cyc = widget.cardController
                        .computeCycleDates(
                            now, c.closingDay ?? 1, c.paymentDay ?? 1);

                    final bool wasPaid =
                        _isInvoicePaid(c.id, c.name, cyc, c.paidInvoices);
                    final bool afterClosing = !now.isBefore(cyc.openEnd);
                    final bool beforePayment = !now.isAfter(cyc.paymentDate);
                    final bool showClosed =
                        afterClosing && beforePayment && !wasPaid;

                    // CORREÇÃO: Somar a fatura que está sendo exibida (Fechada ou Aberta)
                    totalCredit += showClosed
                        ? summary.closedInvoiceTotal
                        : summary.currentInvoiceTotal;
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
                            fontSize: isTablet ? 10.sp : 12.sp,
                          ),
                        ),
                        Text(
                          formatter.format(totalCredit),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 10.sp : 12.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final card = cards[index];
                final summary = widget.cardController.getCardSummary(
                  allTransactions: transactions,
                  card: card,
                );

                final CardCycleDates cycle = widget.cardController
                    .computeCycleDates(
                        now, card.closingDay ?? 1, card.paymentDay ?? 1);

                final bool wasPaid = _isInvoicePaid(
                    card.id, card.name, cycle, card.paidInvoices);
                final bool afterClosing = !now.isBefore(cycle.openEnd);
                final bool beforePayment = !now.isAfter(cycle.paymentDate);
                final bool showClosedSection =
                    afterClosing && beforePayment && !wasPaid;

                final double limit = summary.totalLimit;
                final double available = summary.availableLimit;
                final double spent = summary.blockedTotal;

                final double ratio =
                    (limit > 0) ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                final double usagePercent = ratio * 100;

                Color progressColor;
                if (usagePercent <= 40) {
                  progressColor = const Color(0xFF16A34A);
                } else if (usagePercent <= 70) {
                  progressColor = const Color(0xFFF59E0B);
                } else {
                  progressColor = const Color(0xFFDC2626);
                }

                final String percentLabel =
                    '${usagePercent.toStringAsFixed(0)}%';

                String formatMonthDay(DateTime d) =>
                    DateFormat('d MMM', 'pt_BR').format(d).toLowerCase();
                final DateTime today = DateTime(now.year, now.month, now.day);
                final int daysUntilDue =
                    cycle.paymentDate.difference(today).inDays;

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
                    : DefaultColors.vibrantRed;

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
                            Get.to(
                                () => AddCardPage(isEditing: true, card: card));
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
                            _showDeleteCardDialog(context, theme, card);
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
                        _showActionModal(context, theme, card);
                      },
                      child: Container(
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
                            if (showClosedSection)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 14.h),
                                decoration: const BoxDecoration(
                                    color: Color(0xff9E9E9E)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Center(
                                          child: card.iconPath != null
                                              ? Image.asset(card.iconPath!,
                                                  width: 40.w, height: 40.h)
                                              : Icon(Icons.credit_card,
                                                  size: 18.sp,
                                                  color: Colors.white),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                card.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if ((card.bankName ?? '')
                                                  .isNotEmpty)
                                                Text(
                                                  card.bankName!,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.9),
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999.r),
                                            border:
                                                Border.all(color: Colors.white),
                                          ),
                                          child: Text(
                                            'Fechada',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(percentLabel,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    _UsageBar(
                                        ratio: ratio,
                                        progressColor: progressColor,
                                        isWhiteBg: true),
                                    SizedBox(height: 10.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _LimitInfoColumn(
                                            label: 'Limite disponível',
                                            value: formatter.format(available),
                                            isWhiteText: true),
                                        _LimitInfoColumn(
                                            label: 'Limite total',
                                            value: formatter.format(limit),
                                            isWhiteText: true,
                                            crossAlign: CrossAxisAlignment.end),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (!showClosedSection) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 14.h),
                                child: Row(
                                  children: [
                                    card.iconPath != null
                                        ? Image.asset(card.iconPath!,
                                            width: 40.w, height: 40.h)
                                        : Icon(Icons.credit_card, size: 20.sp),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.name,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if ((card.bankName ?? '').isNotEmpty)
                                            Text(
                                              card.bankName!,
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: DefaultColors.grey20),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(percentLabel,
                                            style: TextStyle(
                                                color: theme.primaryColor,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    _UsageBar(
                                        ratio: ratio,
                                        progressColor: progressColor,
                                        isWhiteBg: false),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _InvoiceInfoColumn(
                                        label: "Fatura atual",
                                        value: formatter.format(
                                            summary.currentInvoiceTotal),
                                        theme: theme,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _InvoiceInfoColumn(
                                        label: "Limite disponível",
                                        value: formatter.format(available),
                                        theme: theme,
                                        crossAlign: CrossAxisAlignment.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (showClosedSection) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 14.h),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(formatMonthDay(cycle.paymentDate),
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: DefaultColors.grey20,
                                                fontWeight: FontWeight.w600)),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 6.h),
                                          decoration: BoxDecoration(
                                              color: dueChipColor
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12.r)),
                                          child: Text(dueChipText,
                                              style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _InvoiceInfoColumn(
                                                label: 'total da fatura',
                                                value: formatter.format(
                                                    summary.closedInvoiceTotal),
                                                theme: theme)),
                                        Expanded(
                                            child: _InvoiceInfoColumn(
                                                label: 'próxima fatura',
                                                value: formatter.format(summary
                                                    .currentInvoiceTotal),
                                                theme: theme,
                                                crossAlign:
                                                    CrossAxisAlignment.end)),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.primaryColor,
                                          foregroundColor:
                                              theme.scaffoldBackgroundColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.h),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r)),
                                          elevation: 0,
                                        ),
                                        onPressed: () => _markInvoicePaid(
                                            card.id, card.name, cycle),
                                        child: Text('Pagar agora',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ));
  }

  void _showActionModal(BuildContext context, ThemeData theme, dynamic card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: DefaultColors.grey20.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(card.name,
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  SizedBox(height: 20.h),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Editar',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(modalContext);
                      Get.to(() => AddCardPage(isEditing: true, card: card));
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.sync,
                    label: 'Sincronizar Transações',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(modalContext);
                      _handleSyncTransactions(context, card);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Deletar',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(modalContext);
                      _showDeleteCardDialog(context, theme, card);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.close,
                    label: 'Cancelar',
                    color: DefaultColors.grey20,
                    onTap: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showDeleteCardDialog(
      BuildContext context, ThemeData theme, dynamic card) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Excluir cartão',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text('Tem certeza que deseja excluir o cartão ${card.name}?',
                textAlign: TextAlign.center,
                style: TextStyle(color: DefaultColors.grey20, fontSize: 13.sp)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              widget.cardController.deleteCard(card.id!);
              Navigator.pop(dialogContext);
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSyncTransactions(
      BuildContext context, dynamic card) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    final count =
        await widget.cardController.syncCardTransactions(card.id!, card.name);
    if (context.mounted) Navigator.pop(context);

    if (count > 0) {
      SnackbarHelper.showSuccess('$count transações sincronizadas');
    } else {
      final recoverCount = await widget.cardController
          .recoverCardTransactions(card.id!, card.name);
      if (recoverCount > 0) {
        SnackbarHelper.showSuccess('$recoverCount transações recuperadas');
      } else {
        SnackbarHelper.showInfo('Nenhuma transação pendente');
      }
    }
  }
}

class _UsageBar extends StatelessWidget {
  final double ratio;
  final Color progressColor;
  final bool isWhiteBg;

  const _UsageBar(
      {required this.ratio,
      required this.progressColor,
      required this.isWhiteBg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = constraints.maxWidth;
      return Stack(
        children: [
          Container(
            height: 8.h,
            width: barWidth,
            decoration: BoxDecoration(
                color: isWhiteBg
                    ? Colors.white.withOpacity(.25)
                    : Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999.r)),
          ),
          Container(
            height: 8.h,
            width: barWidth * ratio,
            decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(999.r)),
          ),
        ],
      );
    });
  }
}

class _LimitInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isWhiteText;
  final CrossAxisAlignment crossAlign;

  const _LimitInfoColumn(
      {required this.label,
      required this.value,
      required this.isWhiteText,
      this.crossAlign = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(label,
            style: TextStyle(
                color: isWhiteText
                    ? Colors.white.withOpacity(.85)
                    : DefaultColors.grey20,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 2.h),
        Text(value,
            style: TextStyle(
                color:
                    isWhiteText ? Colors.white : Theme.of(context).primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _InvoiceInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final CrossAxisAlignment crossAlign;

  const _InvoiceInfoColumn(
      {required this.label,
      required this.value,
      required this.theme,
      this.crossAlign = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                color: DefaultColors.grey20,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
        Text(value,
            style: TextStyle(
                fontSize: 14.sp,
                color: theme.primaryColor,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
