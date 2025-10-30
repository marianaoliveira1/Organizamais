import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter padrão: trata todos os dígitos como centavos (mesmo do transaction_page).
/// Exemplos:
/// 1 -> R$ 0,01; 3 -> R$ 0,13; 0 -> R$ 1,30; 8580 -> R$ 85,80
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String text;
    if (digits.isEmpty) {
      text = _formatter.format(0);
    } else {
      final double value = double.parse(digits) / 100.0;
      text = _formatter.format(value);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Alias compatível se algo usar a variante "cents".
class CurrencyCentsInputFormatter extends CurrencyInputFormatter {}
