// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

import '../model/fixed_account_model.dart';

class FixedAccountsController extends GetxController {
  final _allFixedAccounts = <FixedAccountModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? fixedAccountsStream;

  var isLoading = true.obs;

  List<FixedAccountModel> get fixedAccounts {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    return _allFixedAccounts.where((account) {
      // Show account if it was never deactivated
      if (account.deactivatedAt == null) return true;

      // Hide account if it was deactivated before the current month
      return account.deactivatedAt!.isAfter(currentMonthStart) ||
          account.deactivatedAt!.isAtSameMomentAs(currentMonthStart);
    }).toList();
  }

  List<FixedAccountModel> get fixedAccountsWithDeactivated {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

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
    });
  }

  Future<void> addFixedAccount(FixedAccountModel fixedAccount) async {
    var fixedAccountWithUserId = fixedAccount.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('fixedAccounts').add(
          fixedAccountWithUserId.toMap(),
        );
    Get.snackbar('Sucesso', 'Conta fixa adicionada com sucesso');
  }

  Future<void> updateFixedAccount(FixedAccountModel fixedAccount) async {
    if (fixedAccount.id == null) {
      print(fixedAccount.id);
      throw Exception('Fixed account id is null');
    }
    await FirebaseFirestore.instance
        .collection('fixedAccounts')
        .doc(fixedAccount.id)
        .update(
          fixedAccount.toMap(),
        );
    Get.snackbar('Sucesso', 'Conta fixa atualizada com sucesso');
  }

  Future<void> disableFixedAccount(String id) async {
    await FirebaseFirestore.instance
        .collection('fixedAccounts')
        .doc(id)
        .update({
      'deactivatedAt': DateTime.now().toIso8601String(),
    });
    Get.snackbar('Sucesso', 'Conta fixa desabilitada com sucesso');
  }

  Future<void> reactivateFixedAccount(String id) async {
    await FirebaseFirestore.instance
        .collection('fixedAccounts')
        .doc(id)
        .update({
      'deactivatedAt': null,
    });
    Get.snackbar('Sucesso', 'Conta fixa reativada com sucesso');
  }

  Future<void> deleteFixedAccount(String id) async {
    await FirebaseFirestore.instance
        .collection('fixedAccounts')
        .doc(id)
        .delete();
    Get.snackbar('Sucesso', 'Conta fixa removida permanentemente');
  }
}
