import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../ads_banner/ads_banner.dart';
import '../model/percentage_result.dart';
import '../utils/color.dart';

enum PercentageExplanationType {
  balance,
  income,
  expense,
}

class PercentageExplanationDialog extends StatelessWidget {
  final PercentageResult result;
  final PercentageExplanationType type;
  final double currentValue;
  final double previousValue;

  const PercentageExplanationDialog({
    super.key,
    required this.result,
    required this.type,
    required this.currentValue,
    required this.previousValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            result.icon,
            color: result.color,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _getTitle(),
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdsBanner(),
          SizedBox(
            height: 10.h,
          ),
          // Indicador visual
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: result.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: result.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  result.icon,
                  color: result.color,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  result.formattedPercentage,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: result.color,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Explicação
          Text(
            _getExplanation(),
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // Comparação de valores
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Mês anterior (mesmo período):',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Text(
                      formatter.format(previousValue),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Mês atual (até hoje):',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Text(
                      formatter.format(currentValue),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color: DefaultColors.grey.withValues(alpha: 0.3)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Diferença:',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${currentValue >= previousValue ? '+' : ''}${formatter.format(currentValue - previousValue)}',
                      style: TextStyle(
                        color: result.color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // Nota explicativa
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: DefaultColors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: DefaultColors.grey,
                  size: 14.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _getNote(),
                    style: TextStyle(
                      color: DefaultColors.grey,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Ok',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (type) {
      case PercentageExplanationType.balance:
        return 'Comparação do Saldo';
      case PercentageExplanationType.income:
        return 'Comparação das Receitas';
      case PercentageExplanationType.expense:
        return 'Comparação das Despesas';
    }
  }

  String _getExplanation() {
    final isPositive = result.type == PercentageType.positive;
    final isNeutral = result.type == PercentageType.neutral;
    final isNew = result.type == PercentageType.newData;

    if (isNew) {
      return 'Este é o primeiro mês com dados ou não há informações do mês anterior para comparação.';
    }

    if (isNeutral) {
      return 'Os valores são exatamente iguais ao mesmo período do mês anterior.';
    }

    switch (type) {
      case PercentageExplanationType.balance:
        if (isPositive) {
          return 'Seu saldo está ${result.percentage.toStringAsFixed(1)}% melhor comparado ao mesmo período do mês anterior. Isso significa que você está economizando mais ou ganhando mais dinheiro.';
        } else {
          return 'Seu saldo está ${result.percentage.toStringAsFixed(1)}% pior comparado ao mesmo período do mês anterior. Isso pode indicar mais gastos ou menos receitas.';
        }

      case PercentageExplanationType.income:
        if (isPositive) {
          return 'Suas receitas aumentaram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Parabéns! Você está ganhando mais dinheiro.';
        } else {
          return 'Suas receitas diminuíram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Pode ser útil revisar suas fontes de renda.';
        }

      case PercentageExplanationType.expense:
        if (isPositive) {
          return 'Suas despesas diminuíram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Excelente! Você está gastando menos.';
        } else {
          return 'Suas despesas aumentaram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Considere revisar seus gastos.';
        }
    }
  }

  String _getNote() {
    final today = DateTime.now();
    return 'A comparação é feita entre o período de 1º até o dia ${today.day} do mês atual versus o mesmo período do mês anterior. Isso garante uma comparação justa entre períodos equivalentes.';
  }
}
