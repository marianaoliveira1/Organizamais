// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

import '../model/fixed_account_model.dart';

class FixedAccountsController extends GetxController {
  var fixedAccounts = <FixedAccountModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? fixedAccountsStream;

  void startFixedAccountsStream() {
    fixedAccountsStream = FirebaseFirestore.instance
        .collection('fixedAccounts')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      fixedAccounts.value = snapshot.docs
          .map(
            (e) => FixedAccountModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addFixedAccount(FixedAccountModel fixedAccount) async {
    var fixedAccountWithUserId = fixedAccount.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
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
    await FirebaseFirestore.instance.collection('fixedAccounts').doc(fixedAccount.id).update(
          fixedAccount.toMap(),
        );
    Get.snackbar('Sucesso', 'Conta fixa atualizada com sucesso');
  }

  Future<void> deleteFixedAccount(String id) async {
    await FirebaseFirestore.instance.collection('fixedAccounts').doc(id).delete();
    Get.snackbar('Sucesso', 'Conta fixa removida com sucesso');
  }
}
