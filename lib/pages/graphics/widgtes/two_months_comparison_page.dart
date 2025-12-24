import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

class TwoMonthsComparisonPage extends StatelessWidget {
  final int categoryId;
  final String title;
  final String? iconPath;
  final String? selectedMonthName; // e.g. "Março/2025" ou "Março"

  const TwoMonthsComparisonPage({
    super.key,
    required this.categoryId,
    required this.title,
    this.iconPath,
    this.selectedMonthName,
  });

  // Retorna número do mês (1-12) a partir de string com ou sem acento/abreviação
  static int? _extractMonthNumber(String raw) {
    String s = raw.toLowerCase();
    // remove acentos básicos
    s = s
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');

    final Map<String, int> map = {
      'jan': 1,
      'janeiro': 1,
      'fev': 2,
      'fevereiro': 2,
      'mar': 3,
      'marco': 3,
      'março': 3,
      'abr': 4,
      'abril': 4,
      'mai': 5,
      'maio': 5,
      'jun': 6,
      'junho': 6,
      'jul': 7,
      'julho': 7,
      'ago': 8,
      'agosto': 8,
      'set': 9,
      'setembro': 9,
      'out': 10,
      'outubro': 10,
      'nov': 11,
      'novembro': 11,
      'dez': 12,
      'dezembro': 12,
    };

    for (final entry in map.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final tx = Get.find<TransactionController>();

    // Resolve mês/ano com base no selecionado; fallback para agora
    final DateTime now = DateTime.now();
    int curYear = now.year;
    int curMonth = now.month;
    if (selectedMonthName != null && selectedMonthName!.trim().isNotEmpty) {
      final String raw = selectedMonthName!.trim();
      // Detecta ano (4 dígitos) onde estiver
      final yearMatch = RegExp(r'(19|20)\d{2}').firstMatch(raw);
      if (yearMatch != null) {
        curYear = int.tryParse(yearMatch.group(0)!) ?? now.year;
      }
      // Extrai mês de forma robusta (ignora acentos, case e aceita abreviações)
      final int? m = _extractMonthNumber(raw);
      if (m != null) curMonth = m;
    }
    final int prevMonth = curMonth == 1 ? 12 : curMonth - 1;
    final int prevYear = curMonth == 1 ? curYear - 1 : curYear;

    List<TransactionModel> forMonth(int y, int m) {
      final DateTime start = DateTime(y, m, 1);
      final DateTime end = DateTime(y, m + 1, 0, 23, 59, 59);
      final list = tx.transaction.where((t) {
        if (t.paymentDay == null) return false;
        if (t.category != categoryId) return false;
        if (t.type != TransactionType.despesa) return false;
        final d = DateTime.parse(t.paymentDay!);
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();
      // ordem decrescente (mais recente primeiro)
      list.sort((a, b) => DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!)));
      return list;
    }

    final List<TransactionModel> currentList = forMonth(curYear, curMonth);
    final List<TransactionModel> previousList = forMonth(prevYear, prevMonth);

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
              child: (iconPath != null && iconPath!.isNotEmpty)
                  ? Image.asset(iconPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink())
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.primaryColor,
                      )),
                  SizedBox(height: 6.h),
                  Text(
                    '${_monthNamePt(prevMonth)}/$prevYear  ×  ${_monthNamePt(curMonth)}/$curYear',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor.withOpacity(.9)),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    Widget buildColumn(String label, List<TransactionModel> list) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                )),
            SizedBox(height: 8.h),
            if (list.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Sem transações',
                    style:
                        TextStyle(fontSize: 12.sp, color: DefaultColors.grey)),
              ),
            ...list.map((t) {
              final d = DateTime.parse(t.paymentDay!);
              final String date = DateFormat('dd/MM').format(d);
              final double value = double.tryParse(
                      t.value.replaceAll('.', '').replaceAll(',', '.')) ??
                  0.0;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency.format(value),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(date,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: DefaultColors.grey,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Divider(
                      color: DefaultColors.grey20.withOpacity(.5),
                      height: 1,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdsBanner(),
            SizedBox(height: 12.h),
            header(),
            SizedBox(height: 12.h),
            AdsBanner(),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: buildColumn(
                    '${_monthNamePt(prevMonth)} de $prevYear',
                    previousList,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: buildColumn(
                    '${_monthNamePt(curMonth)} de $curYear',
                    currentList,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            AdsBanner(),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  static String _monthNamePt(int m) {
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
      'Dezembro'
    ];
    return ms[(m - 1).clamp(0, 11)];
  }
}
