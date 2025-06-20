import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/color.dart';

class SaldoCard extends StatelessWidget {
  final double saldo;

  const SaldoCard({
    super.key,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo do Ano',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: DefaultColors.grey20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(
                      saldo), // Removido o .abs() para mostrar valores negativos
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: saldo < 0
                        ? Colors.red
                        : theme
                            .primaryColor, // Cor vermelha para saldo negativo
                  ),
                ),
              ],
            ),
          ),
        ],
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
