import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';

class ExpenseModal extends StatelessWidget {
  final FixedAccountsController controller = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final List<String> categories = [
    'Casa',
    'Educação',
    'Beleza',
    'Alimentação'
  ];
  final List<String> paymentMethods = [
    'Crédito',
    'Débito',
    'Dinheiro',
    'Pix'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Nome
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Nome"),
            onChanged: (value) => controller.name.value = value,
          ),
          SizedBox(height: 10),

          // Data
          Obx(() => TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Data",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    controller.date.value = DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
                controller: TextEditingController(text: controller.date.value),
              )),
          SizedBox(height: 10),

          // Categoria
          Obx(() => DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Categoria"),
                items: categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => controller.category.value = value!,
              )),
          SizedBox(height: 10),

          // Valor
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Valor (R\$)"),
            onChanged: (value) => controller.amount.value = value,
          ),
          SizedBox(height: 10),

          // Forma de pagamento
          Obx(() => DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Forma de Pagamento"),
                items: paymentMethods.map((String method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) => controller.paymentMethod.value = value!,
              )),
          SizedBox(height: 20),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  print("Nome: ${controller.name.value}");
                  print("Data: ${controller.date.value}");
                  print("Categoria: ${controller.category.value}");
                  print("Valor: ${controller.amount.value}");
                  print("Pagamento: ${controller.paymentMethod.value}");
                  Get.back();
                },
                child: Text("Salvar"),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
