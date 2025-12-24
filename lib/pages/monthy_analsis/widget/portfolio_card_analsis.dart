import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class PortfolioCard extends StatelessWidget {
  final double saldo;
  final double valueReceita;
  final double valueDespesa;
  final double mediaDespesa;
  final double mediaReceita;

  const PortfolioCard(
      {super.key,
      required this.saldo,
      required this.valueReceita,
      required this.valueDespesa,
      required this.mediaDespesa,
      required this.mediaReceita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnnualAnalysisHeader(
          saldo: saldo,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _LabeledAmount(
                label: 'Receitas',
                valueText: _formatCurrency(valueReceita),
                valueColor: theme.primaryColor,
              ),
            ),
            Container(
              width: 1.w,
              height: 40.h,
              color: DefaultColors.greyLight,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _LabeledAmount(
                label: 'Despesas',
                valueText: _formatCurrency(valueDespesa),
                valueColor: theme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _LabeledAmount(
                label: 'Média de Receitas',
                valueText: _formatCurrency(mediaReceita),
                valueColor: theme.primaryColor,
              ),
            ),
            Container(
              width: 1.w,
              height: 40.h,
              color: DefaultColors.greyLight,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _LabeledAmount(
                label: 'Média de Despesas',
                valueText: _formatCurrency(mediaDespesa),
                valueColor: theme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
      ],
    );
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted =
        absValue.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );

    return '${isNegative ? '-' : ''}R\$ $formatted';
  }
}

class _AnnualAnalysisHeader extends StatelessWidget {
  final double saldo;

  const _AnnualAnalysisHeader({required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: DefaultColors.grey20,
          ),
        ),
        SizedBox(height: 4.h),
        AutoSizeText(
          _formatCurrencyStatic(saldo),
          maxLines: 1,
          minFontSize: 20,
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: saldo < 0 ? DefaultColors.red : DefaultColors.green,
          ),
        ),
      ],
    );
  }

  static String _formatCurrencyStatic(double value) {
    final bool isNegative = value < 0;
    final double absValue = value.abs();
    final String formatted = absValue
        .toStringAsFixed(2)
        .replaceAll('.', ',')
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '${isNegative ? '-' : ''}R\$ $formatted';
  }
}

class _LabeledAmount extends StatelessWidget {
  final String label;
  final String valueText;
  final Color valueColor;

  const _LabeledAmount({
    required this.label,
    required this.valueText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: DefaultColors.grey20,
          ),
        ),
        SizedBox(height: 2.h),
        AutoSizeText(
          valueText,
          maxLines: 1,
          minFontSize: 12,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
