import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import '../model/goal_model.dart';
import 'auth_controller.dart';

class GoalController extends GetxController {
  var goal = <GoalModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? goalStream;

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
    var goalWithUserId = goal.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('goals').add(
          goalWithUserId.toMap(),
        );
    Get.snackbar('Sucesso', 'Meta adicionada com sucesso');
  }

  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id == null) return;
    await FirebaseFirestore.instance.collection('goals').doc(goal.id).update(
          goal.toMap(),
        );
    Get.snackbar('Sucesso', 'Meta atualizada com sucesso');
  }

  Future<void> deleteGoal(String id) async {
    await FirebaseFirestore.instance.collection('goals').doc(id).delete();
    Get.snackbar('Sucesso', 'Meta removida com sucesso');
  }
}
