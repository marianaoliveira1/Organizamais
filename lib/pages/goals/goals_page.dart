import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/goal_controller.dart';
import '../../model/goal_model.dart';
import '../transaction/pages/category_page.dart';
import 'pages/add_goal_page.dart';
import 'pages/details_goals_page.dart';

class GoalsPage extends StatelessWidget {
  final GoalController goalController = Get.put(GoalController());

  @override
  Widget build(BuildContext context) {
    goalController.startGoalStream();
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Metas')),
      body: Obx(() {
        if (goalController.goal.isEmpty) {
          return Center(child: Text('Nenhuma meta encontrada.'));
        }
        return ListView.builder(
          itemCount: goalController.goal.length,
          itemBuilder: (context, index) {
            final GoalModel goal = goalController.goal[index];
            final String cleanedValue = goal.value.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll(',', '.');
            final double numericValue = double.tryParse(cleanedValue) ?? 0.0;
            final double progress = goal.currentValue / numericValue;
            final category = findCategoryById(goal.categoryId);

            return ListTile(
              leading: category != null ? Image.asset(category['icon'], height: 30, width: 30) : Icon(Icons.category),
              title: Text(goal.name),
              subtitle: Text(
                '${NumberFormat.currency(locale: 'pt_BR').format(goal.currentValue)} / ${NumberFormat.currency(locale: 'pt_BR').format(numericValue)}',
              ),
              trailing: CircularProgressIndicator(value: progress),
              onTap: () => Get.to(() => GoalDetailsPage(initialGoal: goal)), // Corrected line
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddGoalPage()),
        child: Icon(Icons.add),
      ),
    );
  }
}
