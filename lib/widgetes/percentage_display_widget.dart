import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/percentage_result.dart';
import 'percentage_explanation_dialog.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/color.dart';

class PercentageDisplayWidget extends StatelessWidget {
  final PercentageResult result;
  final bool showTooltip;
  final PercentageExplanationType? explanationType;
  final double? currentValue;
  final double? previousValue;
  final double? textFontSizeSp;

  const PercentageDisplayWidget({
    super.key,
    required this.result,
    this.showTooltip = false,
    this.explanationType,
    this.currentValue,
    this.previousValue,
    this.textFontSizeSp,
  });

  @override
  Widget build(BuildContext context) {
    // Derive an effective result using current/previous values when available
    PercentageResult? derived;
    if (explanationType != null &&
        currentValue != null &&
        previousValue != null) {
      final double prev = previousValue!;
      final double curr = currentValue!;

      if (prev == 0) {
        // Sem base comparável: mostrar 0.0% em vez de "Novo"
        derived = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );
      } else {
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

        derived = PercentageResult(
          percentage: computedPercent.abs(),
          hasData: true,
          type: type,
          displayText: displayText,
        );
      }
    }

    final PercentageResult effectiveResult = derived ?? result;
    if (!effectiveResult.hasData) {
      return const SizedBox.shrink();
    }

    // Determine icon and circle color based on current/previous when available,
    // otherwise fall back to effectiveResult.type semantics
    IconData iconData;
    Color circleColor;
    if (explanationType != null &&
        currentValue != null &&
        previousValue != null) {
      final double prev = previousValue!;
      final double curr = currentValue!;
      final bool isEqual = curr == prev;
      if (isEqual) {
        iconData = Iconsax.more_circle;
        circleColor = DefaultColors.grey;
      } else if (curr > prev) {
        iconData = Iconsax.arrow_circle_up;
        // Para despesas, aumento é ruim (vermelho), para outros é bom (verde)
        circleColor = explanationType == PercentageExplanationType.expense
            ? DefaultColors.redDark
            : DefaultColors.greenDark;
      } else {
        iconData = Iconsax.arrow_circle_down;
        // Para despesas, diminuição é bom (verde), para outros é ruim (vermelho)
        circleColor = explanationType == PercentageExplanationType.expense
            ? DefaultColors.greenDark
            : DefaultColors.redDark;
      }
    } else {
      switch (effectiveResult.type) {
        case PercentageType.positive:
          iconData = Iconsax.arrow_circle_up;
          circleColor = DefaultColors.greenDark;
          break;
        case PercentageType.negative:
          iconData = Iconsax.arrow_circle_down;
          circleColor = DefaultColors.redDark;
          break;
        case PercentageType.neutral:
          iconData = Iconsax.more_circle;
          circleColor = DefaultColors.grey;
          break;
        case PercentageType.newData:
          iconData = Iconsax.star_1;
          circleColor = DefaultColors.grey;
          break;
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
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              effectiveResult.formattedPercentage,
              style: TextStyle(
                fontSize: (textFontSizeSp ?? 10.sp),
                fontWeight: FontWeight.w600,
                color: circleColor,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              iconData,
              size: 12.sp,
              color: circleColor,
            ),
          ],
        ),
      ),
    );
  }
}
