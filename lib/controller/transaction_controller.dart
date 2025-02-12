import 'package:get/get.dart';

import '../model/transaction_model.dart';

class TransactionController extends GetxController {
  final _transactions = <TransactionModel>[].obs;
  final _selectedCategory = Rxn<String>();
  final _description = ''.obs;
  final _amount = 0.0.obs;
  final _date = DateTime.now().obs;
  final _isRecurring = false.obs;
  final _isInstallment = false.obs;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  String? get selectedCategory => _selectedCategory.value;
  String get description => _description.value;
  double get amount => _amount.value;
  DateTime get date => _date.value;
  bool get isRecurring => _isRecurring.value;
  bool get isInstallment => _isInstallment.value;

  // Filtered transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // CRUD Operations
  Future<void> addTransaction(TransactionType type, String accountId) async {
    if (_selectedCategory.value == null || _description.value.isEmpty || _amount.value <= 0) {
      Get.snackbar('Erro', 'Preencha todos os campos obrigatórios');
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _description.value,
      amount: _amount.value,
      date: _date.value,
      categoryId: _selectedCategory.value!,
      type: type,
      accountId: accountId,
      isRecurring: _isRecurring.value,
      isInstallment: _isInstallment.value,
    );

    _transactions.add(transaction);
    _clearForm();
    Get.back();
    Get.snackbar('Sucesso', 'Transação adicionada com sucesso');
  }

  Future<void> updateTransaction(String id, TransactionType type, String accountId) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      Get.snackbar('Erro', 'Transação não encontrada');
      return;
    }

    final updatedTransaction = TransactionModel(
      id: id,
      description: _description.value,
      amount: _amount.value,
      date: _date.value,
      categoryId: _selectedCategory.value!,
      type: type,
      accountId: accountId,
      isRecurring: _isRecurring.value,
      isInstallment: _isInstallment.value,
    );

    _transactions[index] = updatedTransaction;
    _clearForm();
    Get.back();
    Get.snackbar('Sucesso', 'Transação atualizada com sucesso');
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      Get.snackbar('Erro', 'Transação não encontrada');
      return;
    }

    _transactions.removeAt(index);
    Get.snackbar('Sucesso', 'Transação excluída com sucesso');
  }

  void loadTransactionForEdit(String id) {
    final transaction = _transactions.firstWhere((t) => t.id == id);
    _description.value = transaction.description;
    _amount.value = transaction.amount;
    _date.value = transaction.date;
    _selectedCategory.value = transaction.categoryId;
    _isRecurring.value = transaction.isRecurring;
    _isInstallment.value = transaction.isInstallment;
  }

  void _clearForm() {
    _description.value = '';
    _amount.value = 0.0;
    _date.value = DateTime.now();
    _selectedCategory.value = null;
    _isRecurring.value = false;
    _isInstallment.value = false;
  }

  // Setters
  void setCategory(String categoryId) => _selectedCategory.value = categoryId;
  void setDescription(String description) => _description.value = description;
  void setAmount(double amount) => _amount.value = amount;
  void setDate(DateTime date) => _date.value = date;
  void toggleRecurring() => _isRecurring.value = !_isRecurring.value;
  void toggleInstallment() => _isInstallment.value = !_isInstallment.value;
}
