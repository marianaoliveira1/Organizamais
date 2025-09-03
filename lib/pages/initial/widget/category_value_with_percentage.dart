import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../model/percentage_result.dart';
import '../../../widgetes/percentage_display_widget.dart';
import '../../../widgetes/percentage_explanation_dialog.dart';

class CategoryValueWithPercentage extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final PercentageResult? percentageResult;
  final PercentageExplanationType? explanationType;
  final double? currentValue;
  final double? previousValue;

  const CategoryValueWithPercentage({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.percentageResult,
    this.explanationType,
    this.currentValue,
    this.previousValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44.h,
          width: 2.w,
          color: color,
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                (((explanationType != null &&
                            currentValue != null &&
                            previousValue != null) ||
                        (percentageResult != null && percentageResult!.hasData))
                    ? Row(
                        children: [
                          SizedBox(width: 6.w),
                          PercentageDisplayWidget(
                            result:
                                percentageResult ?? PercentageResult.noData(),
                            explanationType: explanationType,
                            currentValue: currentValue,
                            previousValue: previousValue,
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            SizedBox(height: 4.h),
            // Valor da categoria
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
