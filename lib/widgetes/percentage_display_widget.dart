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

    // Derive an effective result using current/previous values when available
    PercentageResult effectiveResult = result;
    if (explanationType != null &&
        currentValue != null &&
        previousValue != null) {
      final double prev = previousValue!;
      final double curr = currentValue!;

      if (prev != 0) {
        final double computedPercent = ((curr - prev) / prev.abs()) * 100.0;

        PercentageType type;
        if (explanationType == PercentageExplanationType.expense) {
          // Expense: decrease is positive (good), increase is negative (bad)
          if (computedPercent < 0) {
            type = PercentageType.positive;
          } else if (computedPercent > 0) {
            type = PercentageType.negative;
          } else {
            type = PercentageType.neutral;
          }
        } else {
          // Income/balance: increase is positive, decrease is negative
          if (computedPercent > 0) {
            type = PercentageType.positive;
          } else if (computedPercent < 0) {
            type = PercentageType.negative;
          } else {
            type = PercentageType.neutral;
          }
        }

        String displayText;
        switch (type) {
          case PercentageType.positive:
            displayText = '+${computedPercent.abs().toStringAsFixed(1)}%';
            break;
          case PercentageType.negative:
            displayText = '-${computedPercent.abs().toStringAsFixed(1)}%';
            break;
          case PercentageType.neutral:
            displayText = '0.0%';
            break;
          case PercentageType.newData:
            displayText = 'Novo';
            break;
        }

        effectiveResult = PercentageResult(
          percentage: computedPercent.abs(),
          hasData: true,
          type: type,
          displayText: displayText,
        );
      }
    }

    return GestureDetector(
      onTap: () {
        if (explanationType != null &&
            currentValue != null &&
            previousValue != null) {
          showDialog(
            context: context,
            builder: (context) => PercentageExplanationDialog(
              result: effectiveResult,
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
              effectiveResult.icon,
              size: 12.sp,
              color: effectiveResult.color,
            ),
            SizedBox(width: 2.w),
            Text(
              effectiveResult.formattedPercentage,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: effectiveResult.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
