import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';

class ExpenseModal extends StatelessWidget {
  final FixedAccountsController controller = Get.put(FixedAccountsController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();

  ExpenseModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Nome"),
          ),
          TextField(
            controller: dateController,
            decoration: InputDecoration(labelText: "Data"),
          ),
          TextField(
            controller: categoryController,
            decoration: InputDecoration(labelText: "Categoria"),
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: "Valor"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: paymentMethodController,
            decoration: InputDecoration(labelText: "Forma de Pagamento"),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // controller.addFixedAccount(
              //   nameController.text,
              //   dateController.text,
              //   categoryController.text,
              //   amountController.text,
              //   paymentMethodController.text,
              // );
            },
            child: Text("Adicionar"),
          ),
        ],
      ),
    );
  }
}
