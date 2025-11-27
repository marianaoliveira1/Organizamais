import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/card_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/cards_model.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../../widgetes/info_card.dart';
import '../../transaction/pages/category_page.dart';
import 'invoice_categories_breakdown_page.dart';

class InvoiceDetailsPage extends StatelessWidget {
  const InvoiceDetailsPage({
    super.key,
    required this.cardName,
    required this.periodStart,
    required this.periodEnd,
    required this.title,
  });

  final String cardName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final TransactionController txController =
        Get.find<TransactionController>();
    final CardController cardController = Get.find<CardController>();

    double parseAmount(String raw) {
      String s = raw.replaceAll('R\$', '').trim();
      if (s.contains(',')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(s) ?? 0.0;
      }
      s = s.replaceAll(' ', '');
      return double.tryParse(s) ?? 0.0;
    }

    final cardNameLower = cardName.trim().toLowerCase();
    List<TransactionModel> list = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      final String pt = (t.paymentType ?? '').trim().toLowerCase();
      if (pt != cardNameLower) return false;
      DateTime d;
      try {
        d = DateTime.parse(t.paymentDay!);
      } catch (_) {
        return false;
      }
      return !d.isBefore(periodStart) && !d.isAfter(periodEnd);
    }).toList()
      ..sort((a, b) {
        final da = DateTime.tryParse(a.paymentDay ?? '') ?? DateTime(1900);
        final db = DateTime.tryParse(b.paymentDay ?? '') ?? DateTime(1900);
        return db.compareTo(da);
      });

    final double total = list.fold(0.0, (sum, t) => sum + parseAmount(t.value));

    String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

    // Buscar informações do cartão
    CardsModel? card;
    try {
      card = cardController.card.firstWhere(
        (c) => c.name == cardName,
      );
    } catch (_) {
      card = null;
    }
    final double cardLimit = card?.limit ?? 0.0;
    final bool hasLimit = cardLimit > 0;
    final double usagePercent =
        hasLimit ? (total / cardLimit * 100).clamp(0.0, 100.0) : 0.0;
    final double remaining =
        hasLimit ? (cardLimit - total).clamp(0.0, cardLimit) : 0.0;

    // Calcular dias até o fim do período
    final DateTime now = DateTime.now();
    final int daysUntilEnd = periodEnd.difference(now).inDays;
    final String daysText = daysUntilEnd > 0
        ? '$daysUntilEnd ${daysUntilEnd == 1 ? 'dia' : 'dias'}'
        : daysUntilEnd == 0
            ? 'Hoje'
            : 'Encerrado';

    // Cor da barra de progresso baseada no uso
    Color progressColor;
    if (usagePercent <= 40) {
      progressColor = const Color(0xFF16A34A); // Verde
    } else if (usagePercent <= 70) {
      progressColor = const Color(0xFFF59E0B); // Laranja
    } else {
      progressColor = const Color(0xFFDC2626); // Vermelho
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdsBanner(),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do cartão
                  Text(
                    cardName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Período e dias restantes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Período: ${formatDate(periodStart)} a ${formatDate(periodEnd)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.textGrey,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Faltam $daysText',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  // Informações de limite
                  if (hasLimit) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Limite usado',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          '${currency.format(total)} de ${currency.format(cardLimit)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    // Barra de progresso estilizada
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth;
                        final ratio = (usagePercent / 100).clamp(0.0, 1.0);
                        final progressWidth = barWidth * ratio;
                        final percentLabel =
                            '${usagePercent.toStringAsFixed(0)}%';

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 10.h,
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
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
                            Positioned(
                              left:
                                  (progressWidth - 20).clamp(0, barWidth - 40),
                              top: -24.h,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.08),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          theme.shadowColor.withOpacity(0.05),
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
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Faltam ${currency.format(remaining)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: DefaultColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${usagePercent.toStringAsFixed(1)}% usado',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    // Divisor
                    Container(
                      height: 1.h,
                      color: theme.primaryColor.withOpacity(0.08),
                    ),
                    SizedBox(height: 18.h),
                  ],
                  // Total gasto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total gasto',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        currency.format(total),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            InfoCard(
              title: 'Visão por Categoria',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoiceCategoriesBreakdownPage(
                      cardName: cardName,
                      periodStart: periodStart,
                      periodEnd: periodEnd,
                    ),
                  ),
                );
              },
              backgroundColor: theme.cardColor,
              content: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Iconsax.wallet,
                        color: theme.primaryColor, size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Acompanhe em detalhes cada categoria em que você utilizou seu dinheiro ao longo do mês.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.primaryColor),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Text(
              "Transações",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: DefaultColors.grey20,
              ),
            ),
            SizedBox(height: 12.h),
            list.isEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text(
                        'Nenhuma transação no período',
                        style: TextStyle(color: DefaultColors.grey20),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...list.map((t) {
                        final d = DateTime.tryParse(t.paymentDay ?? '') ??
                            DateTime(1900);
                        final categoryData = findCategoryById(t.category);
                        final categoryName =
                            categoryData?['name'] ?? 'Sem categoria';

                        return Container(
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Row com nome da transação e valor
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    currency.format(parseAmount(t.value)),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              // Row com data e categoria
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(d),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.textGrey,
                                    ),
                                  ),
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: DefaultColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
