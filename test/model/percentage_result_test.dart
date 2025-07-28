import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organizamais/model/percentage_result.dart';
import 'package:organizamais/utils/color.dart';

void main() {
  group('PercentageResult', () {
    group('color getter', () {
      test('should return green for positive type', () {
        final result = PercentageResult(
          percentage: 25.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+25.0%',
        );

        expect(result.color, DefaultColors.green);
      });

      test('should return red for negative type', () {
        final result = PercentageResult(
          percentage: -25.0,
          hasData: true,
          type: PercentageType.negative,
          displayText: '-25.0%',
        );

        expect(result.color, DefaultColors.red);
      });

      test('should return grey for neutral type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );

        expect(result.color, DefaultColors.grey);
      });

      test('should return grey for newData type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );

        expect(result.color, DefaultColors.grey);
      });
    });

    group('icon getter', () {
      test('should return trending_up for positive type', () {
        final result = PercentageResult(
          percentage: 25.0,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+25.0%',
        );

        expect(result.icon, Icons.trending_up);
      });

      test('should return trending_down for negative type', () {
        final result = PercentageResult(
          percentage: -25.0,
          hasData: true,
          type: PercentageType.negative,
          displayText: '-25.0%',
        );

        expect(result.icon, Icons.trending_down);
      });

      test('should return trending_flat for neutral type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );

        expect(result.icon, Icons.trending_flat);
      });

      test('should return fiber_new for newData type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );

        expect(result.icon, Icons.fiber_new);
      });
    });

    group('formattedPercentage getter', () {
      test('should return empty string when hasData is false', () {
        final result = PercentageResult(
          percentage: 25.0,
          hasData: false,
          type: PercentageType.positive,
          displayText: '',
        );

        expect(result.formattedPercentage, '');
      });

      test('should return formatted positive percentage', () {
        final result = PercentageResult(
          percentage: 25.5,
          hasData: true,
          type: PercentageType.positive,
          displayText: '+25.5%',
        );

        expect(result.formattedPercentage, '+25.5%');
      });

      test('should return formatted negative percentage', () {
        final result = PercentageResult(
          percentage: -25.5,
          hasData: true,
          type: PercentageType.negative,
          displayText: '-25.5%',
        );

        expect(result.formattedPercentage, '-25.5%');
      });

      test('should return 0.0% for neutral type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );

        expect(result.formattedPercentage, '0.0%');
      });

      test('should return Novo for newData type', () {
        final result = PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );

        expect(result.formattedPercentage, 'Novo');
      });
    });

    group('noData factory', () {
      test('should create result with no data', () {
        final result = PercentageResult.noData();

        expect(result.percentage, 0.0);
        expect(result.hasData, false);
        expect(result.type, PercentageType.neutral);
        expect(result.displayText, '');
        expect(result.formattedPercentage, '');
      });
    });
  });
}