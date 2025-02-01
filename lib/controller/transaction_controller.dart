import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller to manage the transaction state
class TransactionController extends GetxController {
  var transactionType = 'receita'.obs;
  var value = 0.0.obs;
  var title = ''.obs;
  var description = ''.obs;
  var selectedDate = DateTime.now().obs;

  // Get the primary color based on transaction type
  Color get primaryColor {
    switch (transactionType.value) {
      case 'receita':
        return Colors.green;
      case 'despesa':
        return Colors.red;
      case 'transferência':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }
}
