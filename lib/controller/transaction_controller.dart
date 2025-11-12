import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/services/analytics_service.dart';
import '../model/transaction_model.dart';
import '../model/percentage_result.dart';
import '../services/percentage_calculation_service.dart';

class TransactionController extends GetxController {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? transactionStream;
  final _transaction = <TransactionModel>[].obs;
  final _isLoading = true.obs;
  final AnalyticsService _analyticsService = AnalyticsService();

  FixedAccountsController get fixedAccountsController =>
      Get.find<FixedAccountsController>();

  bool get isLoading => _isLoading.value;

  List<TransactionModel> get transaction {
    var fakeTransactionsFromFixed = <TransactionModel>[];
    final today = DateTime.now();

    for (final e in fixedAccountsController.allFixedAccounts) {
      final frequency = e.frequency ?? 'mensal';
      if (frequency == 'semanal') {
        // Gera lançamentos semanais de ~2 anos para trás até dez/2030
        final int weekday = (e.weeklyWeekday ?? 1).clamp(1, 7);
        final DateTime start = DateTime(today.year - 2, 1, 1);
        final DateTime end = DateTime(2030, 12, 31);
        // Find first occurrence on/after start matching weekday
        DateTime cursor = start;
        while (cursor.weekday != weekday) {
          cursor = cursor.add(const Duration(days: 1));
        }
        while (!cursor.isAfter(end)) {
          // Apply startMonth/startYear filter
          if (e.startMonth != null && e.startYear != null) {
            final startDate = DateTime(e.startYear!, e.startMonth!, 1);
            if (cursor.isBefore(startDate)) {
              cursor = cursor.add(const Duration(days: 7));
              continue;
            }
          }
          // Skip if deactivated before this date
          if (e.deactivatedAt != null && e.deactivatedAt!.isBefore(cursor)) {
            cursor = cursor.add(const Duration(days: 7));
            continue;
          }
          fakeTransactionsFromFixed.add(TransactionModel(
            id: e.id,
            value: e.value.split('\$')[1],
            type: TransactionType.despesa,
            paymentDay: cursor.toString(),
            title: "Conta fixa: ${e.title}",
            paymentType: e.paymentType,
            category: e.category,
          ));
          cursor = cursor.add(const Duration(days: 7));
        }
      } else {
        // Mensal/quinzenal/bimestral/trimestral: amplia para até Dez/2030
        final int monthsForward = (2030 - today.year) * 12 + (12 - today.month);
        for (var i = -12; i <= monthsForward; i++) {
          final transactionMonth = today.month + i;
          final transactionYear = today.year +
              (transactionMonth > 12
                  ? (transactionMonth - 1) ~/ 12
                  : transactionMonth < 1
                      ? (transactionMonth - 12) ~/ 12
                      : 0);
          final normalizedMonth = ((transactionMonth - 1) % 12) + 1;
          final adjustedNormalizedMonth =
              normalizedMonth <= 0 ? normalizedMonth + 12 : normalizedMonth;
          final adjustedYear =
              normalizedMonth <= 0 ? transactionYear - 1 : transactionYear;

          List<int> days = [];
          if (frequency == 'quinzenal' &&
              e.biweeklyDays != null &&
              e.biweeklyDays!.length >= 2) {
            days = e.biweeklyDays!;
          } else {
            days = [int.tryParse(e.paymentDay) ?? 1];
          }

          for (final d in days) {
            final int requestedDay = d.clamp(1, 31);
            // For bimestral and trimestral, only generate on specific month intervals
            bool shouldGenerate = true;
            if (frequency == 'bimestral') {
              final startRefMonth = e.startMonth ?? adjustedNormalizedMonth;
              final startRefYear = e.startYear ?? adjustedYear;
              final diff = ((adjustedYear - startRefYear) * 12) +
                  (adjustedNormalizedMonth - startRefMonth);
              shouldGenerate = diff % 2 == 0;
            } else if (frequency == 'trimestral') {
              final startRefMonth = e.startMonth ?? adjustedNormalizedMonth;
              final startRefYear = e.startYear ?? adjustedYear;
              final diff = ((adjustedYear - startRefYear) * 12) +
                  (adjustedNormalizedMonth - startRefMonth);
              shouldGenerate = diff % 3 == 0;
            }
            if (!shouldGenerate) {
              continue;
            }
            // fallback to last valid day of the month if requested day doesn't exist
            final int lastDayOfMonth =
                DateTime(adjustedYear, adjustedNormalizedMonth + 1, 0).day;
            final int effectiveDay =
                requestedDay <= lastDayOfMonth ? requestedDay : lastDayOfMonth;
            final date =
                DateTime(adjustedYear, adjustedNormalizedMonth, effectiveDay);

            // Skip if deactivated before this transaction date
            if (e.deactivatedAt != null && e.deactivatedAt!.isBefore(date)) {
              continue;
            }

            if (e.startMonth != null && e.startYear != null) {
              final startDate =
                  DateTime(e.startYear!, e.startMonth!, effectiveDay);
              if (date.isBefore(startDate)) {
                continue;
              }
            }

            fakeTransactionsFromFixed.add(TransactionModel(
              id: e.id,
              value: e.value.split('\$')[1],
              type: TransactionType.despesa,
              paymentDay: date.toString(),
              title: "Conta fixa: ${e.title}",
              paymentType: e.paymentType,
              category: e.category,
            ));
          }
        }
      }
    }

    return [..._transaction, ...fakeTransactionsFromFixed];
  }

  // Exposição reativa para rebuilds em UI que precisam reagir a alterações de transações
  RxList<TransactionModel> get transactionRx => _transaction;

  // Retorna transações (incluindo contas fixas geradas) para um mês/ano específicos
  List<TransactionModel> getTransactionsForMonth(int year, int month,
      {TransactionType? type}) {
    final DateTime start = DateTime(year, month, 1);
    final DateTime end = DateTime(year, month + 1, 0, 23, 59, 59);

    // 1) Transações reais do Firestore no intervalo
    final List<TransactionModel> real = _transaction.where((t) {
      if (t.paymentDay == null) return false;
      try {
        final d = DateTime.parse(t.paymentDay!);
        return (d.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(end.add(const Duration(seconds: 1))) &&
            (type == null || t.type == type));
      } catch (_) {
        return false;
      }
    }).toList();

    // 2) Contas fixas geradas apenas para o mês/ano solicitados
    final List<TransactionModel> fixed = <TransactionModel>[];
    for (final e in fixedAccountsController.allFixedAccounts) {
      final String freq = e.frequency ?? 'mensal';

      bool isAfterStartDate(DateTime d) {
        if (e.startMonth != null && e.startYear != null) {
          final startDate = DateTime(e.startYear!, e.startMonth!, 1);
          return !d.isBefore(startDate);
        }
        return true;
      }

      bool isBeforeDeactivation(DateTime d) {
        if (e.deactivatedAt == null) return true;
        return !e.deactivatedAt!.isBefore(d);
      }

      if (freq == 'semanal') {
        final int weekday = (e.weeklyWeekday ?? 1).clamp(1, 7);
        DateTime cursor = start;
        // avança até o weekday desejado
        while (cursor.weekday != weekday) {
          cursor = cursor.add(const Duration(days: 1));
          if (cursor.isAfter(end)) break;
        }
        while (!cursor.isAfter(end)) {
          if (isAfterStartDate(cursor) && isBeforeDeactivation(cursor)) {
            fixed.add(TransactionModel(
              id: e.id,
              value: e.value.split('\$').last,
              type: TransactionType.despesa,
              paymentDay: cursor.toString(),
              title: "Conta fixa: ${e.title}",
              paymentType: e.paymentType,
              category: e.category,
            ));
          }
          cursor = cursor.add(const Duration(days: 7));
        }
      } else {
        final int lastDay = DateTime(year, month + 1, 0).day;
        List<int> days;
        if (freq == 'quinzenal' &&
            e.biweeklyDays != null &&
            e.biweeklyDays!.length >= 2) {
          days = e.biweeklyDays!;
        } else {
          days = [int.tryParse(e.paymentDay) ?? 1];
        }

        bool shouldGenerateForInterval() {
          if (freq == 'bimestral' || freq == 'trimestral') {
            final int startRefMonth = e.startMonth ?? month;
            final int startRefYear = e.startYear ?? year;
            final int diff =
                ((year - startRefYear) * 12) + (month - startRefMonth);
            return diff >= 0 &&
                (freq == 'bimestral' ? diff % 2 == 0 : diff % 3 == 0);
          }
          return true; // mensal/quinzenal
        }

        if (!shouldGenerateForInterval()) continue;

        for (final d in days) {
          final int day = d.clamp(1, 31);
          final int effectiveDay = day <= lastDay ? day : lastDay;
          final DateTime date = DateTime(year, month, effectiveDay);
          if (!isAfterStartDate(date) || !isBeforeDeactivation(date)) continue;
          fixed.add(TransactionModel(
            id: e.id,
            value: e.value.split('\$').last,
            type: TransactionType.despesa,
            paymentDay: date.toString(),
            title: "Conta fixa: ${e.title}",
            paymentType: e.paymentType,
            category: e.category,
          ));
        }
      }
    }

    final all = [...real, ...fixed];
    if (type != null) {
      return all.where((t) => t.type == type).toList();
    }
    return all;
  }

  get isFirstDay {
    final today = DateTime.now();
    return today.day == 1;
  }

  double get totalReceita {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;
    return isFirstDay
        ? 0
        : transaction.where((t) {
            if (t.paymentDay != null) {
              DateTime paymentDate = DateTime.parse(t.paymentDay!);
              return t.type == TransactionType.receita &&
                  paymentDate.month == currentMonth &&
                  paymentDate.year == currentYear;
            }
            return false;
          }).fold<double>(
            0,
            (sum, t) =>
                sum +
                double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')),
          );
  }

  double get totalDespesas {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;
    return transaction.where((t) {
      if (t.paymentDay != null) {
        DateTime paymentDate = DateTime.parse(t.paymentDay!);
        return t.type == TransactionType.despesa &&
            paymentDate.month == currentMonth &&
            paymentDate.year == currentYear;
      }
      return false;
    }).fold<double>(
      0,
      (sum, t) =>
          sum + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')),
    );
  }

  List<TransactionModel> get transactionsAno {
    final now = DateTime.now();
    final currentYear = now.year;
    return transaction.where((t) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        return date.year == currentYear && date.isBefore(now);
      }
      return false;
    }).toList();
  }

  double get totalReceitaAno {
    final now = DateTime.now();
    final currentYear = now.year;
    return transaction.where((t) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        return t.type == TransactionType.receita &&
            date.year == currentYear &&
            date.isBefore(now);
      }
      return false;
    }).fold(
        0.0,
        (sum, t) =>
            sum +
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
  }

  double get totalDespesasAno {
    final now = DateTime.now();
    final currentYear = now.year;
    return transaction.where((t) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        return t.type == TransactionType.despesa &&
            date.year == currentYear &&
            date.isBefore(now);
      }
      return false;
    }).fold(
        0.0,
        (sum, t) =>
            sum +
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')));
  }

  double get mediaReceitaMensal {
    final now = DateTime.now();
    final currentYear = now.year;

    // Agrupa as receitas e despesas por mês
    Map<int, double> receitasPorMes = {};
    Map<int, double> despesasPorMes = {};

    for (final t in transaction) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (date.year == currentYear && date.isBefore(now)) {
          final month = date.month;
          final value =
              double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));

          if (t.type == TransactionType.receita) {
            receitasPorMes[month] = (receitasPorMes[month] ?? 0) + value;
          } else if (t.type == TransactionType.despesa) {
            despesasPorMes[month] = (despesasPorMes[month] ?? 0) + value;
          }
        }
      }
    }

    // Encontra meses que têm TANTO receitas QUANTO despesas
    final mesesCompletos = receitasPorMes.keys
        .where((mes) => despesasPorMes.containsKey(mes))
        .toList();

    if (mesesCompletos.isEmpty) return 0.0;

    final totalReceitas =
        mesesCompletos.fold(0.0, (sum, mes) => sum + receitasPorMes[mes]!);
    return totalReceitas / mesesCompletos.length;
  }

  double get mediaDespesaMensal {
    final now = DateTime.now();
    final currentYear = now.year;

    // Agrupa as receitas e despesas por mês
    Map<int, double> receitasPorMes = {};
    Map<int, double> despesasPorMes = {};

    for (final t in transaction) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        if (date.year == currentYear && date.isBefore(now)) {
          final month = date.month;
          final value =
              double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));

          if (t.type == TransactionType.receita) {
            receitasPorMes[month] = (receitasPorMes[month] ?? 0) + value;
          } else if (t.type == TransactionType.despesa) {
            despesasPorMes[month] = (despesasPorMes[month] ?? 0) + value;
          }
        }
      }
    }

    // Encontra meses que têm TANTO receitas QUANTO despesas
    final mesesCompletos = despesasPorMes.keys
        .where((mes) => receitasPorMes.containsKey(mes))
        .toList();

    if (mesesCompletos.isEmpty) return 0.0;

    final totalDespesas =
        mesesCompletos.fold(0.0, (sum, mes) => sum + despesasPorMes[mes]!);
    return totalDespesas / mesesCompletos.length;
  }

  void startTransactionStream() {
    transactionStream = FirebaseFirestore.instance
        .collection('transactions')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      var map = snapshot.docs.map((e) {
        try {
          return TransactionModel.fromMap(e.data()).copyWith(id: e.id);
        } catch (e) {
          return null;
        }
      }).toList();
      var filteredMap = map.where((e) => e != null).toList();
      _transaction.value = filteredMap.cast<TransactionModel>();
      _isLoading.value = false;
    });
  }

  Future<void> addTransaction(TransactionModel transaction,
      {bool isInstallment = false, int installments = 1}) async {
    final value = double.parse(transaction.value
        .replaceAll('R\$', '')
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.'));

    final userId = Get.find<AuthController>().firebaseUser.value?.uid;

    if (isInstallment) {
      // Batch write installments to reduce round-trips
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var i = 0; i < installments; i++) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        final newPaymentDay =
            DateTime(paymentDate.year, paymentDate.month + i, paymentDate.day)
                .toString();
        final localizedValue = value / installments;
        final localizedValueString =
            localizedValue.toStringAsFixed(2).replaceAll('.', ',');
        final txData = transaction
            .copyWith(
              userId: userId,
              value: localizedValueString,
              paymentDay: newPaymentDay,
              title: 'Parcela ${i + 1}: ${transaction.title}',
            )
            .toMap();
        final docRef =
            FirebaseFirestore.instance.collection('transactions').doc();
        batch.set(docRef, txData);
      }
      await batch.commit();
    } else {
      // Optimistic UI: add locally with a temporary id, rollback on error
      final String tempId =
          'local_${DateTime.now().microsecondsSinceEpoch.toString()}';
      final localTx = transaction.copyWith(id: tempId);
      _transaction.insert(0, localTx);
      try {
        var transactionWithUserId = transaction.copyWith(userId: userId);
        await FirebaseFirestore.instance.collection('transactions').add(
              transactionWithUserId.toMap(),
            );
      } catch (e) {
        _transaction.removeWhere((t) => t.id == tempId);
        rethrow;
      }
    }

    // Log analytics event (non-blocking)
    _analyticsService.logAddTransaction(
      type: transaction.type.toString().split('.').last,
      value: value,
      category: transaction.category?.toString(),
      paymentType: transaction.paymentType,
      isInstallment: isInstallment,
    );

    Get.snackbar('Sucesso', 'Transação adicionada com sucesso');
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    final value = double.parse(transaction.value
        .replaceAll('R\$', '')
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.'));

    // Optimistic UI: update locally and rollback on error
    final int idx = _transaction.indexWhere((t) => t.id == transaction.id);
    TransactionModel? previous;
    if (idx != -1) {
      previous = _transaction[idx];
      _transaction[idx] = transaction;
    }

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id!)
          .update(
            transaction.toMap(),
          );
    } catch (e) {
      if (idx != -1 && previous != null) {
        _transaction[idx] = previous;
      }
      rethrow;
    }

    // Log analytics event (non-blocking)
    _analyticsService.logUpdateTransaction(
      type: transaction.type.toString().split('.').last,
      value: value,
    );

    Get.snackbar('Sucesso', 'Transação atualizada com sucesso');
  }

  Future<void> deleteTransaction(String id) async {
    // Find the transaction to get its details for analytics
    final trans = _transaction.firstWhereOrNull((t) => t.id == id);

    // Optimistic UI: remove locally and rollback on error
    final removedIndex = _transaction.indexWhere((t) => t.id == id);
    TransactionModel? removedItem;
    if (removedIndex != -1) {
      removedItem = _transaction.removeAt(removedIndex);
    }

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(id)
          .delete();
    } catch (e) {
      if (removedItem != null) {
        _transaction.insert(removedIndex, removedItem);
      }
      rethrow;
    }

    // Log analytics event (non-blocking)
    if (trans != null) {
      final value = double.parse(trans.value
          .replaceAll('R\$', '')
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '.'));

      _analyticsService.logDeleteTransaction(
        type: trans.type.toString().split('.').last,
        value: value,
      );
    }

    Get.snackbar('Sucesso', 'Transação removida com sucesso');
  }

  // Percentage calculation methods
  PercentageResult get monthlyPercentageComparison {
    return PercentageCalculationService.calculateMonthlyComparison(
      transaction,
      DateTime.now(),
    );
  }

  PercentageResult get incomePercentageComparison {
    return PercentageCalculationService.calculateIncomeComparison(
      transaction,
      DateTime.now(),
    );
  }

  PercentageResult get expensePercentageComparison {
    return PercentageCalculationService.calculateExpenseComparison(
      transaction,
      DateTime.now(),
    );
  }

  // Helper otimizado para parsing de valores
  static double _parseTransactionValue(String value) {
    try {
      final cleaned = value.replaceAll('R\$', '').trim();
      if (cleaned.contains(',')) {
        return double.parse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
      }
      return double.parse(cleaned.replaceAll(' ', ''));
    } catch (_) {
      return 0.0;
    }
  }

  double getBalanceForDateRange(DateTime startDate, DateTime endDate) {
    // Normalizar datas para comparação mais eficiente
    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    double balance = 0.0;
    for (final t in transaction) {
      if (t.paymentDay == null) continue;

      try {
        final paymentDate = DateTime.parse(t.paymentDay!);
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);

        if (paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly))) {
          final value = _parseTransactionValue(t.value);
          if (t.type == TransactionType.receita) {
            balance += value;
          } else if (t.type == TransactionType.despesa) {
            balance -= value;
          }
        }
      } catch (_) {
        continue;
      }
    }
    return balance;
  }

  List<TransactionModel> getTransactionsForDateRange(
      DateTime startDate, DateTime endDate) {
    return transaction.where((t) {
      if (t.paymentDay == null) return false;

      try {
        final paymentDate = DateTime.parse(t.paymentDay!);

        // Simplificando a lógica de comparação
        final paymentDateOnly =
            DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        final startDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        return paymentDateOnly.isAtSameMomentAs(startDateOnly) ||
            paymentDateOnly.isAtSameMomentAs(endDateOnly) ||
            (paymentDateOnly.isAfter(startDateOnly) &&
                paymentDateOnly.isBefore(endDateOnly));
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
