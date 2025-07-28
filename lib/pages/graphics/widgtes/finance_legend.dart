import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../utils/color.dart';

class FinanceLegend extends StatelessWidget {
  final String title;
  final Color color;
  final double percent;
  final num value;
  final NumberFormat formatter;

  const FinanceLegend({
    super.key,
    required this.title,
    required this.color,
    required this.percent,
    required this.value,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 12.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  "${percent.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DefaultColors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
