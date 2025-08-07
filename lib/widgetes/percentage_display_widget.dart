import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/percentage_result.dart';
import 'percentage_explanation_dialog.dart';

class PercentageDisplayWidget extends StatelessWidget {
  final PercentageResult result;
  final bool showTooltip;
  final PercentageExplanationType? explanationType;
  final double? currentValue;
  final double? previousValue;

  const PercentageDisplayWidget({
    super.key,
    required this.result,
    this.showTooltip = false,
    this.explanationType,
    this.currentValue,
    this.previousValue,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.hasData) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        if (explanationType != null &&
            currentValue != null &&
            previousValue != null) {
          showDialog(
            context: context,
            builder: (context) => PercentageExplanationDialog(
              result: result,
              type: explanationType!,
              currentValue: currentValue!,
              previousValue: previousValue!,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.icon,
              size: 12.sp,
              color: result.color,
            ),
            SizedBox(width: 2.w),
            Text(
              result.formattedPercentage,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: result.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
