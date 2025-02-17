import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/cards_model.dart';
import 'auth_controller.dart';

class CardController extends GetxController {
  var card = <CardsModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? cardStream;

  void startCardStream() {
    cardStream = FirebaseFirestore.instance
        .collection('cards')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      card.value = snapshot.docs
          .map(
            (e) => CardsModel.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addCard(CardsModel card) async {
    var cardWithUserId = card.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('cards').add(
          cardWithUserId.toMap(),
        );
    Get.snackbar('Sucesso', 'Cartão adicionado com sucesso');
  }

  Future<void> updateCard(CardsModel card) async {
    if (card.id == null) return;
    await FirebaseFirestore.instance.collection('cards').doc(card.id).update(
          card.toMap(),
        );
    Get.snackbar('Sucesso', 'Cartão atualizado com sucesso');
  }

  Future<void> deleteCard(String id) async {
    await FirebaseFirestore.instance.collection('cards').doc(id).delete();
    Get.snackbar('Sucesso', 'Cartão removido com sucesso');
  }
}
