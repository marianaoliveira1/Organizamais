import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove qualquer caracter que não seja dígito
    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (onlyDigits.isEmpty) {
      // Se não tiver nada digitado, retorna o texto vazio ou R\$ 0,00
      return TextEditingValue(
        text: 'R\$ 0,00',
        selection: TextSelection.collapsed(offset: 'R\$ 0,00'.length),
      );
    }

    // Converte a string de dígitos para double, interpretando como centavos
    double value = double.parse(onlyDigits) / 100;

    // Formata usando o NumberFormat configurado para pt_BR
    String newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
