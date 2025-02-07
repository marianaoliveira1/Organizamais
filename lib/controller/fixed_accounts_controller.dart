import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../utils/color.dart';

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

class FixedAccountsController extends GetxController {
  var fixedAccounts = <FixedAccount>[].obs; // ✅ Lista observável

  void addFixedAccount(String name, String date, String category, String amount, String paymentMethod) {
    fixedAccounts.add(FixedAccount(
      id: const Uuid().v4(),
      name: name,
      date: date,
      category: category,
      amount: amount,
      paymentMethod: paymentMethod,
    ));
    Get.back(); // Fecha o modal após adicionar a conta fixa
  }

  void showBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DefaultColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Adicionar Conta Fixa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: "Nome"),
              controller: TextEditingController(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Valor"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você adiciona os dados à lista de fixedAccounts
                // Exemplo:
                // fixedAccounts.add(FixedAccount(name: "Exemplo", amount: "100", ...));
                Get.back(); // Fecha o modal
              },
              child: const Text("Adicionar"),
            ),
          ],
        ),
      ),
    );
  }
}
