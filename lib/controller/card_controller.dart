import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

    // IMPORTANTE: Capturar o nome antigo ANTES de qualquer atualização otimista
    final int idx = this.card.indexWhere((c) => c.id == card.id);
    CardsModel? prev;
    String? oldName;
    if (idx != -1) {
      prev = this.card[idx];
      oldName = prev.name; // Guardar o nome antigo ANTES de atualizar
      debugPrint(
          '🔄 updateCard: Nome antigo capturado: "$oldName" (trim: "${oldName.trim()}"), novo nome: "${card.name}" (trim: "${card.name.trim()}")');
    } else {
      debugPrint('⚠️ updateCard: Cartão não encontrado na lista local');
    }

    // IMPORTANTE: Normalizar o nome do cartão antes de salvar (remover espaços extras)
    // Isso garante consistência entre o nome do cartão e o paymentType das transações
    final normalizedCard = card.copyWith(name: card.name.trim());

    // UI otimista com rollback
    if (idx != -1) {
      this.card[idx] = normalizedCard;
    }

    try {
      await FirebaseFirestore.instance.collection('cards').doc(card.id).update(
            normalizedCard.toMap(),
          );

      // Atualizar transações em background para não bloquear a UI
      if (oldName != null) {
        final oldNameTrimmed = oldName.trim();
        final newNameTrimmed = normalizedCard.name.trim();

        if (oldNameTrimmed != newNameTrimmed) {
          // Executar atualização de transações em background (não bloqueia a UI)
          Future.microtask(() async {
            try {
              await _updateAllRelatedTransactions(
                  card.id!, oldNameTrimmed, newNameTrimmed);
            } catch (e) {
              debugPrint('❌ Erro ao atualizar transações em background: $e');
            }
          });
        }
      }
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

  /// OTIMIZADO: Atualiza todas as transações relacionadas em uma única busca
  /// Combina todas as buscas em uma única função para melhor performance
  Future<void> _updateAllRelatedTransactions(
      String cardId, String oldName, String newName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) {
        debugPrint('⚠️ _updateAllRelatedTransactions: userId é null');
        return;
      }

      final oldNameTrimmed = oldName.trim();
      final newNameTrimmed = newName.trim();
      final oldNameLower = oldNameTrimmed.toLowerCase();
      final newNameLower = newNameTrimmed.toLowerCase();

      if (kDebugMode) {
        debugPrint(
            '🔄 _updateAllRelatedTransactions: Atualizando transações de "$oldNameTrimmed" para "$newNameTrimmed"');
      }

      // UMA ÚNICA busca no Firestore (otimização de performance)
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      if (transactionsSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
              'ℹ️ _updateAllRelatedTransactions: Nenhuma transação encontrada');
        }
        return;
      }

      // Verificar quais cartões existem para evitar conflitos
      final existingCardNames = <String>{};
      try {
        final CardController cardController = Get.find<CardController>();
        for (final c in cardController.card) {
          if (c.id != cardId) {
            existingCardNames.add(c.name.trim().toLowerCase());
          }
        }
      } catch (_) {}

      // Filtrar TODAS as transações que precisam ser atualizadas em uma única passada
      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType == null || paymentType.trim().isEmpty) return false;

        final pt = paymentType.trim();
        final ptLower = pt.toLowerCase();

        // Não atualizar se corresponde a outro cartão existente
        if (existingCardNames.contains(ptLower)) {
          return false;
        }

        // 1. Nome exato (case-insensitive) - PRINCIPAL
        if (ptLower == oldNameLower) return true;

        // 2. PaymentType que começa com o nome antigo (se novo nome também começa com antigo)
        if (newNameLower.startsWith(oldNameLower) &&
            ptLower.startsWith(oldNameLower) &&
            ptLower != oldNameLower &&
            !ptLower.startsWith(newNameLower)) {
          return true;
        }

        // 3. PaymentType que contém o nome antigo como palavra completa
        if (oldNameLower.length >= 3 &&
            (ptLower.contains(' $oldNameLower ') ||
                ptLower.startsWith('$oldNameLower ') ||
                ptLower.endsWith(' $oldNameLower'))) {
          return true;
        }

        return false;
      }).toList();

      if (transactionsToUpdate.isEmpty) {
        if (kDebugMode) {
          debugPrint(
              'ℹ️ _updateAllRelatedTransactions: Nenhuma transação precisa ser atualizada');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
            '📊 _updateAllRelatedTransactions: ${transactionsToUpdate.length} transações encontradas para atualizar');
      }

      // Atualizar em batches (máximo 500 por batch)
      final batches = <WriteBatch>[];
      WriteBatch? currentBatch;
      int batchCount = 0;

      for (final doc in transactionsToUpdate) {
        if (currentBatch == null || batchCount >= 500) {
          currentBatch = FirebaseFirestore.instance.batch();
          batches.add(currentBatch);
          batchCount = 0;
        }
        currentBatch.update(doc.reference, {'paymentType': newNameTrimmed});
        batchCount++;
      }

      // Executar todos os batches
      for (final batch in batches) {
        await batch.commit();
      }

      if (kDebugMode) {
        debugPrint(
            '✅ _updateAllRelatedTransactions: ${transactionsToUpdate.length} transações atualizadas com sucesso');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar todas as transações relacionadas: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  // Funções antigas removidas para melhor performance
  // Use _updateAllRelatedTransactions que faz tudo em uma única busca

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

  /// Sincroniza transações de um cartão específico
  /// Útil quando o cartão foi editado antes e as transações não foram atualizadas
  /// Retorna o número de transações atualizadas
  Future<int> syncCardTransactions(String cardId, String cardName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) {
        debugPrint('⚠️ syncCardTransactions: userId é null');
        return 0;
      }

      final cardNameTrimmed = cardName.trim();
      final cardNameNormalized = cardNameTrimmed.toLowerCase();

      debugPrint(
          '🔄 syncCardTransactions: Sincronizando transações para cartão "$cardName" (ID: $cardId)');

      // Buscar todas as transações do usuário
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint(
          '📊 syncCardTransactions: Total de transações do usuário: ${transactionsSnapshot.docs.length}');

      if (transactionsSnapshot.docs.isEmpty) {
        debugPrint('ℹ️ syncCardTransactions: Nenhuma transação encontrada');
        return 0;
      }

      // DEBUG: Listar todos os paymentTypes únicos para ajudar a identificar problemas
      final allPaymentTypes = <String>{};
      final paymentTypeCounts = <String, int>{};
      for (final doc in transactionsSnapshot.docs) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType != null && paymentType.trim().isNotEmpty) {
          final pt = paymentType.trim();
          allPaymentTypes.add(pt);
          paymentTypeCounts[pt] = (paymentTypeCounts[pt] ?? 0) + 1;
        }
      }
      debugPrint(
          '📋 syncCardTransactions: PaymentTypes únicos encontrados: ${allPaymentTypes.toList()}');
      debugPrint(
          '📊 syncCardTransactions: Contagem por paymentType: $paymentTypeCounts');
      debugPrint(
          '🔍 syncCardTransactions: Procurando por nome: "$cardNameTrimmed" (normalizado: "$cardNameNormalized")');

      // Encontrar transações que podem estar associadas a este cartão
      // mas com nome diferente (diferenças de case/espaços)
      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType == null) return false;
        final paymentTypeNormalized = paymentType.trim().toLowerCase();
        // Se o nome normalizado corresponde mas o nome exato não, precisa atualizar
        final needsUpdate = paymentTypeNormalized == cardNameNormalized &&
            paymentType.trim() != cardNameTrimmed;
        if (needsUpdate) {
          debugPrint(
              '  ✓ Transação ${doc.id}: "$paymentType" -> "$cardNameTrimmed"');
        }
        return needsUpdate;
      }).toList();

      debugPrint(
          '📊 syncCardTransactions: Transações para atualizar: ${transactionsToUpdate.length}');

      if (transactionsToUpdate.isEmpty) {
        debugPrint(
            'ℹ️ syncCardTransactions: Nenhuma transação precisa ser atualizada');
        debugPrint(
            '💡 Dica: Verifique se há transações com paymentType similar ao nome do cartão');
        return 0;
      }

      debugPrint(
          '🔄 syncCardTransactions: ${transactionsToUpdate.length} transações encontradas para sincronizar');

      // Atualizar em batches
      final batches = <WriteBatch>[];
      WriteBatch? currentBatch;
      int batchCount = 0;

      for (final doc in transactionsToUpdate) {
        if (currentBatch == null || batchCount >= 500) {
          currentBatch = FirebaseFirestore.instance.batch();
          batches.add(currentBatch);
          batchCount = 0;
        }
        currentBatch.update(doc.reference, {'paymentType': cardNameTrimmed});
        batchCount++;
      }

      for (final batch in batches) {
        await batch.commit();
      }

      debugPrint(
          '✅ syncCardTransactions: ${transactionsToUpdate.length} transações sincronizadas com sucesso');
      return transactionsToUpdate.length;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao sincronizar transações do cartão: $e');
      debugPrint('Stack trace: $stackTrace');
      return 0;
    }
  }

  /// Função manual para recuperar transações de um cartão
  /// Busca todas as transações que podem estar relacionadas ao cartão
  /// e permite atualizar para o nome atual
  Future<int> recoverCardTransactions(String cardId, String cardName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) {
        debugPrint('⚠️ recoverCardTransactions: userId é null');
        return 0;
      }

      final cardNameTrimmed = cardName.trim();
      debugPrint(
          '🔍 recoverCardTransactions: Recuperando transações para cartão "$cardName" (ID: $cardId)');

      // Buscar todas as transações do usuário
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint(
          '📊 recoverCardTransactions: Total de transações: ${transactionsSnapshot.docs.length}');

      // Listar todos os paymentTypes únicos
      final allPaymentTypes = <String>{};
      final paymentTypeCounts = <String, int>{};
      for (final doc in transactionsSnapshot.docs) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType != null && paymentType.trim().isNotEmpty) {
          final pt = paymentType.trim();
          allPaymentTypes.add(pt);
          paymentTypeCounts[pt] = (paymentTypeCounts[pt] ?? 0) + 1;
        }
      }

      debugPrint(
          '📋 recoverCardTransactions: Todos os paymentTypes encontrados:');
      paymentTypeCounts.forEach((pt, count) {
        debugPrint('  - "$pt": $count transação(ões)');
      });

      // Buscar transações que podem estar relacionadas (similaridade parcial)
      // Por exemplo, se o nome do cartão contém parte do paymentType ou vice-versa
      final cardNameWords = cardNameTrimmed.toLowerCase().split(' ');
      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType == null || paymentType.trim().isEmpty) return false;

        final pt = paymentType.trim().toLowerCase();
        final cardNameLower = cardNameTrimmed.toLowerCase();

        // Verificar se há similaridade
        // 1. Nome exato (case-insensitive)
        if (pt == cardNameLower) return true;

        // 2. Uma palavra do nome do cartão está no paymentType
        for (final word in cardNameWords) {
          if (word.length > 2 && pt.contains(word)) {
            debugPrint(
                '  ✓ Similaridade encontrada: "$paymentType" contém "$word"');
            return true;
          }
        }

        // 3. PaymentType contém parte do nome do cartão
        if (cardNameLower.length > 3 &&
            pt.contains(cardNameLower.substring(
                0, cardNameLower.length > 5 ? 5 : cardNameLower.length))) {
          debugPrint(
              '  ✓ Similaridade encontrada: "$paymentType" contém parte de "$cardNameTrimmed"');
          return true;
        }

        return false;
      }).toList();

      debugPrint(
          '📊 recoverCardTransactions: ${transactionsToUpdate.length} transações encontradas para atualizar');

      if (transactionsToUpdate.isEmpty) {
        debugPrint(
            'ℹ️ recoverCardTransactions: Nenhuma transação encontrada para recuperar');
        return 0;
      }

      // Atualizar em batches
      final batches = <WriteBatch>[];
      WriteBatch? currentBatch;
      int batchCount = 0;

      for (final doc in transactionsToUpdate) {
        if (currentBatch == null || batchCount >= 500) {
          currentBatch = FirebaseFirestore.instance.batch();
          batches.add(currentBatch);
          batchCount = 0;
        }
        final oldPaymentType = doc.data()['paymentType'] as String?;
        currentBatch.update(doc.reference, {'paymentType': cardNameTrimmed});
        debugPrint(
            '  ✓ Atualizando transação ${doc.id}: "$oldPaymentType" -> "$cardNameTrimmed"');
        batchCount++;
      }

      for (final batch in batches) {
        await batch.commit();
      }

      debugPrint(
          '✅ recoverCardTransactions: ${transactionsToUpdate.length} transações recuperadas com sucesso');
      return transactionsToUpdate.length;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao recuperar transações do cartão: $e');
      debugPrint('Stack trace: $stackTrace');
      return 0;
    }
  }

  // Funções antigas removidas - agora usamos _updateAllRelatedTransactions que é mais eficiente
}
