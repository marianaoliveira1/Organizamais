import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/cards_model.dart';
import '../services/analytics_service.dart';
import 'auth_controller.dart';

class CardController extends GetxController {
  var card = <CardsModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? cardStream;
  final AnalyticsService _analyticsService = AnalyticsService();

  void startCardStream() {
    // Cancelar stream anterior se existir para evitar múltiplas subscrições
    cardStream?.cancel();

    cardStream = FirebaseFirestore.instance
        .collection('cards')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      // Usar List.generate para melhor performance
      final List<CardsModel> newCards = [];
      for (final doc in snapshot.docs) {
        try {
          final card = CardsModel.fromMap(doc.data()).copyWith(id: doc.id);
          newCards.add(card);
        } catch (_) {
          // Ignorar documentos inválidos
        }
      }
      card.value = newCards;
    });
  }

  Future<void> addCard(CardsModel card) async {
    var cardWithUserId = card.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid);

    // UI otimista com id temporário
    final String tempId =
        'local_${DateTime.now().microsecondsSinceEpoch.toString()}';
    final local = cardWithUserId.copyWith(id: tempId);
    this.card.insert(0, local);
    try {
      await FirebaseFirestore.instance.collection('cards').add(
            cardWithUserId.toMap(),
          );
    } catch (e) {
      this.card.removeWhere((c) => c.id == tempId);
      rethrow;
    }

    // Log analytics (não bloqueante)
    _analyticsService.logAddCard(card.name);

    // Snackbar removido para melhorar performance - a UI já atualiza otimisticamente
  }

  Future<void> updateCard(CardsModel card) async {
    if (card.id == null) return;
    // UI otimista com rollback
    final int idx = this.card.indexWhere((c) => c.id == card.id);
    CardsModel? prev;
    if (idx != -1) {
      prev = this.card[idx];
      this.card[idx] = card;
    }

    try {
      await FirebaseFirestore.instance.collection('cards').doc(card.id).update(
            card.toMap(),
          );
    } catch (e) {
      if (idx != -1 && prev != null) {
        this.card[idx] = prev;
      }
      rethrow;
    }

    // Log analytics (não bloqueante)
    _analyticsService.logUpdateCard(card.name);

    // Snackbar removido para melhorar performance - a UI já atualiza otimisticamente
  }

  Future<void> deleteCard(String id) async {
    // Get card name for analytics before deletion
    final cardToDelete = card.firstWhereOrNull((c) => c.id == id);

    // UI otimista com rollback
    final removedIndex = card.indexWhere((c) => c.id == id);
    CardsModel? removedItem;
    if (removedIndex != -1) {
      removedItem = card.removeAt(removedIndex);
    }

    try {
      await FirebaseFirestore.instance.collection('cards').doc(id).delete();
    } catch (e) {
      if (removedItem != null) {
        card.insert(removedIndex, removedItem);
      }
      rethrow;
    }

    // Log analytics (não bloqueante)
    if (cardToDelete != null) {
      _analyticsService.logDeleteCard(cardToDelete.name);
    }

    // Snackbar removido para melhorar performance - a UI já atualiza otimisticamente
  }

  Future<void> markInvoicePaid(
      {required String cardId, required String invoiceKey}) async {
    final doc = FirebaseFirestore.instance.collection('cards').doc(cardId);
    await doc.update({
      'paidInvoices': FieldValue.arrayUnion([invoiceKey])
    });
  }
}
