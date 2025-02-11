import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:organizamais/model/transaction_model.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _transactionsCollection = FirebaseFirestore.instance.collection('transactions');

  var transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      QuerySnapshot snapshot = await _transactionsCollection.get();
      transactions.value = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    } catch (error) {
      print("Error fetching transactions: $error");
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      DocumentReference docRef = await _transactionsCollection.add(transaction.toFirestore());
      transaction.id = docRef.id; // Update the transaction ID
      transactions.add(transaction);
    } catch (error) {
      print("Error adding transaction: $error");
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _transactionsCollection.doc(transaction.id).update(transaction.toFirestore());
      int index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        transactions[index] = transaction;
      }
    } catch (error) {
      print("Error updating transaction: $error");
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection.doc(id).delete();
      transactions.removeWhere((t) => t.id == id);
    } catch (error) {
      print("Error deleting transaction: $error");
    }
  }
}
