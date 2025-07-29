import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../model/percentage_result.dart';
import '../../../utils/color.dart';

enum PercentageExplanationTypeWiget {
  balance,
  income,
  expense,
}

class PorcentageExplanationFinanceDetailsPage extends StatelessWidget {
  final PercentageResult result;
  final PercentageExplanationTypeWiget type;
  final double currentValue;
  final double previousValue;

  const PorcentageExplanationFinanceDetailsPage({
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: theme.cardColor,
        foregroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador visual
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: result.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: result.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(result.icon, color: result.color, size: 24.sp),
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
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),

              // Comparação de valores
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    _buildValueRow(
                      'Mês anterior (mesmo período):',
                      formatter.format(previousValue),
                      theme.primaryColor,
                    ),
                    SizedBox(height: 8.h),
                    _buildValueRow(
                      'Mês atual (até hoje):',
                      formatter.format(currentValue),
                      theme.primaryColor,
                    ),
                    SizedBox(height: 8.h),
                    Divider(color: DefaultColors.grey.withOpacity(0.3)),
                    SizedBox(height: 8.h),
                    _buildValueRow(
                      'Diferença:',
                      '${currentValue >= previousValue ? '+' : ''}${formatter.format(currentValue - previousValue)}',
                      result.color,
                      bold: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Nota explicativa
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getNote(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Botão de voltar
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value, Color color,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: DefaultColors.grey,
              fontSize: 12.sp,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (type) {
      case PercentageExplanationTypeWiget.balance:
        return 'Comparação do Saldo';
      case PercentageExplanationTypeWiget.income:
        return 'Comparação das Receitas';
      case PercentageExplanationTypeWiget.expense:
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
      case PercentageExplanationTypeWiget.balance:
        return isPositive
            ? 'Seu saldo está ${result.percentage.toStringAsFixed(1)}% melhor comparado ao mesmo período do mês anterior. Isso significa que você está economizando mais ou ganhando mais dinheiro.'
            : 'Seu saldo está ${result.percentage.toStringAsFixed(1)}% pior comparado ao mesmo período do mês anterior. Isso pode indicar mais gastos ou menos receitas.';

      case PercentageExplanationTypeWiget.income:
        return isPositive
            ? 'Suas receitas aumentaram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Parabéns! Você está ganhando mais dinheiro.'
            : 'Suas receitas diminuíram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Pode ser útil revisar suas fontes de renda.';

      case PercentageExplanationTypeWiget.expense:
        return isPositive
            ? 'Suas despesas diminuíram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Excelente! Você está gastando menos.'
            : 'Suas despesas aumentaram ${result.percentage.toStringAsFixed(1)}% comparado ao mesmo período do mês anterior. Considere revisar seus gastos.';
    }
  }

  String _getNote() {
    final today = DateTime.now();
    return 'A comparação é feita entre o período de 1º até o dia ${today.day} do mês atual versus o mesmo período do mês anterior. Isso garante uma comparação justa entre períodos equivalentes.';
  }
}
