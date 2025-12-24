import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/card_controller.dart';
import '../../model/cards_model.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CardController cardController = Get.put(CardController());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Meus cartões",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 18.h),
              _buildHeaderCard(theme, cardController),
              SizedBox(height: 20.h),
              Obx(() {
                final cards = cardController.card;
                if (cards.isEmpty) {
                  return _buildEmptyState(theme);
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return _buildCardTile(theme, card);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, CardController cardController) {
    return Obx(() {
      final totalCards = cardController.card.length;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.credit_card,
                color: theme.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gerencie seus cartões',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    totalCards == 0
                        ? 'Cadastre um cartão para acompanhar limites e faturas.'
                        : '$totalCards ${totalCards == 1 ? 'cartão' : 'cartões'} com limites e datas acompanhadas.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_off_outlined,
              color: theme.primaryColor,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhum cartão cadastrado',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Adicione um cartão para sincronizar parcelas, limites e datas de vencimento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile(ThemeData theme, CardsModel card) {
    final hasIcon = card.iconPath != null && card.iconPath!.isNotEmpty;
    final limitText = _formatCurrency(card.limit);
    final closingDay =
        card.closingDay != null ? 'Fecha dia ${card.closingDay}' : null;
    final paymentDay =
        card.paymentDay != null ? 'Paga dia ${card.paymentDay}' : null;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: hasIcon
                ? Image.asset(card.iconPath!, width: 30.w, height: 30.w)
                : Icon(Icons.credit_card,
                    color: theme.primaryColor, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                if ((card.bankName ?? '').isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    card.bankName!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor.withOpacity(0.6),
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  'Limite ${limitText ?? 'não informado'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    if (closingDay != null)
                      _CardInfoChip(
                        icon: Icons.calendar_today_outlined,
                        text: closingDay,
                        theme: theme,
                      ),
                    if (paymentDay != null) ...[
                      SizedBox(width: 8.w),
                      _CardInfoChip(
                        icon: Icons.payments_outlined,
                        text: paymentDay,
                        theme: theme,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _formatCurrency(double? value) {
    if (value == null || value <= 0) return null;
    final formatter =
        NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2);
    return formatter.format(value);
  }
}

class _CardInfoChip extends StatelessWidget {
  const _CardInfoChip({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: theme.primaryColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
