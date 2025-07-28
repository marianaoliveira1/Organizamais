import '../model/percentage_result.dart';
import '../model/transaction_model.dart';

class PercentageCalculationService {
  static PercentageResult calculateMonthlyComparison(
    List<TransactionModel> transactions,
    DateTime currentDate,
  ) {
    try {
      // Calculate current month balance up to current day
      final currentMonthStart = DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
      
      // Calculate previous month balance up to same day
      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear = currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);
      
      // Use the same day or last day of previous month if current day doesn't exist
      final daysInPreviousMonth = DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth ? daysInPreviousMonth : currentDate.day;
      final previousMonthEnd = DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentBalance = _getBalanceForPeriod(transactions, currentMonthStart, currentMonthEnd);
      final previousBalance = _getBalanceForPeriod(transactions, previousMonthStart, previousMonthEnd);

      // Check if we have data for previous month
      final hasPreviousData = _hasTransactionsInPeriod(transactions, previousMonthStart, previousMonthEnd);
      if (!hasPreviousData) {
        return PercentageResult.noData();
      }

      // Handle edge cases
      if (previousBalance == 0.0) {
        if (currentBalance > 0) {
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.newData,
            displayText: 'Novo',
          );
        } else if (currentBalance < 0) {
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.newData,
            displayText: 'Novo',
          );
        } else {
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.neutral,
            displayText: '0.0%',
          );
        }
      }

      // Calculate percentage change
      final percentageChange = ((currentBalance - previousBalance) / previousBalance.abs()) * 100;

      // Determine type
      PercentageType type;
      if (percentageChange > 0) {
        type = PercentageType.positive;
      } else if (percentageChange < 0) {
        type = PercentageType.negative;
      } else {
        type = PercentageType.neutral;
      }

      return PercentageResult(
        percentage: percentageChange,
        hasData: true,
        type: type,
        displayText: _formatPercentage(percentageChange, type),
      );
    } catch (e) {
      print('Error calculating monthly comparison: $e');
      return PercentageResult.noData();
    }
  }

  static double _getBalanceForPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    double balance = 0.0;

    for (final transaction in transactions) {
      if (transaction.paymentDay == null) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          
          final value = _parseValue(transaction.value);
          
          if (transaction.type == TransactionType.receita) {
            balance += value;
          } else if (transaction.type == TransactionType.despesa) {
            balance -= value;
          }
        }
      } catch (e) {
        print('Error processing transaction ${transaction.id}: $e');
        continue;
      }
    }

    return balance;
  }

  static bool _hasTransactionsInPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final transaction in transactions) {
      if (transaction.paymentDay == null) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static double _parseValue(String value) {
    try {
      String cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      
      return double.parse(cleanValue);
    } catch (e) {
      print('Error parsing value: $value - $e');
      return 0.0;
    }
  }

  static PercentageResult calculateIncomeComparison(
    List<TransactionModel> transactions,
    DateTime currentDate,
  ) {
    try {
      final currentMonthStart = DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
      
      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear = currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);
      
      final daysInPreviousMonth = DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth ? daysInPreviousMonth : currentDate.day;
      final previousMonthEnd = DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentIncome = _getIncomeForPeriod(transactions, currentMonthStart, currentMonthEnd);
      final previousIncome = _getIncomeForPeriod(transactions, previousMonthStart, previousMonthEnd);

      final hasPreviousData = _hasIncomeInPeriod(transactions, previousMonthStart, previousMonthEnd);
      if (!hasPreviousData) {
        return PercentageResult.noData();
      }

      if (previousIncome == 0.0) {
        return PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );
      }

      final percentageChange = ((currentIncome - previousIncome) / previousIncome) * 100;

      PercentageType type;
      if (percentageChange > 0) {
        type = PercentageType.positive;
      } else if (percentageChange < 0) {
        type = PercentageType.negative;
      } else {
        type = PercentageType.neutral;
      }

      return PercentageResult(
        percentage: percentageChange,
        hasData: true,
        type: type,
        displayText: _formatPercentage(percentageChange, type),
      );
    } catch (e) {
      print('Error calculating income comparison: $e');
      return PercentageResult.noData();
    }
  }

  static PercentageResult calculateExpenseComparison(
    List<TransactionModel> transactions,
    DateTime currentDate,
  ) {
    try {
      final currentMonthStart = DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
      
      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear = currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);
      
      final daysInPreviousMonth = DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth ? daysInPreviousMonth : currentDate.day;
      final previousMonthEnd = DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentExpenses = _getExpensesForPeriod(transactions, currentMonthStart, currentMonthEnd);
      final previousExpenses = _getExpensesForPeriod(transactions, previousMonthStart, previousMonthEnd);

      final hasPreviousData = _hasExpensesInPeriod(transactions, previousMonthStart, previousMonthEnd);
      if (!hasPreviousData) {
        return PercentageResult.noData();
      }

      if (previousExpenses == 0.0) {
        return PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.newData,
          displayText: 'Novo',
        );
      }

      final percentageChange = ((currentExpenses - previousExpenses) / previousExpenses) * 100;

      // For expenses, logic is inverted: less expenses = positive (good)
      PercentageType type;
      if (percentageChange > 0) {
        type = PercentageType.negative; // More expenses = bad
      } else if (percentageChange < 0) {
        type = PercentageType.positive; // Less expenses = good
      } else {
        type = PercentageType.neutral;
      }

      // For expenses, we want to show the actual percentage change but with inverted colors
      // If expenses decreased (percentageChange < 0), show negative percentage in green (good)
      // If expenses increased (percentageChange > 0), show positive percentage in red (bad)
      
      return PercentageResult(
        percentage: percentageChange.abs(),
        hasData: true,
        type: type,
        displayText: _formatPercentage(percentageChange, type),
      );
    } catch (e) {
      print('Error calculating expense comparison: $e');
      return PercentageResult.noData();
    }
  }

  static double _getIncomeForPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    double income = 0.0;

    for (final transaction in transactions) {
      if (transaction.paymentDay == null || transaction.type != TransactionType.receita) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          income += _parseValue(transaction.value);
        }
      } catch (e) {
        continue;
      }
    }

    return income;
  }

  static double _getExpensesForPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    double expenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.paymentDay == null || transaction.type != TransactionType.despesa) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          expenses += _parseValue(transaction.value);
        }
      } catch (e) {
        continue;
      }
    }

    return expenses;
  }

  static bool _hasIncomeInPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final transaction in transactions) {
      if (transaction.paymentDay == null || transaction.type != TransactionType.receita) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static bool _hasExpensesInPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final transaction in transactions) {
      if (transaction.paymentDay == null || transaction.type != TransactionType.despesa) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        
        if (paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
            paymentDate.isBefore(endDate.add(Duration(days: 1)))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static String _formatPercentage(double percentage, PercentageType type) {
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
}