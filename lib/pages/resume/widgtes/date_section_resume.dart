import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

import '../../../utils/color.dart';
import 'transaction_item.dart';

class DateSectionResume extends StatelessWidget {
  final String date;
  final List transactions;
  final NumberFormat formatter;

  const DateSectionResume({
    super.key,
    required this.date,
    required this.transactions,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular totais por dia
    double totalReceita = 0.0;
    double totalDespesa = 0.0;

    for (final t in transactions) {
      try {
        final String raw = t.value as String;
        final double valor =
            double.parse(raw.replaceAll('.', '').replaceAll(',', '.'));
        if (t.type.toString().contains('receita')) {
          totalReceita += valor;
        } else if (t.type.toString().contains('despesa')) {
          totalDespesa += valor;
        }
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            color: DefaultColors.grey,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Despesas: ${formatter.format(totalDespesa)}',
              style: TextStyle(
                color: DefaultColors.redDark,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (totalReceita > 0) SizedBox(width: 8.w),
            if (totalReceita > 0)
              Text(
                'Receitas: ${formatter.format(totalReceita)}',
                style: TextStyle(
                  color: DefaultColors.greenDark,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        ...transactions.map(
          (transaction) => TransactionItem(
            transaction: transaction,
            formatter: formatter,
          ),
        ),
      ],
    );
  }
}
