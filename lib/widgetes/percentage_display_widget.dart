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
    // Sempre calcular usando valores locais quando disponíveis
    PercentageResult effectiveResult;

    if (explanationType != null &&
        currentValue != null &&
        previousValue != null) {
      final double prev = previousValue!;
      final double curr = currentValue!;

      // Se ambos são zero, mostrar 0.0%
      if (prev.abs() < 0.01 && curr.abs() < 0.01) {
        effectiveResult = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );
      } else {
        double computedPercent;

        // Se valor anterior é zero mas atual tem valor, calcular como aumento infinito
        if (prev.abs() < 0.01 && curr.abs() >= 0.01) {
          // Mostrar uma porcentagem muito grande para indicar aumento infinito
          computedPercent = 999.9; // Representa aumento infinito
        } else {
          // Calcular porcentagem normal: ((atual - anterior) / anterior) * 100
          double referencePrev = prev;
          if (explanationType == PercentageExplanationType.balance &&
              prev.abs() >= 0.01) {
            // Para saldo, comparar usando o módulo do valor anterior para evitar
            // porcentagens negativas quando o saldo anterior era negativo.
            referencePrev = prev.abs();
          }
          computedPercent = ((curr - prev) / referencePrev) * 100.0;
        }

        // Determinar tipo baseado no sinal e no tipo de transação
        PercentageType type;
        if (explanationType == PercentageExplanationType.expense) {
          // Para despesas: diminuição é bom (positivo), aumento é ruim (negativo)
          type = computedPercent < 0
              ? PercentageType.positive
              : (computedPercent > 0
                  ? PercentageType.negative
                  : PercentageType.neutral);
        } else {
          // Para receita/saldo: aumento é bom (positivo), diminuição é ruim (negativo)
          type = computedPercent > 0
              ? PercentageType.positive
              : (computedPercent < 0
                  ? PercentageType.negative
                  : PercentageType.neutral);
        }

        // Formatar texto da porcentagem
        String displayText;
        if (computedPercent.abs() < 0.01) {
          displayText = '0.0%';
        } else {
          final String sign = computedPercent > 0 ? '+' : '';
          displayText = '$sign${computedPercent.toStringAsFixed(1)}%';
        }

        effectiveResult = PercentageResult(
          percentage: computedPercent.abs(),
          hasData: true,
          type: type,
          displayText: displayText,
        );
      }
    } else {
      // Usar result quando não temos valores locais
      effectiveResult = result;
    }

    // Se não tem dados e não temos valores locais, não mostrar nada
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

      // Usar tolerância para comparação de igualdade (evitar problemas com ponto flutuante)
      final bool isEqual = (curr - prev).abs() < 0.01;
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
              effectiveResult.displayText,
              style: TextStyle(
                fontSize: (textFontSizeSp ?? 12.sp),
                fontWeight: FontWeight.w600,
                color: circleColor,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              iconData,
              size: 15.sp,
              color: circleColor,
            ),
          ],
        ),
      ),
    );
  }
}
