import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ResponsiveCurrencyText extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int minFontSize;

  const ResponsiveCurrencyText({
    super.key,
    required this.value,
    this.style,
    this.minFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AutoSizeText(
        _formatCurrency(value),
        style: style ??
            TextStyle(
              fontSize: 40.sp, // responsivo
              fontWeight: FontWeight.bold,
              color: value < 0 ? Colors.red : Colors.green,
            ),
        maxLines: 1,
        minFontSize: minFontSize.toDouble(),
        overflow: TextOverflow.ellipsis,
      ),
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
