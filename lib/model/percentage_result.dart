import 'package:flutter/material.dart';
import 'package:organizamais/utils/color.dart';

enum PercentageType {
  positive,
  negative,
  neutral,
  newData
}

class PercentageResult {
  final double percentage;
  final bool hasData;
  final PercentageType type;
  final String displayText;

  PercentageResult({
    required this.percentage,
    required this.hasData,
    required this.type,
    required this.displayText,
  });

  Color get color {
    switch (type) {
      case PercentageType.positive:
        return DefaultColors.green;
      case PercentageType.negative:
        return DefaultColors.red;
      case PercentageType.neutral:
        return DefaultColors.grey;
      case PercentageType.newData:
        return DefaultColors.grey;
    }
  }

  IconData get icon {
    switch (type) {
      case PercentageType.positive:
        return Icons.trending_up;
      case PercentageType.negative:
        return Icons.trending_down;
      case PercentageType.neutral:
        return Icons.trending_flat;
      case PercentageType.newData:
        return Icons.fiber_new;
    }
  }

  String get formattedPercentage {
    if (!hasData) return '';
    
    switch (type) {
      case PercentageType.positive:
        return '+${percentage.toStringAsFixed(1)}%';
      case PercentageType.negative:
        return '${percentage.toStringAsFixed(1)}%';
      case PercentageType.neutral:
        return '0.0%';
      case PercentageType.newData:
        return 'Novo';
    }
  }

  static PercentageResult noData() {
    return PercentageResult(
      percentage: 0.0,
      hasData: false,
      type: PercentageType.neutral,
      displayText: '',
    );
  }
}