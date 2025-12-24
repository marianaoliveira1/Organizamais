import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../../utils/performance_helpers.dart';
import '../../../utils/snackbar_helper.dart';
import '../pages/add_card_page.dart';
import '../pages/invoice_details_page.dart';

// Dados de parcelamento para fatura (mensal) e bloqueio de limite
class _InstallmentData {
  final double monthlyAmount; // valor que cai na fatura do período
  final double blockedAmount; // valor bloqueado no limite

  const _InstallmentData({
    required this.monthlyAmount,
    required this.blockedAmount,
  });
}

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

  static _MyCardsWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyCardsWidgetState>();
  }

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
          // OTIMIZADO: Um único Obx ao invés de aninhados para evitar rebuilds desnecessários
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

            ({int? atual, int? total, String? description}) parseParcela(
                String title) {
              final regexFull = RegExp(
                  r'Parcela\s+(\d+)(?:\s+de\s+(\d+))?[:\-]?\s*(.+)?',
                  caseSensitive: false);
              final match = regexFull.firstMatch(title);
              if (match != null) {
                return (
                  atual: int.tryParse(match.group(1) ?? ''),
                  total: int.tryParse(match.group(2) ?? ''),
                  description: (match.group(3) ?? '').trim()
                );
              }
              return (atual: null, total: null, description: null);
            }

            _InstallmentData calculateInstallmentData(
              Iterable<TransactionModel> all,
              String cardName,
              DateTime start,
              DateTime end,
              bool? isTotalLimit,
            ) {
              final bool useTotalLimit = isTotalLimit ?? true;
              final cardNameLower = cardName.trim().toLowerCase();

              double monthlyTotal = 0.0;
              double blockedTotal = 0.0;

              final Map<String, int> seriesMaxAtual = {};
              final Map<String, double> seriesParcelValue = {};
              final Map<String, int> seriesParcelTotal = {};

              for (final t in all) {
                if (t.paymentDay == null) continue;
                if (t.type != TransactionType.despesa) continue;
                final String pt = (t.paymentType ?? '').trim().toLowerCase();
                if (pt != cardNameLower) continue;

                final DateTime? d =
                    PerformanceHelpers.safeParseDate(t.paymentDay!);
                if (d == null) continue;

                final double transactionValue =
                    PerformanceHelpers.parseCurrencyValue(t.value);
                final parcela = parseParcela(t.title);

                int? totalFromModel;
                try {
                  totalFromModel = (t as dynamic).installments as int?;
                } catch (_) {}

                final int? totalParcelas =
                    (totalFromModel != null && totalFromModel > 1)
                        ? totalFromModel
                        : parcela.total;

                final bool isParcelado =
                    (totalParcelas != null && totalParcelas > 1) ||
                        (parcela.atual != null);

                if (isParcelado) {
                  final int total = totalParcelas ?? (parcela.atual ?? 1);
                  final int atual = parcela.atual ?? 1;
                  final double parcelaValor = transactionValue;
                  final String description =
                      parcela.description?.isNotEmpty == true
                          ? parcela.description!
                          : t.title;

                  final String key =
                      '${description.toLowerCase()}|$pt|${parcelaValor.toStringAsFixed(2)}|$total';

                  seriesParcelValue[key] = parcelaValor;
                  seriesParcelTotal[key] = total;
                  if ((seriesMaxAtual[key] ?? 0) < atual) {
                    seriesMaxAtual[key] = atual;
                  }

                  // Fatura do período: só parcela que cai no range
                  if (!d.isBefore(start) && !d.isAfter(end)) {
                    monthlyTotal += parcelaValor;
                  }
                } else {
                  // Compra avulsa
                  // Só entra na fatura se estiver no período
                  if (!d.isBefore(start) && !d.isAfter(end)) {
                    monthlyTotal += transactionValue;
                  }

                  // Só bloqueia o limite se a compra for futura ou do ciclo atual/aberto
                  // Se for de um ciclo passado, assume-se que já foi paga e o limite liberado
                  if (!d.isBefore(start)) {
                    blockedTotal += transactionValue;
                  }
                }
              }

              // Bloqueio das séries parceladas
              seriesParcelValue.forEach((key, parcelaValor) {
                final int total = seriesParcelTotal[key] ?? 1;
                final int maxAtual = seriesMaxAtual[key] ?? 1;

                if (useTotalLimit) {
                  // Sistema de Limite Total: bloqueia todas as parcelas que faltam
                  // Se estamos na Parcela 3 de 10, faltam 8 parcelas para pagar (3,4,5,6,7,8,9,10)
                  final int parcelasPendentes = total - (maxAtual - 1);
                  blockedTotal += (parcelasPendentes * parcelaValor);
                } else {
                  // Sistema de Limite Parcelado: bloqueia apenas a parcela do mês
                  blockedTotal += parcelaValor;
                }
              });

              return _InstallmentData(
                monthlyAmount: monthlyTotal,
                blockedAmount: blockedTotal,
              );
            }

            // Soma despesas do cartão em um intervalo
            double sumTransactionsInRange(
              Iterable<TransactionModel> all,
              String cardName,
              DateTime start,
              DateTime end,
            ) {
              final cardNameLower = cardName.trim().toLowerCase();
              return all.where((t) {
                if (t.paymentDay == null) return false;
                if (t.type != TransactionType.despesa) return false;
                final String pt = (t.paymentType ?? '').trim().toLowerCase();
                if (pt != cardNameLower) return false;
                final d = PerformanceHelpers.safeParseDate(t.paymentDay!);
                if (d == null) return false;
                return !d.isBefore(start) && !d.isAfter(end);
              }).fold<double>(
                  0.0,
                  (sum, t) =>
                      sum + PerformanceHelpers.parseCurrencyValue(t.value));
            }

            _CycleDates computeCycleDates(
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

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final widgetState = _MyCardsWidgetState.of(context);
                // Rodapé com total gasto no crédito (dinâmico conforme estado da fatura)
                if (index == cards.length) {
                  double totalCredit = 0.0;
                  for (final c in cards) {
                    final int cClosing = c.closingDay ?? 1;
                    final int cPayment = c.paymentDay ?? 1;
                    final _CycleDates cyc =
                        computeCycleDates(now, cClosing, cPayment);

                    final instData = calculateInstallmentData(
                      transactions,
                      c.name,
                      cyc.openStart,
                      cyc.openEnd,
                      c.isTotalLimit,
                    );

                    final bool cInvoiceClosed = !now.isBefore(cyc.openStart) &&
                        !now.isAfter(cyc.paymentDate);
                    final bool cWasPaid =
                        widgetState?._isInvoicePaid(c.id, c.name, cyc) ?? false;
                    final bool cShowClosed = cInvoiceClosed && !cWasPaid;

                    if (cShowClosed) {
                      final closedData = calculateInstallmentData(
                        transactions,
                        c.name,
                        cyc.closedStart,
                        cyc.closedEnd,
                        c.isTotalLimit,
                      );
                      totalCredit += closedData.monthlyAmount;
                    } else {
                      totalCredit += instData.monthlyAmount;
                    }
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

                final int closingDay = card.closingDay ?? 1;
                final int paymentDay = card.paymentDay ?? 1;

                final _CycleDates cycle =
                    computeCycleDates(now, closingDay, paymentDay);

                final installmentData = calculateInstallmentData(
                  transactions,
                  card.name,
                  cycle.openStart,
                  cycle.openEnd,
                  card.isTotalLimit,
                );

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
                final bool isAfterOrOnClosingEvent =
                    !now.isBefore(cycle.openStart);
                final bool isBeforeOrOnPayment =
                    !now.isAfter(cycle.paymentDate);
                final bool invoiceClosed =
                    isAfterOrOnClosingEvent && isBeforeOrOnPayment;
                final bool wasMarkedPaid = widgetState?._isInvoicePaid(
                        card.id, card.name, cycle, card.paidInvoices) ??
                    false;
                final bool showClosedSection = invoiceClosed && !wasMarkedPaid;

                // Para a barra de progresso e "faltam X para o limite":
                // No padrão brasileiro, parcelamentos bloqueiam o limite TOTAL.
                // O valor 'spent' para fins de limite deve ser o blockedAmount.
                final double spent = installmentData.blockedAmount;

                final double limit = card.limit ?? 0.0;
                final bool hasLimit = limit > 0;
                final double usagePercent =
                    hasLimit ? (spent / limit) * 100.0 : 0.0;
                final double ratio = (usagePercent / 100).clamp(0.0, 1.0);
                final double remaining = limit - spent;
                // Cores por faixa de uso
                Color progressColor;
                if (usagePercent <= 40) {
                  progressColor = const Color(0xFF16A34A); // Verde
                } else if (usagePercent <= 70) {
                  progressColor = const Color(0xFFF59E0B); // Laranja
                } else {
                  progressColor = const Color(0xFFDC2626); // Vermelho
                }
                final String percentLabel =
                    '${(ratio * 100).toStringAsFixed(0)}%';
                // Labels de data e vencimento no estilo "upcoming payment"
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
                    : (daysUntilDue <= 2
                        ? DefaultColors.vibrantRed
                        : DefaultColors.vibrantRed);

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
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: theme.cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  side: BorderSide(
                                      color:
                                          theme.primaryColor.withOpacity(0.06)),
                                ),
                                insetPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 24.h),
                                titlePadding: EdgeInsets.zero,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                                actionsPadding:
                                    EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                                title: null,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 52.r,
                                      height: 52.r,
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor
                                            .withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.credit_card_off_outlined,
                                        color: theme.primaryColor,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Excluir cartão',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Tem certeza que deseja excluir o cartão ${card.name}?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: DefaultColors.grey20,
                                        fontSize: 13.sp,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: theme.primaryColor
                                                  .withOpacity(0.25),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24.r),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                                horizontal: 8.w),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24.r),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                                horizontal: 8.w),
                                            elevation: 0,
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            'Excluir',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
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
                        _showActionModal(context, theme, card);
                      },
                      child: Container(
                        padding: EdgeInsets.zero,
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
                              LayoutBuilder(builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.r),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w, vertical: 14.h),
                                      decoration: BoxDecoration(
                                          color: Color(0xff9E9E9E)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Center(
                                                child: card.iconPath != null
                                                    ? Image.asset(
                                                        card.iconPath!,
                                                        width: 40.w,
                                                        height: 40.h,
                                                      )
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
                                                            FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    if (card.bankName != null &&
                                                        (card.bankName ?? '')
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                      Text(
                                                        card.bankName!,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.9),
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999.r),
                                                  border: Border.all(
                                                      color: Colors.white),
                                                ),
                                                child: Text(
                                                  'Fechada',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.h),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                percentLabel,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          LayoutBuilder(builder:
                                              (context, innerConstraints) {
                                            final barWidth =
                                                innerConstraints.maxWidth;
                                            final progressWidth =
                                                barWidth * ratio;
                                            return Stack(
                                              children: [
                                                Container(
                                                  height: 8.h,
                                                  width: barWidth,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999.r),
                                                  ),
                                                ),
                                                Container(
                                                  height: 8.h,
                                                  width: progressWidth,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        progressColor
                                                            .withOpacity(0.85),
                                                        progressColor,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999.r),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                          SizedBox(height: 10.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Limite disponível',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.85),
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    formatter.format(remaining
                                                        .clamp(0, limit)),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Limite total',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.85),
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    formatter.format(limit),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            if (!showClosedSection) ...[
                              // header padrão (quando não está fechado)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 14.h),
                                child: Row(
                                  children: [
                                    Center(
                                      child: card.iconPath != null
                                          ? Image.asset(
                                              card.iconPath!,
                                              width: 40.w,
                                              height: 40.h,
                                            )
                                          : Icon(Icons.credit_card,
                                              size: 20.sp),
                                    ),
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
                                              padding:
                                                  EdgeInsets.only(top: 2.h),
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
                                  ],
                                ),
                              ),

                              SizedBox(height: 18.h),
                            ],

                            if (!showClosedSection) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasLimit)
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final barWidth = constraints.maxWidth;
                                          final progressWidth =
                                              barWidth * ratio;

                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                height: 10.h,
                                                width: barWidth,
                                                decoration: BoxDecoration(
                                                  color: theme.primaryColor
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.r),
                                                ),
                                              ),
                                              Container(
                                                height: 10.h,
                                                width: progressWidth,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      progressColor
                                                          .withOpacity(0.85),
                                                      progressColor,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.r),
                                                ),
                                              ),
                                              Positioned(
                                                left: (progressWidth - 20)
                                                    .clamp(0, barWidth - 40),
                                                top: -24.h,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: theme.cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.r),
                                                    border: Border.all(
                                                      color: theme.primaryColor
                                                          .withOpacity(0.08),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: theme.shadowColor
                                                            .withOpacity(0.05),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    percentLabel,
                                                    style: TextStyle(
                                                      color: theme.primaryColor,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 6.h),
                                        child: Text(
                                          'Defina o limite para acompanhar o uso',
                                          style: TextStyle(
                                            color: DefaultColors.grey20,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],

                            if (!showClosedSection) SizedBox(height: 12.h),

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

                            if (!showClosedSection) ...[
                              // valores dinâmicos (apenas quando não está fechada)
                              if (hasLimit)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Fatura atual",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: DefaultColors.grey20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              formatter.format(installmentData
                                                  .monthlyAmount),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Limite disponível",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: DefaultColors.grey20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              formatter.format(
                                                remaining.clamp(0, limit),
                                              ),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // if (hasLimit) ...[
                              //   SizedBox(height: 16.h),
                              //   Padding(
                              //     padding: EdgeInsets.symmetric(horizontal: 16.w),
                              //     child: Container(
                              //       padding: EdgeInsets.symmetric(
                              //           horizontal: 12.w, vertical: 10.h),
                              //       alignment: Alignment.center,
                              //       child: Text(
                              //         remaining >= 0
                              //             ? 'Limite disponível ${formatter.format(remaining)} '
                              //             : 'Ultrapassou o limite em ${formatter.format(-remaining)}',
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //           fontSize: 11.sp,
                              //           color: remaining >= 0
                              //               ? DefaultColors.textGrey
                              //               : DefaultColors.redDark,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ],
                            ],

                            SizedBox(height: 10.h),

                            // Status e valores por ciclo
                            if (showClosedSection) ...[
                              // Cabeçalho: Fatura do mês (exibir apenas quando a fatura estiver fechada e não paga)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 14.h),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                            color:
                                                dueChipColor.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                          foregroundColor:
                                              theme.scaffoldBackgroundColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) {
                                              final dialogTheme =
                                                  Theme.of(context);
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 30.w),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 22.w,
                                                      vertical: 22.h),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        dialogTheme.cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.r),
                                                    border: Border.all(
                                                      color: dialogTheme
                                                          .primaryColor
                                                          .withOpacity(0.06),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.12),
                                                        blurRadius: 24,
                                                        offset:
                                                            const Offset(0, 12),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                            12.w),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: DefaultColors
                                                              .green
                                                              .withOpacity(.12),
                                                        ),
                                                        child: Icon(
                                                          Iconsax.shield_tick,
                                                          color: DefaultColors
                                                              .green,
                                                          size: 26.sp,
                                                        ),
                                                      ),
                                                      SizedBox(height: 16.h),
                                                      Text(
                                                        'Fatura paga?',
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: dialogTheme
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      Text(
                                                        'Confirme se este cartão já foi quitado para arquivar a fatura atual.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: dialogTheme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color
                                                              ?.withOpacity(
                                                                  .75),
                                                          fontSize: 13.sp,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      SizedBox(height: 22.h),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                OutlinedButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false),
                                                              style:
                                                                  OutlinedButton
                                                                      .styleFrom(
                                                                foregroundColor:
                                                                    dialogTheme
                                                                        .primaryColor,
                                                                side:
                                                                    BorderSide(
                                                                  color: dialogTheme
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.4),
                                                                ),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              14.r),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10.h),
                                                                child: Text(
                                                                  'Ainda não',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14.sp),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 12.w),
                                                          Expanded(
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    dialogTheme
                                                                        .primaryColor,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              14.r),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10.h),
                                                                child: Text(
                                                                  'Sim',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: dialogTheme
                                                                        .cardColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (confirmed == true &&
                                              widgetState != null) {
                                            widgetState._markInvoicePaid(
                                                card.id, card.name, cycle);
                                          }
                                        },
                                        child: Text(
                                          'Já foi paga?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.sp,
                                            color: theme.cardColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: theme.cardColor,
                                              foregroundColor:
                                                  theme.primaryColor,
                                              side: BorderSide(
                                                  color: theme.primaryColor),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              minimumSize: Size(0, 40.h),
                                            ),
                                            onPressed: () {
                                              Get.to(() => InvoiceDetailsPage(
                                                    cardName: card.name,
                                                    periodStart:
                                                        cycle.closedStart,
                                                    periodEnd: cycle.closedEnd,
                                                    title: 'Fatura anterior',
                                                  ));
                                            },
                                            child: Text(
                                              'Ver fatura anterior',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.sp,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: theme.cardColor,
                                              foregroundColor:
                                                  theme.primaryColor,
                                              side: BorderSide(
                                                  color: theme.primaryColor),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              minimumSize: Size(0, 40.h),
                                            ),
                                            onPressed: () {
                                              Get.to(() => InvoiceDetailsPage(
                                                    cardName: card.name,
                                                    periodStart:
                                                        cycle.openStart,
                                                    periodEnd: cycle.openEnd,
                                                    title: 'Próxima fatura',
                                                  ));
                                            },
                                            child: Text(
                                              'Próxima fatura',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.sp,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Datas

                              SizedBox(height: 10.h),
                              // Links secundários
                            ] else ...[
                              // Fora do período de fatura fechada (fatura aberta)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Fecha dia',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: DefaultColors.grey20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                '$closingDay',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
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
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Paga dia',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: DefaultColors.grey20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                '$paymentDay',
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
                                    SizedBox(height: 12.h),
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
                                                BorderRadius.circular(12.r),
                                          ),
                                          elevation: 0,
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
                                          'Ver fatura',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: theme.cardColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                  Text(
                    card.name,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.edit,
                    label: 'Editar',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      // Usar o contexto original, não o do modal
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          Get.to(
                              () => AddCardPage(isEditing: true, card: card));
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.delete,
                    label: 'Deletar',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          _showDeleteCardDialog(context, theme, card);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.close,
                    label: 'Cancelar',
                    color: DefaultColors.grey20,
                    onTap: () => Navigator.of(modalContext).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCardDialog(
      BuildContext context, ThemeData theme, dynamic card) {
    final cardController = widget.cardController;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: theme.primaryColor.withOpacity(0.06)),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        title: null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_outlined,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Excluir cartão',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tem certeza que deseja excluir o cartão ${card.name}?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.primaryColor.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    elevation: 0,
                  ),
                  onPressed: () {
                    cardController.deleteCard(card.id!);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
