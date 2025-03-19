import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/widget/button_select_category.dart';

class AddGoalPage extends StatefulWidget {
  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final GoalController goalController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int? categoryId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Meta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text("Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            DefaultButtonSelectCategory(
              selectedCategory: categoryId,
              onTap: (category) {
                setState(() {
                  categoryId = category;
                });
              },
              transactionType: TransactionType.despesa,
            ),
            ElevatedButton(
              onPressed: () {
                final double value = double.tryParse(valueController.text.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll(',', '.')) ?? 0.0;
                final goal = GoalModel(
                  name: nameController.text,
                  value: NumberFormat.currency(locale: 'pt_BR').format(value), // Formata para Real Brasileiro
                  date: DateFormat('dd/MM/yyyy').format(selectedDate),
                  categoryId: categoryId ?? 0,
                  currentValue: 0,
                );
                goalController.addGoal(goal);
                Get.back();
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
