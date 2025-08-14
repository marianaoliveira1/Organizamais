import '../model/percentage_result.dart';
import '../model/transaction_model.dart';

class PercentageCalculationService {
  static PercentageResult calculateMonthlyComparison(
    List<TransactionModel> transactions,
    DateTime currentDate,
  ) {
    try {
      // Calculate current month balance up to current day
      final currentMonthStart =
          DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(
          currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

      // Calculate previous month balance up to same day
      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear =
          currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);

      // Use the same day or last day of previous month if current day doesn't exist
      final daysInPreviousMonth =
          DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth
          ? daysInPreviousMonth
          : currentDate.day;
      final previousMonthEnd =
          DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentBalance = _getBalanceForPeriod(
          transactions, currentMonthStart, currentMonthEnd);
      final previousBalance = _getBalanceForPeriod(
          transactions, previousMonthStart, previousMonthEnd);

      // Check if we have data for previous month
      final hasPreviousData = _hasTransactionsInPeriod(
          transactions, previousMonthStart, previousMonthEnd);
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
      final percentageChange =
          ((currentBalance - previousBalance) / previousBalance.abs()) * 100;

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

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
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

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
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
      final currentMonthStart =
          DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(
          currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear =
          currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);

      final daysInPreviousMonth =
          DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth
          ? daysInPreviousMonth
          : currentDate.day;
      final previousMonthEnd =
          DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentIncome =
          _getIncomeForPeriod(transactions, currentMonthStart, currentMonthEnd);
      final previousIncome = _getIncomeForPeriod(
          transactions, previousMonthStart, previousMonthEnd);

      final hasPreviousData = _hasIncomeInPeriod(
          transactions, previousMonthStart, previousMonthEnd);
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

      final percentageChange =
          ((currentIncome - previousIncome) / previousIncome) * 100;

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
      final currentMonthStart =
          DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(
          currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear =
          currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);

      final daysInPreviousMonth =
          DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth
          ? daysInPreviousMonth
          : currentDate.day;
      final previousMonthEnd =
          DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentExpenses = _getExpensesForPeriod(
          transactions, currentMonthStart, currentMonthEnd);
      final previousExpenses = _getExpensesForPeriod(
          transactions, previousMonthStart, previousMonthEnd);

      final hasPreviousData = _hasExpensesInPeriod(
          transactions, previousMonthStart, previousMonthEnd);
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

      final percentageChange =
          ((currentExpenses - previousExpenses) / previousExpenses) * 100;

      // Para despesas: diminuição = positivo (bom), aumento = negativo (ruim)
      PercentageType type;
      if (percentageChange < 0) {
        // Despesas diminuíram = bom
        type = PercentageType.positive;
      } else if (percentageChange > 0) {
        // Despesas aumentaram = ruim
        type = PercentageType.negative;
      } else {
        type = PercentageType.neutral;
      }

      return PercentageResult(
        percentage: percentageChange.abs(),
        hasData: true,
        type: type,
        displayText: _formatPercentage(percentageChange.abs(), type),
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
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.receita) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
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
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.despesa) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
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
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.receita) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
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
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.despesa) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static PercentageResult calculateCategoryExpenseComparison(
    List<TransactionModel> transactions,
    int categoryId,
    DateTime currentDate,
  ) {
    try {
      // Calculate current month expenses for the category up to current day
      final currentMonthStart =
          DateTime(currentDate.year, currentDate.month, 1);
      final currentMonthEnd = DateTime(
          currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

      // Calculate previous month expenses for the category up to same day
      final previousMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final previousYear =
          currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final previousMonthStart = DateTime(previousYear, previousMonth, 1);

      // Use the same day or last day of previous month if current day doesn't exist
      final daysInPreviousMonth =
          DateTime(previousYear, previousMonth + 1, 0).day;
      final previousMonthDay = currentDate.day > daysInPreviousMonth
          ? daysInPreviousMonth
          : currentDate.day;
      final previousMonthEnd =
          DateTime(previousYear, previousMonth, previousMonthDay, 23, 59, 59);

      final currentExpenses = getCategoryExpensesForPeriod(
          transactions, categoryId, currentMonthStart, currentMonthEnd);
      final previousExpenses = getCategoryExpensesForPeriod(
          transactions, categoryId, previousMonthStart, previousMonthEnd);

      // Check if we have data for current month
      final hasCurrentData = _hasCategoryTransactionsInPeriod(
          transactions, categoryId, currentMonthStart, currentMonthEnd);

      // Check if we have data for previous month
      final hasPreviousData = _hasCategoryTransactionsInPeriod(
          transactions, categoryId, previousMonthStart, previousMonthEnd);

      // Debug: imprimir informações para entender o que está acontecendo
      print(
          'Category $categoryId - Current: $currentExpenses, Previous: $previousExpenses');
      print(
          'Category $categoryId - HasCurrent: $hasCurrentData, HasPrevious: $hasPreviousData');
      print(
          'Category $categoryId - Current period: $currentMonthStart to $currentMonthEnd');
      print(
          'Category $categoryId - Previous period: $previousMonthStart to $previousMonthEnd');

      // Debug: mostrar transações específicas da categoria
      print('Category $categoryId - All transactions:');
      for (final transaction in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        if (transaction.paymentDay != null) {
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          print(
              '  - ${transaction.title}: ${transaction.value} on $paymentDate');
        }
      }

      // Debug: mostrar transações no período atual
      print('Category $categoryId - Current period transactions:');
      for (final transaction in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        if (transaction.paymentDay != null) {
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          if (paymentDate.isAfter(
                  currentMonthStart.subtract(const Duration(seconds: 1))) &&
              paymentDate
                  .isBefore(currentMonthEnd.add(const Duration(seconds: 1)))) {
            print(
                '  - CURRENT: ${transaction.title}: ${transaction.value} on $paymentDate');
          }
        }
      }

      // Debug: mostrar transações no período anterior
      print('Category $categoryId - Previous period transactions:');
      for (final transaction in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        if (transaction.paymentDay != null) {
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          if (paymentDate.isAfter(
                  previousMonthStart.subtract(const Duration(seconds: 1))) &&
              paymentDate
                  .isBefore(previousMonthEnd.add(const Duration(seconds: 1)))) {
            print(
                '  - PREVIOUS: ${transaction.title}: ${transaction.value} on $paymentDate');
          }
        }
      }

      // Debug: verificar se há dados em outros meses
      final hasAnyDataDebug = _hasCategoryTransactionsInAnyPreviousMonth(
          transactions, categoryId, currentDate);
      print('Category $categoryId - HasAnyData: $hasAnyDataDebug');

      // Lógica simplificada: se há dados em qualquer mês, calcular a comparação
      if (hasCurrentData || hasPreviousData) {
        // Se não há dados do mês anterior, mas há dados do mês atual, é um novo dado
        if (!hasPreviousData && hasCurrentData && currentExpenses > 0) {
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.newData,
            displayText: 'Novo',
          );
        }

        // Se há dados do mês anterior, calcular a comparação
        if (hasPreviousData) {
          // Handle edge cases
          if (previousExpenses == 0.0) {
            if (currentExpenses > 0) {
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
          final percentageChange =
              ((currentExpenses - previousExpenses) / previousExpenses) * 100;

          // Determine type
          PercentageType type;
          if (percentageChange < 0) {
            // Despesas diminuíram = bom
            type = PercentageType.negative;
          } else if (percentageChange > 0) {
            // Despesas aumentaram = ruim
            type = PercentageType.positive;
          } else {
            type = PercentageType.neutral;
          }

          return PercentageResult(
            percentage: percentageChange.abs(),
            hasData: true,
            type: type,
            displayText: _formatPercentage(percentageChange.abs(), type),
          );
        }

        // Se chegou aqui, há dados atuais mas não há dados anteriores
        // Verificar se é realmente uma categoria nova ou se há parcelamentos
        if (currentExpenses > 0) {
          // Verificar se há transações da mesma categoria em outros meses (parcelamentos)
          final hasAnyPreviousData = _hasCategoryTransactionsInAnyPreviousMonth(
              transactions, categoryId, currentDate);

          if (hasAnyPreviousData) {
            // Se há dados em outros meses, não é realmente nova
            return PercentageResult(
              percentage: 0.0,
              hasData: true,
              type: PercentageType.neutral,
              displayText: '0.0%',
            );
          } else {
            // É realmente uma categoria nova
            return PercentageResult(
              percentage: 0.0,
              hasData: true,
              type: PercentageType.newData,
              displayText: 'Novo',
            );
          }
        }
      }

      // Se chegou aqui, verificar se há dados em outros meses (parcelamentos antigos)
      final hasAnyData = _hasCategoryTransactionsInAnyPreviousMonth(
          transactions, categoryId, currentDate);

      if (hasAnyData) {
        // Se há dados em outros meses, mostrar como "0.0%" (sem variação)
        return PercentageResult(
          percentage: 0.0,
          hasData: true,
          type: PercentageType.neutral,
          displayText: '0.0%',
        );
      }

      // Se chegou aqui, não há dados suficientes
      return PercentageResult.noData();
    } catch (e) {
      print('Error calculating category expense comparison: $e');
      return PercentageResult.noData();
    }
  }

  static double getCategoryExpensesForPeriod(
    List<TransactionModel> transactions,
    int categoryId,
    DateTime startDate,
    DateTime endDate,
  ) {
    double expenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.despesa ||
          transaction.category != categoryId) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Lógica de comparação mais precisa - usar datas completas
        if (paymentDate
                .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            paymentDate.isBefore(endDate.add(const Duration(seconds: 1)))) {
          expenses += _parseValue(transaction.value);
        }
      } catch (e) {
        continue;
      }
    }

    return expenses;
  }

  static bool _hasCategoryTransactionsInPeriod(
    List<TransactionModel> transactions,
    int categoryId,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final transaction in transactions) {
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.despesa ||
          transaction.category != categoryId) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Lógica de comparação mais precisa - usar datas completas
        if (paymentDate
                .isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            paymentDate.isBefore(endDate.add(const Duration(seconds: 1)))) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static bool _hasCategoryTransactionsInAnyPreviousMonth(
    List<TransactionModel> transactions,
    int categoryId,
    DateTime currentDate,
  ) {
    // Verificar se há transações da mesma categoria em qualquer mês anterior
    for (final transaction in transactions) {
      if (transaction.paymentDay == null ||
          transaction.type != TransactionType.despesa ||
          transaction.category != categoryId) continue;

      try {
        final paymentDate = DateTime.parse(transaction.paymentDay!);

        // Se a transação é de um mês anterior ao atual
        if (paymentDate.year < currentDate.year ||
            (paymentDate.year == currentDate.year &&
                paymentDate.month < currentDate.month)) {
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
        return '+${percentage.abs().toStringAsFixed(1)}%';
      case PercentageType.negative:
        return '-${percentage.abs().toStringAsFixed(1)}%';
      case PercentageType.neutral:
        return '0.0%';
      case PercentageType.newData:
        return 'Novo';
    }
  }
}
