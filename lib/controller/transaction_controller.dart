import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/auth_controller.dart';

import '../model/transaction_model.dart';

class TransactionController extends GetxController {
  var transaction = <TransactionModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? transactionStream;

  void startTransactionStream() {
    transactionStream = FirebaseFirestore.instance
        .collection('transactions')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      transaction.value = snapshot.docs
          .map(
            (e) => TransactionModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    var transactionWithUserId = transaction.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('transactions').add(
          transactionWithUserId.toMap(),
        );
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
