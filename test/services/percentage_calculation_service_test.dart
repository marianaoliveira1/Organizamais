import 'package:flutter_test/flutter_test.dart';
import 'package:organizamais/model/percentage_result.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/services/percentage_calculation_service.dart';

void main() {
  group('PercentageCalculationService', () {
    late List<TransactionModel> testTransactions;

    setUp(() {
      testTransactions = [];
    });

    group('calculateMonthlyComparison', () {
      test('should return positive percentage when current month is better', () {
        // Current month: +1000 (1500 receita - 500 despesa)
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Salário',
            value: '1500,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '2',
            title: 'Compras',
            value: '500,00',
            type: TransactionType.despesa,
            paymentDay: '2024-02-10T10:00:00.000Z',
          ),
        ]);

        // Previous month: +800 (1200 receita - 400 despesa)
        testTransactions.addAll([
          TransactionModel(
            id: '3',
            title: 'Salário',
            value: '1200,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '4',
            title: 'Compras',
            value: '400,00',
            type: TransactionType.despesa,
            paymentDay: '2024-01-10T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.type, PercentageType.positive);
        expect(result.percentage, 25.0); // (1000-800)/800 * 100 = 25%
      });

      test('should return negative percentage when current month is worse', () {
        // Current month: +600
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Salário',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '2',
            title: 'Compras',
            value: '400,00',
            type: TransactionType.despesa,
            paymentDay: '2024-02-10T10:00:00.000Z',
          ),
        ]);

        // Previous month: +800
        testTransactions.addAll([
          TransactionModel(
            id: '3',
            title: 'Salário',
            value: '1200,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '4',
            title: 'Compras',
            value: '400,00',
            type: TransactionType.despesa,
            paymentDay: '2024-01-10T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.type, PercentageType.negative);
        expect(result.percentage, -25.0); // (600-800)/800 * 100 = -25%
      });

      test('should return neutral when values are equal', () {
        // Both months: +800
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Salário',
            value: '1200,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '2',
            title: 'Compras',
            value: '400,00',
            type: TransactionType.despesa,
            paymentDay: '2024-02-10T10:00:00.000Z',
          ),
          TransactionModel(
            id: '3',
            title: 'Salário',
            value: '1200,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '4',
            title: 'Compras',
            value: '400,00',
            type: TransactionType.despesa,
            paymentDay: '2024-01-10T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.type, PercentageType.neutral);
        expect(result.percentage, 0.0);
      });

      test('should return newData when previous month balance is zero', () {
        // Current month: +1000
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Salário',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
        ]);

        // Previous month: 0 (transactions that cancel out)
        testTransactions.addAll([
          TransactionModel(
            id: '2',
            title: 'Receita',
            value: '100,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-10T10:00:00.000Z',
          ),
          TransactionModel(
            id: '3',
            title: 'Despesa',
            value: '100,00',
            type: TransactionType.despesa,
            paymentDay: '2024-01-12T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.type, PercentageType.newData);
      });

      test('should return noData when no previous month data exists', () {
        // Only current month data
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Salário',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, false);
      });

      test('should handle invalid transaction values gracefully', () {
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Invalid',
            value: 'invalid_value',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '2',
            title: 'Valid',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-10T10:00:00.000Z',
          ),
          TransactionModel(
            id: '3',
            title: 'Previous',
            value: '800,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.percentage, 25.0); // Should ignore invalid value and calculate (1000-800)/800
      });

      test('should handle invalid payment dates gracefully', () {
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'Invalid Date',
            value: '500,00',
            type: TransactionType.receita,
            paymentDay: 'invalid_date',
          ),
          TransactionModel(
            id: '2',
            title: 'Valid',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-02-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '3',
            title: 'Previous',
            value: '800,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 2, 15),
        );

        expect(result.hasData, true);
        expect(result.percentage, 25.0); // Should ignore invalid date and calculate (1000-800)/800
      });

      test('should handle month boundaries correctly', () {
        // Test January to December transition
        testTransactions.addAll([
          TransactionModel(
            id: '1',
            title: 'January',
            value: '1000,00',
            type: TransactionType.receita,
            paymentDay: '2024-01-15T10:00:00.000Z',
          ),
          TransactionModel(
            id: '2',
            title: 'December',
            value: '800,00',
            type: TransactionType.receita,
            paymentDay: '2023-12-15T10:00:00.000Z',
          ),
        ]);

        final result = PercentageCalculationService.calculateMonthlyComparison(
          testTransactions,
          DateTime(2024, 1, 15),
        );

        expect(result.hasData, true);
        expect(result.percentage, 25.0); // (1000-800)/800 * 100 = 25%
      });
    });


  });
}