import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';

import '../model/transaction_model.dart';

class TransactionController extends GetxController {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? transactionStream;
  final _transaction = <TransactionModel>[].obs;
  FixedAccountsController get fixedAccountsController => Get.find<FixedAccountsController>();

  List<TransactionModel> get transaction {
    var fakeTransactionsFromFixed = <TransactionModel>[];

    for (final e in fixedAccountsController.fixedAccounts) {
      final today = DateTime.now();

      for (var i = 0; i < 12; i++) {
        final todayWithRightDay = DateTime(today.year, today.month - 6 + i, int.parse(e.paymentDay));

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

    return [
      ..._transaction,
      ...fakeTransactionsFromFixed
    ];
  }

  get isFirstDay {
    final today = DateTime.now();
    return today.day == 1;
  }

  get totalReceita {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;
    return isFirstDay
        ? 0
        : transaction.where((t) {
            if (t.paymentDay != null) {
              DateTime paymentDate = DateTime.parse(t.paymentDay!); // Converte a string para DateTime
              return t.type == TransactionType.receita && paymentDate.month == currentMonth && paymentDate.year == currentYear;
            }
            return false; // Caso paymentDay seja nulo
          }).fold<double>(
            0,
            (sum, t) =>
                sum +
                double.parse(
                  t.value.replaceAll('.', '').replaceAll(',', '.'),
                ),
          );
  }

  get totalDespesas {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;
    return transaction.where((t) {
      if (t.paymentDay != null) {
        DateTime paymentDate = DateTime.parse(t.paymentDay!); // Converte a string para DateTime
        return t.type == TransactionType.despesa && paymentDate.month == currentMonth && paymentDate.year == currentYear;
      }
      return false; // Caso paymentDay seja nulo
    }).fold<double>(
      0,
      (sum, t) => sum + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')),
    );
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
      var map = snapshot.docs.map(
        (e) {
          try {
            return TransactionModel.fromMap(e.data()).copyWith(id: e.id);
          } catch (e) {
            return null;
          }
        },
      ).toList();
      var filteredMap = map.where((e) => e != null).toList();
      _transaction.value = filteredMap.cast<TransactionModel>();
    });
  }

  Future<void> addTransaction(TransactionModel transaction, {bool isInstallment = false, int installments = 1}) async {
    if (isInstallment) {
      for (var i = 0; i < installments; i++) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        final newPaymentDay = DateTime(paymentDate.year, paymentDate.month + i, paymentDate.day).toString();
        final value = double.parse(transaction.value.replaceAll('R\$', '').trim().replaceAll('.', '').replaceAll(',', '.'));
        final localizedValue = value / installments;
        final localizedValueString = localizedValue.toStringAsFixed(2).replaceAll('.', ',');
        var transactionWithUserId = transaction.copyWith(
          userId: Get.find<AuthController>().firebaseUser.value?.uid,
          value: localizedValueString,
          paymentDay: newPaymentDay,
          title: 'Parcela ${i + 1}: ${transaction.title}',
        );
        print(transactionWithUserId.toMap());
        FirebaseFirestore.instance.collection('transactions').add(
              transactionWithUserId.toMap(),
            );
      }
    } else {
      var transactionWithUserId = transaction.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
      await FirebaseFirestore.instance.collection('transactions').add(
            transactionWithUserId.toMap(),
          );
    }
    Get.snackbar('Sucesso', 'Transação adicionada com sucesso');
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;
    await FirebaseFirestore.instance.collection('transactions').doc(transaction.id).update(
          transaction.toMap(),
        );
    Get.snackbar('Sucesso', 'Transação atualizada com sucesso');
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
    Get.snackbar('Sucesso', 'Transação removida com sucesso');
  }
}
