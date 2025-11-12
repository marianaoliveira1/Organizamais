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

      // (removido: cálculo do mês anterior completo aqui não é usado neste método)

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
        // print('Error processing transaction ${transaction.id}: $e');
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
      // print('Error parsing value: $value - $e');
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
      // print('Error calculating income comparison: $e');
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
      // print('Error calculating expense comparison: $e');
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
          transaction.type != TransactionType.receita) {
        continue;
      }

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
          transaction.type != TransactionType.despesa) {
        continue;
      }

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
          transaction.type != TransactionType.receita) {
        continue;
      }

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
          transaction.type != TransactionType.despesa) {
        continue;
      }

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

      // Valor do mês anterior completo (para verificar se há transações)
      final previousFullMonthEnd =
          DateTime(previousYear, previousMonth + 1, 0, 23, 59, 59);

      // Check if we have data for current month
      final hasCurrentData = _hasCategoryTransactionsInPeriod(
          transactions, categoryId, currentMonthStart, currentMonthEnd);

      // Check if we have data for previous month (até o dia atual)
      final hasPreviousData = _hasCategoryTransactionsInPeriod(
          transactions, categoryId, previousMonthStart, previousMonthEnd);

      // Check if we have transactions in the full previous month
      final hasPreviousFullMonthData = _hasCategoryTransactionsInPeriod(
          transactions, categoryId, previousMonthStart, previousFullMonthEnd);

      // // Debug: imprimir informações para entender o que está acontecendo
      // print(
      //     'Category $categoryId - Current: $currentExpenses, Previous: $previousExpenses');
      // print(
      //     'Category $categoryId - HasCurrent: $hasCurrentData, HasPrevious: $hasPreviousData');
      // print(
      //     'Category $categoryId - Current period: $currentMonthStart to $currentMonthEnd');
      // print(
      //     'Category $categoryId - Previous period: $previousMonthStart to $previousMonthEnd');

      // Debug: mostrar transações específicas da categoria

      for (final _ in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        // noop
      }

      for (final transaction in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        if (transaction.paymentDay != null) {
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          if (paymentDate.isAfter(
                  currentMonthStart.subtract(const Duration(seconds: 1))) &&
              paymentDate
                  .isBefore(currentMonthEnd.add(const Duration(seconds: 1)))) {
            // print(
            //     '  - CURRENT: ${transaction.title}: ${transaction.value} on $paymentDate');
          }
        }
      }

      // Debug: mostrar transações no período anterior

      for (final transaction in transactions.where((t) =>
          t.type == TransactionType.despesa && t.category == categoryId)) {
        if (transaction.paymentDay != null) {
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          if (paymentDate.isAfter(
                  previousMonthStart.subtract(const Duration(seconds: 1))) &&
              paymentDate.isBefore(
                  previousMonthEnd.add(const Duration(seconds: 1)))) {}
        }
      }

      // Debug: verificar se há dados em outros meses
      // noop: debug variable removed

      // Lógica: considerar somente o mês anterior para definir "Novo" e cobrir cenários incompletos
      // Se há transações no mês anterior completo, sempre faz comparação (nunca marca como nova)
      if (hasCurrentData || hasPreviousData || hasPreviousFullMonthData) {
        // Caso 1: Novo (tem no mês atual e mês anterior completo não teve transações)
        // Só marca como nova se não houver transações no mês anterior completo
        if (hasCurrentData &&
            currentExpenses > 0 &&
            !hasPreviousFullMonthData) {
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.newData,
            displayText: 'Novo',
          );
        }

        // Caso 1b: Tem dados atuais mas currentExpenses == 0 e não há dados anteriores
        if (hasCurrentData &&
            currentExpenses == 0 &&
            !hasPreviousFullMonthData &&
            !hasPreviousData) {
          // Se não há dados anteriores, não há comparação possível
          return PercentageResult.noData();
        }

        // Caso 2: Há dados no mês anterior dentro da janela comparável (até o mesmo dia)
        // Sempre usa previousExpenses que é calculado até o mesmo dia do mês passado
        if (hasPreviousData) {
          if (previousExpenses == 0.0) {
            // Sem gasto até o mesmo dia do mês anterior – tratar variação como 100% se houver gasto atual
            if (currentExpenses > 0) {
              return PercentageResult(
                percentage: 100.0,
                hasData: true,
                type: PercentageType.negative, // aumento de despesa = ruim
                displayText: _formatPercentage(100.0, PercentageType.negative),
              );
            }
            return PercentageResult(
              percentage: 0.0,
              hasData: true,
              type: PercentageType.neutral,
              displayText: '0.0%',
            );
          }

          final percentageChange =
              ((currentExpenses - previousExpenses) / previousExpenses) * 100;

          // Para despesas: diminuição = positivo (bom), aumento = negativo (ruim)
          PercentageType type;
          if (percentageChange < 0) {
            type = PercentageType.positive;
          } else if (percentageChange > 0) {
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
        }

        // Caso 3: Tem dados no mês atual e há transações no mês anterior completo,
        // mas não há dados até o mesmo dia do mês passado
        // Compara usando previousExpenses (até o mesmo dia, que será 0) vs currentExpenses
        if (hasCurrentData && hasPreviousFullMonthData && !hasPreviousData) {
          if (previousExpenses == 0.0) {
            if (currentExpenses > 0) {
              // Não havia gasto até o mesmo dia do mês passado, mas há no mês completo
              // Trata como aumento de 100% (comparando até o mesmo dia)
              return PercentageResult(
                percentage: 100.0,
                hasData: true,
                type: PercentageType.negative,
                displayText: _formatPercentage(100.0, PercentageType.negative),
              );
            } else {
              // Ambos são zero até o mesmo dia
              return PercentageResult(
                percentage: 0.0,
                hasData: true,
                type: PercentageType.neutral,
                displayText: '0.0%',
              );
            }
          }
          // Se previousExpenses > 0 mas não há hasPreviousData, isso não deveria acontecer,
          // mas vamos tratar como comparação normal
          if (previousExpenses > 0) {
            final percentageChange =
                ((currentExpenses - previousExpenses) / previousExpenses) * 100;
            PercentageType type;
            if (percentageChange < 0) {
              type = PercentageType.positive;
            } else if (percentageChange > 0) {
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
          }
        }

        // Caso 4: Tem dados no mês anterior (na janela), mas não no atual até a data
        if (hasPreviousData && !hasCurrentData) {
          if (previousExpenses > 0) {
            // Queda de 100%
            return PercentageResult(
              percentage: 100.0,
              hasData: true,
              type: PercentageType.positive, // diminuição de despesa = bom
              displayText: _formatPercentage(100.0, PercentageType.positive),
            );
          } else {
            // Ambos são zero
            return PercentageResult(
              percentage: 0.0,
              hasData: true,
              type: PercentageType.neutral,
              displayText: '0.0%',
            );
          }
        }

        // Caso 5: Fallback final - se tem dados atuais e anteriores completos mas não entrou em nenhum caso
        // Isso não deveria acontecer, mas garante que sempre retorna comparação quando há dados
        if (hasCurrentData && hasPreviousFullMonthData) {
          // Faz comparação usando previousExpenses (até o mesmo dia)
          if (previousExpenses == 0.0) {
            if (currentExpenses > 0) {
              return PercentageResult(
                percentage: 100.0,
                hasData: true,
                type: PercentageType.negative,
                displayText: _formatPercentage(100.0, PercentageType.negative),
              );
            } else {
              // Ambos são zero até o mesmo dia
              return PercentageResult(
                percentage: 0.0,
                hasData: true,
                type: PercentageType.neutral,
                displayText: '0.0%',
              );
            }
          } else {
            final percentageChange =
                ((currentExpenses - previousExpenses) / previousExpenses) * 100;
            PercentageType type;
            if (percentageChange < 0) {
              type = PercentageType.positive;
            } else if (percentageChange > 0) {
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
          }
        }

        // Caso 6: Tem apenas dados atuais (sem dados anteriores)
        // Se chegou aqui e tem hasCurrentData mas não tem hasPreviousFullMonthData nem hasPreviousData,
        // e não entrou no Caso 1, então currentExpenses deve ser 0
        if (hasCurrentData && !hasPreviousFullMonthData && !hasPreviousData) {
          // Já foi tratado no Caso 1b, mas se chegou aqui é porque currentExpenses > 0
          // mas não entrou no Caso 1 - isso não deveria acontecer, mas vamos tratar
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.newData,
            displayText: 'Novo',
          );
        }

        // Caso 7: Tem apenas dados anteriores completos (sem dados atuais até o dia)
        if (hasPreviousFullMonthData && !hasCurrentData && !hasPreviousData) {
          // Não há dados atuais até o dia, mas há no mês anterior completo
          // Compara 0 atual vs previousExpenses (que será 0 até o mesmo dia)
          return PercentageResult(
            percentage: 0.0,
            hasData: true,
            type: PercentageType.neutral,
            displayText: '0.0%',
          );
        }

        // Fallback final: Se chegou aqui e tem qualquer dado, faz comparação básica
        // Isso garante que sempre retorna algo quando há dados para comparar
        if (hasCurrentData || hasPreviousData || hasPreviousFullMonthData) {
          // Se tem dados atuais e anteriores, compara
          if (hasCurrentData && (hasPreviousData || hasPreviousFullMonthData)) {
            if (previousExpenses == 0.0) {
              if (currentExpenses > 0) {
                return PercentageResult(
                  percentage: 100.0,
                  hasData: true,
                  type: PercentageType.negative,
                  displayText:
                      _formatPercentage(100.0, PercentageType.negative),
                );
              } else {
                return PercentageResult(
                  percentage: 0.0,
                  hasData: true,
                  type: PercentageType.neutral,
                  displayText: '0.0%',
                );
              }
            } else {
              final percentageChange =
                  ((currentExpenses - previousExpenses) / previousExpenses) *
                      100;
              PercentageType type;
              if (percentageChange < 0) {
                type = PercentageType.positive;
              } else if (percentageChange > 0) {
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
            }
          }
          // Se tem apenas dados atuais sem anteriores
          else if (hasCurrentData && currentExpenses > 0) {
            return PercentageResult(
              percentage: 0.0,
              hasData: true,
              type: PercentageType.newData,
              displayText: 'Novo',
            );
          }
          // Se tem apenas dados anteriores sem atuais
          else if ((hasPreviousData || hasPreviousFullMonthData) &&
              previousExpenses > 0) {
            return PercentageResult(
              percentage: 100.0,
              hasData: true,
              type: PercentageType.positive,
              displayText: _formatPercentage(100.0, PercentageType.positive),
            );
          }
        }

        // Sem dados relevantes para comparar
        return PercentageResult.noData();
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
          transaction.category != categoryId) {
        continue;
      }

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
          transaction.category != categoryId) {
        continue;
      }

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
          transaction.category != categoryId) {
        continue;
      }

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
        return '+${percentage.toStringAsFixed(1)}%';
      case PercentageType.negative:
        return '-${percentage.toStringAsFixed(1)}%';
      case PercentageType.neutral:
        return '0.0%';
      case PercentageType.newData:
        return 'Novo';
    }
  }
}
