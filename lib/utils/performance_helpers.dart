// Helpers estáticos para otimização de performance
class PerformanceHelpers {
  // Cache para parsing de datas
  static final Map<String, DateTime?> _dateCache = {};

  // Cache para parsing de valores
  static final Map<String, double> _valueCache = {};

  // Parse seguro de data com cache
  static DateTime? safeParseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;

    // Verificar cache primeiro
    if (_dateCache.containsKey(iso)) {
      return _dateCache[iso];
    }

    try {
      final date = DateTime.parse(iso);
      _dateCache[iso] = date;
      return date;
    } catch (_) {
      _dateCache[iso] = null;
      return null;
    }
  }

  // Parse seguro de valor monetário com cache
  static double parseCurrencyValue(String value) {
    // Verificar cache primeiro
    if (_valueCache.containsKey(value)) {
      return _valueCache[value]!;
    }

    try {
      String s = value.replaceAll('R\$', '').trim();
      if (s.contains(',')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(' ', '');
      }
      final parsed = double.tryParse(s) ?? 0.0;
      _valueCache[value] = parsed;
      return parsed;
    } catch (_) {
      _valueCache[value] = 0.0;
      return 0.0;
    }
  }

  // Limpar cache quando necessário (ex: após atualizações)
  static void clearCache() {
    _dateCache.clear();
    _valueCache.clear();
  }

  // Limpar apenas cache de valores (mais usado)
  static void clearValueCache() {
    _valueCache.clear();
  }

  // Limpar apenas cache de datas
  static void clearDateCache() {
    _dateCache.clear();
  }
}
