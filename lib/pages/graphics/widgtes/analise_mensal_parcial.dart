import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../ads_banner/ads_banner.dart';

import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

class AnaliseMensalParcialWidget extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final Color? categoryColor;
  final String?
      selectedMonthName; // opcional, usado apenas para consistência visual

  const AnaliseMensalParcialWidget({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.selectedMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final TransactionController tx = Get.find<TransactionController>();

    final DateTime now = DateTime.now();
    final int dayLimit = now.day; // 1..hoje

    // Filtra transações relevantes
    final List<TransactionModel> all = tx.transaction
        .where((t) =>
            t.paymentDay != null &&
            t.type == TransactionType.despesa &&
            t.category == categoryId)
        .toList();

    if (all.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(categoryName)),
        body: Center(
          child: Text('Sem transações para esta categoria'),
        ),
      );
    }

    // Determina primeiro mês com dados e cria o intervalo
    all.sort((a, b) =>
        DateTime.parse(a.paymentDay!).compareTo(DateTime.parse(b.paymentDay!)));
    final DateTime firstDate = DateTime.parse(all.first.paymentDay!);
    final DateTime firstMonth = DateTime(firstDate.year, firstDate.month, 1);
    // Primeiro mês a exibir: um mês ANTES do primeiro mês com dados (ex.: se começa em Março, mostrar Fevereiro)
    DateTime startMonth = DateTime(firstMonth.year, firstMonth.month - 1, 1);
    final DateTime endMonth = DateTime(now.year, now.month, 1);

    // Constrói a lista de meses em ordem decrescente (mais recente primeiro)
    final List<DateTime> months = [];
    DateTime cursor = endMonth;
    while (!(cursor.year < startMonth.year ||
        (cursor.year == startMonth.year && cursor.month < startMonth.month))) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }

    String monthNamePt(int m) {
      const ms = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro',
      ];
      return ms[(m - 1).clamp(0, 11)];
    }

    double sumForRange(DateTime start, DateTime end) {
      double total = 0;
      for (final t in all) {
        final d = DateTime.parse(t.paymentDay!);
        if (!d.isBefore(start) && !d.isAfter(end)) {
          total += double.tryParse(
                  t.value.replaceAll('.', '').replaceAll(',', '.')) ??
              0.0;
        }
      }
      return total;
    }

    Color chipColor(double current, double previous) {
      if (previous == 0 && current == 0) return DefaultColors.grey;
      if (current < previous) return DefaultColors.greenDark;
      if (current > previous) return DefaultColors.redDark;
      return DefaultColors.grey;
    }

    String pctText(double current, double previous) {
      if (previous == 0) {
        if (current == 0) return '0.0%';
        return '100.0%'; // quando não há base anterior
      }
      final pct = ((current - previous) / previous) * 100.0;
      final s = pct.abs().toStringAsFixed(1);
      return pct >= 0 ? '+$s%' : '-$s%';
    }

    String diffText(double current, double previous, NumberFormat f) {
      final diff = current - previous;
      final s = f.format(diff.abs());
      return diff >= 0 ? '(+$s)' : '(-$s)';
    }

    Widget header() {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: DefaultColors.grey20.withOpacity(.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: (categoryIcon != null && categoryIcon!.isNotEmpty)
                  ? Image.asset(categoryIcon!, fit: BoxFit.contain)
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Acompanhe seus gastos mensais',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(.9),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    Widget monthTile(DateTime month) {
      final int y = month.year;
      final int m = month.month;
      final int prevM = m == 1 ? 12 : m - 1;
      final int prevY = m == 1 ? y - 1 : y;

      final int daysInCurrent = DateTime(y, m + 1, 0).day;
      final int daysInPrev = DateTime(prevY, prevM + 1, 0).day;
      final int endDayCurrent = dayLimit.clamp(1, daysInCurrent);
      final int endDayPrev = dayLimit.clamp(1, daysInPrev);

      final DateTime startCurrent = DateTime(y, m, 1);
      final DateTime endCurrent = DateTime(y, m, endDayCurrent, 23, 59, 59);
      final DateTime startPrev = DateTime(prevY, prevM, 1);
      final DateTime endPrev = DateTime(prevY, prevM, endDayPrev, 23, 59, 59);

      final double curr = sumForRange(startCurrent, endCurrent);
      final double prev = sumForRange(startPrev, endPrev);
      final Color c = chipColor(curr, prev);
      final String pText = pctText(curr, prev);
      final String dText = diffText(curr, prev, currency);

      String dd(int n) => n.toString().padLeft(2, '0');
      final String title = '1-${dd(endDayCurrent)} de ${monthNamePt(m)} de $y';

      return Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        currency.format(curr),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: (c == DefaultColors.grey)
                          ? DefaultColors.grey20.withOpacity(.12)
                          : c.withOpacity(.12),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: (c == DefaultColors.grey)
                            ? DefaultColors.grey20.withOpacity(.4)
                            : c.withOpacity(.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          curr < prev
                              ? Icons.arrow_downward_rounded
                              : (curr > prev
                                  ? Icons.arrow_upward_rounded
                                  : Icons.remove_rounded),
                          size: 14.sp,
                          color: c,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '$pText  $dText',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: c,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Comparação por dia')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          AdsBanner(),
          SizedBox(height: 12.h),
          header(),
          SizedBox(height: 12.h),
          ...months.map(monthTile),
          SizedBox(height: 12.h),
          AdsBanner(),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
