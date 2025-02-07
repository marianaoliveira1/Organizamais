import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:uuid/uuid.dart';

import '../page/initial/widget/expense_modal.dart';

class FixedAccountsController extends GetxController {
  var id = ''.obs;
  var name = ''.obs;
  var date = ''.obs;
  var category = ''.obs;
  var amount = ''.obs;
  var paymentMethod = ''.obs;

  var fixedAccounts = <FixedAccount>[].obs; // Lista observável de contas fixas

  void reset() {
    id.value = const Uuid().v4();
    name.value = '';
    date.value = '';
    category.value = '';
    amount.value = '';
    paymentMethod.value = '';
  }

  void addFixedAccount() {
    if (name.value.isNotEmpty && amount.value.isNotEmpty && date.value.isNotEmpty) {
      fixedAccounts.add(FixedAccount(
        id: id.value,
        name: name.value,
        date: date.value,
        category: category.value,
        amount: amount.value,
        paymentMethod: paymentMethod.value,
      ));
      Get.back(); // Fecha o modal após adicionar
    }
  }

  void showBottomSheet() {
    reset(); // Limpa os valores antes de abrir
    Get.bottomSheet(
      ExpenseModal(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
    );
  }
}

// Modelo para representar uma conta fixa
class FixedAccount {
  final String id;
  final String name;
  final String date;
  final String category;
  final String amount;
  final String paymentMethod;

  FixedAccount({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
  });
}
