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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            color: DefaultColors.grey,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
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
