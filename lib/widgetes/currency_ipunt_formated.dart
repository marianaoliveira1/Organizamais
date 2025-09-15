import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formata entrada no padrão BRL sem assumir dígitos como centavos.
/// Exemplos:
/// - "16000" -> "R$ 16.000,00"
/// - "100,09" -> "R$ 100,09"
/// - "1.234,5" -> "R$ 1.234,50"
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _intGrouping = NumberFormat.decimalPattern('pt_BR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String raw = newValue.text.replaceAll('R\$', '').replaceAll(' ', '').trim();

    // Mantém apenas dígitos e vírgula/ponto para análise
    String sanitized = raw.replaceAll(RegExp(r'[^0-9,\.]'), '');

    if (sanitized.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String integerPart = '';
    String decimalPart = '';

    // Usa o último separador (vírgula OU ponto) como separador decimal
    final int lastComma = sanitized.lastIndexOf(',');
    final int lastDot = sanitized.lastIndexOf('.');
    final int sepIndex = lastComma > lastDot ? lastComma : lastDot;
    final bool hasDecimalSep = sepIndex != -1;
    if (hasDecimalSep) {
      integerPart =
          sanitized.substring(0, sepIndex).replaceAll(RegExp(r'[^0-9]'), '');
      decimalPart =
          sanitized.substring(sepIndex + 1).replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      // Sem vírgula: trata tudo como parte inteira; pontos são ignorados (milhar)
      integerPart = sanitized.replaceAll(RegExp(r'[^0-9]'), '');
      decimalPart = '';
    }

    if (integerPart.isEmpty) integerPart = '0';

    // Limita os centavos a no máximo 2 dígitos, sem preencher automaticamente
    if (hasDecimalSep && decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // Se usuário já tem 2 casas decimais e está digitando no fim um novo dígito,
    // tratar como parte inteira (ex.: "1,78" + "9" => "19,78").
    final bool typingAtEnd =
        newValue.selection.baseOffset == newValue.text.length &&
            newValue.text.length > oldValue.text.length;
    final String lastTypedChar =
        newValue.text.isNotEmpty ? newValue.text[newValue.text.length - 1] : '';
    final bool lastIsDigit = RegExp(r'\d').hasMatch(lastTypedChar);
    if (hasDecimalSep &&
        decimalPart.length == 2 &&
        typingAtEnd &&
        lastIsDigit) {
      integerPart = integerPart + lastTypedChar;
    }

    String groupedInt = '0';
    try {
      groupedInt = _intGrouping.format(int.parse(integerPart));
    } catch (_) {}

    final String formatted =
        hasDecimalSep ? 'R\$ $groupedInt,$decimalPart' : 'R\$ $groupedInt';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Variante que trata todos os dígitos como centavos (padrão de muitos apps BRL):
/// "0,00" → digita 1 → "R$ 0,01"; digita 3 → "R$ 0,13"; digita 0 → "R$ 1,30".
class CurrencyCentsInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final double value = double.parse(digits) / 100.0;
    final String text = _formatter.format(value);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
