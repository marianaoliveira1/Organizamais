// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

import '../model/fixed_account_model.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';

class FixedAccountsController extends GetxController {
  final _allFixedAccounts = <FixedAccountModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? fixedAccountsStream;
  final AnalyticsService _analyticsService = AnalyticsService();

  var isLoading = true.obs;

  List<FixedAccountModel> get fixedAccounts {
    final now = DateTime.now();

    return _allFixedAccounts.where((account) {
      final currentMonthStart = DateTime(now.year, now.month, 1);
      // Show account if it was never deactivated
      if (account.deactivatedAt == null) return true;

      // Hide account if it was deactivated before the current month
      return account.deactivatedAt!.isAfter(currentMonthStart) ||
          account.deactivatedAt!.isAtSameMomentAs(currentMonthStart);
    }).toList();
  }

  List<FixedAccountModel> get fixedAccountsWithDeactivated {
    final now = DateTime.now();

    return _allFixedAccounts.where((account) {
      // Show account if it was never deactivated
      if (account.deactivatedAt == null) return true;

      // Show recently deactivated accounts (within current month) for visual feedback
      final thirtyDaysAgo = now.subtract(Duration(days: 30));
      return account.deactivatedAt!.isAfter(thirtyDaysAgo);
    }).toList();
  }

  bool isAccountDeactivated(FixedAccountModel account) {
    return account.deactivatedAt != null;
    // if (account.deactivatedAt == null) return false;
    // final now = DateTime.now();
    // final currentMonthStart = DateTime(now.year, now.month, 1);
    // return account.deactivatedAt!.isBefore(currentMonthStart);
  }

  List<FixedAccountModel> get allFixedAccounts => _allFixedAccounts;

  void startFixedAccountsStream() {
    fixedAccountsStream = FirebaseFirestore.instance
        .collection('fixedAccounts')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      _allFixedAccounts.value = snapshot.docs
          .map(
            (e) => FixedAccountModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
      isLoading.value = false;

      // Reagendar notificações simples (12:00 no dia)
      NotificationService().rescheduleAll(_allFixedAccounts);
    });
  }

  Future<void> addFixedAccount(FixedAccountModel fixedAccount) async {
    var fixedAccountWithUserId = fixedAccount.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid);

    // UI otimista: inserir localmente e reverter se falhar
    final String tempId =
        'local_${DateTime.now().microsecondsSinceEpoch.toString()}';
    final local = fixedAccountWithUserId.copyWith(id: tempId);
    _allFixedAccounts.insert(0, local);
    try {
      await FirebaseFirestore.instance.collection('fixedAccounts').add(
            fixedAccountWithUserId.toMap(),
          );
    } catch (e) {
      _allFixedAccounts.removeWhere((a) => a.id == tempId);
      rethrow;
    }

    // Log analytics (não bloqueante)
    final value = double.tryParse(fixedAccount.value
            .split('\$')
            .last
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0.0;
    _analyticsService.logAddFixedAccount(
      accountName: fixedAccount.title,
      value: value,
      frequency: fixedAccount.frequency ?? 'mensal',
    );

    Get.snackbar('Sucesso', 'Conta fixa adicionada com sucesso');
    // Reagendar notificação (não bloqueante)
    NotificationService().scheduleDueDay(fixedAccountWithUserId);
  }

  Future<void> updateFixedAccount(FixedAccountModel fixedAccount) async {
    if (fixedAccount.id == null) {
      // print(fixedAccount.id);
      throw Exception('Fixed account id is null');
    }
    // UI otimista com rollback
    final int idx =
        _allFixedAccounts.indexWhere((a) => a.id == fixedAccount.id);
    FixedAccountModel? prev;
    if (idx != -1) {
      prev = _allFixedAccounts[idx];
      _allFixedAccounts[idx] = fixedAccount;
    }

    try {
      await FirebaseFirestore.instance
          .collection('fixedAccounts')
          .doc(fixedAccount.id)
          .update(
            fixedAccount.toMap(),
          );
    } catch (e) {
      if (idx != -1 && prev != null) {
        _allFixedAccounts[idx] = prev;
      }
      rethrow;
    }

    // Log analytics (não bloqueante)
    _analyticsService.logUpdateFixedAccount(fixedAccount.title);

    Get.snackbar('Sucesso', 'Conta fixa atualizada com sucesso');
    // Reagendar notificação (não bloqueante)
    NotificationService().scheduleDueDay(fixedAccount);
  }

  Future<void> disableFixedAccount(String id) async {
    // UI otimista
    final int idx = _allFixedAccounts.indexWhere((a) => a.id == id);
    DateTime? prevDate;
    if (idx != -1) {
      prevDate = _allFixedAccounts[idx].deactivatedAt;
      _allFixedAccounts[idx] =
          _allFixedAccounts[idx].copyWith(deactivatedAt: DateTime.now());
    }
    try {
      await FirebaseFirestore.instance
          .collection('fixedAccounts')
          .doc(id)
          .update({
        'deactivatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (idx != -1) {
        _allFixedAccounts[idx] = _allFixedAccounts[idx].copyWith(
          deactivatedAt: prevDate,
        );
      }
      rethrow;
    }
    Get.snackbar('Sucesso', 'Conta fixa desabilitada com sucesso');
    NotificationService().cancelFor(id);
  }

  Future<void> reactivateFixedAccount(String id) async {
    // UI otimista
    final int idx = _allFixedAccounts.indexWhere((a) => a.id == id);
    DateTime? prevDate;
    if (idx != -1) {
      prevDate = _allFixedAccounts[idx].deactivatedAt;
      _allFixedAccounts[idx] = _allFixedAccounts[idx].copyWith(
        deactivatedAt: null,
      );
    }
    try {
      await FirebaseFirestore.instance
          .collection('fixedAccounts')
          .doc(id)
          .update({
        'deactivatedAt': null,
      });
    } catch (e) {
      if (idx != -1) {
        _allFixedAccounts[idx] = _allFixedAccounts[idx].copyWith(
          deactivatedAt: prevDate,
        );
      }
      rethrow;
    }
    Get.snackbar('Sucesso', 'Conta fixa reativada com sucesso');
    final account = _allFixedAccounts.firstWhereOrNull((a) => a.id == id);
    if (account != null) {
      NotificationService().scheduleDueDay(account);
    }
  }

  Future<void> deleteFixedAccount(String id) async {
    // Get fixed account name for analytics before deletion
    final accountToDelete =
        _allFixedAccounts.firstWhereOrNull((a) => a.id == id);

    // UI otimista com rollback
    final removedIndex = _allFixedAccounts.indexWhere((a) => a.id == id);
    FixedAccountModel? removedItem;
    if (removedIndex != -1) {
      removedItem = _allFixedAccounts.removeAt(removedIndex);
    }

    try {
      await FirebaseFirestore.instance
          .collection('fixedAccounts')
          .doc(id)
          .delete();
    } catch (e) {
      if (removedItem != null) {
        _allFixedAccounts.insert(removedIndex, removedItem);
      }
      rethrow;
    }

    // Log analytics (não bloqueante)
    if (accountToDelete != null) {
      _analyticsService.logDeleteFixedAccount(accountToDelete.title);
    }

    Get.snackbar('Sucesso', 'Conta fixa removida permanentemente');
    NotificationService().cancelFor(id);
  }
}
