import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

enum PercentageType { positive, negative, neutral, newData }

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
        return Iconsax.arrow_circle_up;
      case PercentageType.negative:
        return Iconsax.arrow_down_2;
      case PercentageType.neutral:
        return Iconsax.arrow_right_2;
      case PercentageType.newData:
        return Iconsax.star_1;
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
