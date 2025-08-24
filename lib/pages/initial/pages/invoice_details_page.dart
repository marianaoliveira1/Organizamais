import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';

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

    double _parseAmount(String raw) {
      String s = raw.replaceAll('R\$', '').trim();
      if (s.contains(',')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(s) ?? 0.0;
      }
      s = s.replaceAll(' ', '');
      return double.tryParse(s) ?? 0.0;
    }

    List<TransactionModel> list = txController.transaction.where((t) {
      if (t.paymentDay == null) return false;
      if (t.type != TransactionType.despesa) return false;
      if ((t.paymentType ?? '') != cardName) return false;
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

    final double total =
        list.fold(0.0, (sum, t) => sum + _parseAmount(t.value));

    String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdsBanner(),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Período: ${formatDate(periodStart)} a ${formatDate(periodEnd)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: DefaultColors.grey20,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        currency.format(total),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma transação no período',
                        style: TextStyle(color: DefaultColors.grey20),
                      ),
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(height: 6.h),
                      itemBuilder: (_, i) {
                        final t = list[i];
                        final d = DateTime.tryParse(t.paymentDay ?? '') ??
                            DateTime(1900);
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(d),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DefaultColors.grey20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                currency.format(_parseAmount(t.value)),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
