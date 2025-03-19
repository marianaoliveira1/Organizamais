import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../transaction/pages/category_page.dart';
import 'add_goal_page.dart';

class GoalDetailsPage extends StatelessWidget {
  final GoalModel initialGoal;
  final GoalController goalController = Get.find();

  GoalDetailsPage({required this.initialGoal});

  @override
  Widget build(BuildContext context) {
    final goal = ValueNotifier<GoalModel>(initialGoal);

    return Scaffold(
      appBar: AppBar(
        title: Text(initialGoal.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              goalController.deleteGoal(initialGoal.id!);
              Get.back();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<GoalModel>(
          valueListenable: goal,
          builder: (context, currentGoal, child) {
            if (currentGoal == null) {
              return Center(child: Text('Meta não encontrada.'));
            }

            final String cleanedValue = currentGoal.value.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll(',', '.');
            final double numericValue = double.tryParse(cleanedValue) ?? 0.0;
            final double progress = currentGoal.currentValue / numericValue;
            final category = findCategoryById(currentGoal.categoryId);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (category != null) Image.asset(category['icon'], height: 30, width: 30) else Icon(Icons.category),
                    SizedBox(width: 8),
                    Text(
                      category != null ? category['name'] : 'Categoria não encontrada',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Valor: ${NumberFormat.currency(locale: 'pt_BR').format(numericValue)}'),
                Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(DateFormat('dd/MM/yyyy', 'pt_BR').parse(currentGoal.date))}'),
                SizedBox(height: 16),
                LinearProgressIndicator(value: progress),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAddValueBottomSheet(context, goal),
                      child: Text('Adicionar Valor'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showRemoveValueBottomSheet(context, goal),
                      child: Text('Remover Valor'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddValueBottomSheet(BuildContext context, ValueNotifier<GoalModel> goal) {
    double valueToAdd = 0;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Valor a adicionar'),
                    onChanged: (value) {
                      valueToAdd = double.tryParse(value) ?? 0;
                    },
                  ),
                  ListTile(
                    title: Text("Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        modalSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Text('Adicionar'),
                    onPressed: () {
                      if (goal.value == null) return;
                      final updatedGoal = goal.value.copyWith(
                        currentValue: goal.value.currentValue + valueToAdd,
                      );
                      goalController.updateGoal(updatedGoal);
                      goal.value = updatedGoal;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRemoveValueBottomSheet(BuildContext context, ValueNotifier<GoalModel> goal) {
    double valueToRemove = 0;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Valor a remover'),
                    onChanged: (value) {
                      valueToRemove = double.tryParse(value) ?? 0;
                    },
                  ),
                  ListTile(
                    title: Text("Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        modalSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Text('Remover'),
                    onPressed: () {
                      if (goal.value == null) return;
                      final updatedGoal = goal.value.copyWith(
                        currentValue: goal.value.currentValue - valueToRemove,
                      );
                      goalController.updateGoal(updatedGoal);
                      goal.value = updatedGoal;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
