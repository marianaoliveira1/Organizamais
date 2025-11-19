import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import '../model/goal_model.dart';
import '../services/analytics_service.dart';
import '../utils/snackbar_helper.dart';
import 'auth_controller.dart';

class GoalController extends GetxController {
  var goal = <GoalModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? goalStream;
  final AnalyticsService _analyticsService = AnalyticsService();

  void startGoalStream() {
    goalStream = FirebaseFirestore.instance
        .collection('goals')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      goal.value = snapshot.docs
          .map(
            (e) => GoalModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    var goalWithUserId = goal.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('goals').add(
          goalWithUserId.toMap(),
        );

    // Log analytics event
    final targetValue = double.tryParse(goal.value
            .replaceAll('R\$', '')
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0.0;
    await _analyticsService.logAddGoal(
      goalName: goal.name,
      targetValue: targetValue,
    );

    SnackbarHelper.showSuccess('Meta adicionada com sucesso');
  }

  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id == null) return;
    await FirebaseFirestore.instance.collection('goals').doc(goal.id).update(
          goal.toMap(),
        );

    // Log analytics event
    await _analyticsService.logUpdateGoal(goal.name);

    SnackbarHelper.showSuccess('Meta atualizada com sucesso');
  }

  Future<void> deleteGoal(String id) async {
    // Get goal name for analytics before deletion
    final goalToDelete = goal.firstWhereOrNull((g) => g.id == id);

    await FirebaseFirestore.instance.collection('goals').doc(id).delete();

    // Log analytics event
    if (goalToDelete != null) {
      await _analyticsService.logDeleteGoal(goalToDelete.name);
    }

    SnackbarHelper.showSuccess('Meta removida com sucesso');
  }
}
