import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import '../model/transaction_model.dart';
import '../model/percentage_result.dart';
import '../services/percentage_calculation_service.dart';

class TransactionController extends GetxController {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? transactionStream;
  final _transaction = <TransactionModel>[].obs;
  final _isLoading = true.obs;

  FixedAccountsController get fixedAccountsController =>
      Get.find<FixedAccountsController>();

  bool get isLoading => _isLoading.value;

  List<TransactionModel> get transaction {
    var fakeTransactionsFromFixed = <TransactionModel>[];
    final today = DateTime.now();

    for (final e in fixedAccountsController.allFixedAccounts) {
      for (var i = 0; i < 2400; i++) {
        // 200 years * 12 months = 2400 months
        final transactionMonth = today.month -
            1200 +
            i; // Center around current date (100 years back, 100 years forward)
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

        final todayWithRightDay = DateTime(
            adjustedYear, adjustedNormalizedMonth, int.parse(e.paymentDay));

        // Skip if account was deactivated before this transaction date
        if (e.deactivatedAt != null) {
          if (e.deactivatedAt!.isBefore(todayWithRightDay)) {
            continue;
          }
        }

        if (e.startMonth != null && e.startYear != null) {
          final startDate =
              DateTime(e.startYear!, e.startMonth!, int.parse(e.paymentDay));
          if (todayWithRightDay.isBefore(startDate)) {
            continue;
          }
        }

        // Skip if transaction date is before the account was created
        // if (e.createdAt != null) {
        //   if (todayWithRightDay.isBefore(e.createdAt!)) {
        //     continue;
        //   }
        // }

        fakeTransactionsFromFixed.add(TransactionModel(
          id: e.id,
          value: e.value.split('\$')[1],
          type: TransactionType.despesa,
          paymentDay: todayWithRightDay.toString(),
          title: "Conta fixa: ${e.title}",
          paymentType: e.paymentType,
          category: e.category,
        ));
      }
    }

    return [..._transaction, ...fakeTransactionsFromFixed];
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
    if (isInstallment) {
      for (var i = 0; i < installments; i++) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        final newPaymentDay =
            DateTime(paymentDate.year, paymentDate.month + i, paymentDate.day)
                .toString();
        final value = double.parse(transaction.value
            .replaceAll('R\$', '')
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '.'));
        final localizedValue = value / installments;
        final localizedValueString =
            localizedValue.toStringAsFixed(2).replaceAll('.', ',');
        var transactionWithUserId = transaction.copyWith(
          userId: Get.find<AuthController>().firebaseUser.value?.uid,
          value: localizedValueString,
          paymentDay: newPaymentDay,
          title: 'Parcela ${i + 1}: ${transaction.title}',
        );
        FirebaseFirestore.instance.collection('transactions').add(
              transactionWithUserId.toMap(),
            );
      }
    } else {
      var transactionWithUserId = transaction.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid,
      );
      await FirebaseFirestore.instance.collection('transactions').add(
            transactionWithUserId.toMap(),
          );
    }
    Get.snackbar('Sucesso', 'Transação adicionada com sucesso');
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.id!)
        .update(
          transaction.toMap(),
        );
    Get.snackbar('Sucesso', 'Transação atualizada com sucesso');
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(id)
        .delete();
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

  double getBalanceForDateRange(DateTime startDate, DateTime endDate) {
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
    }).fold<double>(0.0, (balance, t) {
      try {
        final value =
            double.parse(t.value.replaceAll('.', '').replaceAll(',', '.'));
        if (t.type == TransactionType.receita) {
          return balance + value;
        } else if (t.type == TransactionType.despesa) {
          return balance - value;
        }
        return balance;
      } catch (e) {
        return balance;
      }
    });
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
