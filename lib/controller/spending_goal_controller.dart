import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/spending_goal_model.dart';
import '../model/transaction_model.dart';
import '../services/analytics_service.dart';
import 'auth_controller.dart';
import 'transaction_controller.dart';

class SpendingGoalController extends GetxController {
  var spendingGoals = <SpendingGoalModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? spendingGoalStream;
  final AnalyticsService _analyticsService = AnalyticsService();

  TransactionController get transactionController =>
      Get.find<TransactionController>();

  void startSpendingGoalStream() {
    spendingGoalStream = FirebaseFirestore.instance
        .collection('spending_goals')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      spendingGoals.value = snapshot.docs
          .map(
            (e) => SpendingGoalModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addSpendingGoal(SpendingGoalModel spendingGoal) async {
    var spendingGoalWithUserId = spendingGoal.copyWith(
      userId: Get.find<AuthController>().firebaseUser.value?.uid,
    );
    await FirebaseFirestore.instance
        .collection('spending_goals')
        .add(spendingGoalWithUserId.toMap());

    // Log analytics event
    await _analyticsService.logAddSpendingGoal(
      category: spendingGoal.categoryId.toString(),
      limit: spendingGoal.limitValue,
    );

    Get.snackbar('Sucesso', 'Meta de gasto adicionada com sucesso');
  }

  Future<void> updateSpendingGoal(SpendingGoalModel spendingGoal) async {
    if (spendingGoal.id == null) return;
    await FirebaseFirestore.instance
        .collection('spending_goals')
        .doc(spendingGoal.id)
        .update(spendingGoal.toMap());

    // Log analytics event
    await _analyticsService
        .logUpdateSpendingGoal(spendingGoal.categoryId.toString());

    Get.snackbar('Sucesso', 'Meta de gasto atualizada com sucesso');
  }

  Future<void> deleteSpendingGoal(String id) async {
    // Get spending goal for analytics before deletion
    final goalToDelete = spendingGoals.firstWhereOrNull((g) => g.id == id);

    // Marca como inativo em vez de deletar
    await FirebaseFirestore.instance
        .collection('spending_goals')
        .doc(id)
        .update({'isActive': false});

    // Log analytics event
    if (goalToDelete != null) {
      await _analyticsService
          .logDeleteSpendingGoal(goalToDelete.categoryId.toString());
    }

    Get.snackbar('Sucesso', 'Meta de gasto removida com sucesso');
  }

  /// Calcula o valor gasto em uma categoria específica no mês/ano
  double calculateSpentAmount(int categoryId, int month, int year) {
    return transactionController.transaction.where((transaction) {
      if (transaction.paymentDay == null) return false;
      if (transaction.type != TransactionType.despesa) return false;
      if (transaction.category != categoryId) return false;

      final paymentDate = DateTime.parse(transaction.paymentDay!);
      return paymentDate.month == month && paymentDate.year == year;
    }).fold<double>(0.0, (total, transaction) {
      final value = double.tryParse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          ) ??
          0.0;
      return total + value;
    });
  }

  /// Calcula o progresso percentual de uma meta (0.0 a 1.0)
  double calculateProgress(SpendingGoalModel spendingGoal) {
    final spentAmount = calculateSpentAmount(
      spendingGoal.categoryId,
      spendingGoal.month,
      spendingGoal.year,
    );
    return spendingGoal.limitValue > 0
        ? spentAmount / spendingGoal.limitValue
        : 0.0;
  }

  /// Verifica se uma meta foi ultrapassada
  bool isGoalExceeded(SpendingGoalModel spendingGoal) {
    return calculateProgress(spendingGoal) > 1.0;
  }

  /// Retorna o valor restante para atingir o limite
  double getRemainingAmount(SpendingGoalModel spendingGoal) {
    final spentAmount = calculateSpentAmount(
      spendingGoal.categoryId,
      spendingGoal.month,
      spendingGoal.year,
    );
    return spendingGoal.limitValue - spentAmount;
  }

  /// Retorna metas do mês atual
  List<SpendingGoalModel> getCurrentMonthGoals() {
    final now = DateTime.now();
    return spendingGoals
        .where((goal) => goal.month == now.month && goal.year == now.year)
        .toList();
  }

  /// Retorna metas de um mês específico
  List<SpendingGoalModel> getGoalsForMonth(int month, int year) {
    return spendingGoals
        .where((goal) => goal.month == month && goal.year == year)
        .toList();
  }

  /// Verifica se já existe uma meta para a categoria no mês/ano
  bool hasGoalForCategory(int categoryId, int month, int year) {
    return spendingGoals.any(
      (goal) =>
          goal.categoryId == categoryId &&
          goal.month == month &&
          goal.year == year,
    );
  }

  /// Formata valor monetário para o padrão brasileiro
  String formatCurrency(double value) {
    String stringValue = value.toStringAsFixed(2);
    stringValue = stringValue.replaceAll('.', ',');

    List<String> parts = stringValue.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    if (integerPart.length > 3) {
      String result = '';
      int count = 0;

      for (int i = integerPart.length - 1; i >= 0; i--) {
        result = integerPart[i] + result;
        count++;

        if (count % 3 == 0 && i > 0) {
          result = '.$result';
        }
      }
      integerPart = result;
    }

    return "R\$ $integerPart,$decimalPart";
  }

  @override
  void onClose() {
    spendingGoalStream?.cancel();
    super.onClose();
  }
}
