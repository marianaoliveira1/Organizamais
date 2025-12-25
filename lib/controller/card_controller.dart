import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../model/cards_model.dart';
import '../services/analytics_service.dart';
import 'auth_controller.dart';

import '../model/transaction_model.dart';
import '../utils/performance_helpers.dart';

class CardSummary {
  final double availableLimit;
  final double blockedTotal;
  final double totalLimit;
  final double currentInvoiceTotal;
  final double nextInvoiceTotal;
  final double closedInvoiceTotal;

  CardSummary({
    required this.availableLimit,
    required this.blockedTotal,
    required this.totalLimit,
    required this.currentInvoiceTotal,
    required this.nextInvoiceTotal,
    required this.closedInvoiceTotal,
  });
}

class CardCycleDates {
  final DateTime closedStart;
  final DateTime closedEnd;
  final DateTime openStart;
  final DateTime openEnd;
  final DateTime paymentDate;

  CardCycleDates({
    required this.closedStart,
    required this.closedEnd,
    required this.openStart,
    required this.openEnd,
    required this.paymentDate,
  });
}

class CardController extends GetxController {
  var card = <CardsModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? cardStream;
  final AnalyticsService _analyticsService = AnalyticsService();

  void startCardStream() {
    cardStream?.cancel();

    cardStream = FirebaseFirestore.instance
        .collection('cards')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      final List<CardsModel> newCards = [];
      for (final doc in snapshot.docs) {
        try {
          final card = CardsModel.fromMap(doc.data()).copyWith(id: doc.id);
          newCards.add(card);
        } catch (_) {}
      }
      card.value = newCards;
    });
  }

  ({int? atual, int? total, String? description}) parseParcela(String title) {
    final regexFull = RegExp(r'Parcela\s+(\d+)(?:\s+de\s+(\d+))?[:\-]?\s*(.+)?',
        caseSensitive: false);
    final match = regexFull.firstMatch(title);
    if (match != null) {
      return (
        atual: int.tryParse(match.group(1) ?? ''),
        total: int.tryParse(match.group(2) ?? ''),
        description: (match.group(3) ?? '').trim()
      );
    }
    return (atual: null, total: null, description: null);
  }

  CardCycleDates computeCycleDates(
      DateTime ref, int closingDay, int paymentDay) {
    DateTime dateWithDay(int year, int month, int day) {
      final lastDay = DateTime(year, month + 1, 0).day;
      return DateTime(year, month, day > lastDay ? lastDay : day);
    }

    final DateTime closingThisMonth =
        dateWithDay(ref.year, ref.month, closingDay);

    DateTime openStart;
    DateTime openEnd;
    DateTime paymentDate;

    if (ref.isBefore(closingThisMonth)) {
      openEnd = closingThisMonth;
      openStart = dateWithDay(ref.year, ref.month - 1, closingDay)
          .add(const Duration(days: 1));

      if (paymentDay > closingDay) {
        paymentDate = dateWithDay(ref.year, ref.month, paymentDay);
      } else {
        paymentDate = dateWithDay(ref.year, ref.month + 1, paymentDay);
      }
    } else {
      openStart = closingThisMonth.add(const Duration(days: 1));
      openEnd = dateWithDay(ref.year, ref.month + 1, closingDay);

      if (paymentDay > closingDay) {
        paymentDate = dateWithDay(ref.year, ref.month + 1, paymentDay);
      } else {
        paymentDate = dateWithDay(ref.year, ref.month + 2, paymentDay);
      }
    }

    final DateTime closedEnd = openStart.subtract(const Duration(days: 1));
    final DateTime closedStart =
        dateWithDay(closedEnd.year, closedEnd.month - 1, closingDay)
            .add(const Duration(days: 1));

    return CardCycleDates(
      closedStart: closedStart,
      closedEnd: closedEnd,
      openStart: openStart,
      openEnd: openEnd,
      paymentDate: paymentDate,
    );
  }

  CardSummary getCardSummary({
    required Iterable<TransactionModel> allTransactions,
    required CardsModel card,
  }) {
    final now = DateTime.now();
    final closingDay = card.closingDay ?? 1;
    final paymentDay = card.paymentDay ?? 1;
    final totalLimit = card.limit ?? 0.0;
    final cardNameLower = card.name.trim().toLowerCase();

    // Ciclo Aberto Atual
    final cycle = computeCycleDates(now, closingDay, paymentDay);
    // Ciclo Fechado Anterior
    final cycleClosed = computeCycleDates(
        cycle.openStart.subtract(const Duration(days: 2)),
        closingDay,
        paymentDay);
    // Próximo Ciclo
    final cycleNext = computeCycleDates(
        cycle.openEnd.add(const Duration(days: 2)), closingDay, paymentDay);

    double currentInvoiceTotal = 0.0;
    double nextInvoiceTotal = 0.0;
    double closedInvoiceTotal = 0.0;
    double blockedTotal = 0.0;

    final Set<String> processedTransactionIds = {};
    final Map<
        String,
        ({
          double value,
          int total,
          int refAtual,
          DateTime refDate,
          String description
        })> seriesMap = {};

    for (final t in allTransactions) {
      if (t.paymentDay == null || t.type != TransactionType.despesa) continue;
      if ((t.paymentType ?? '').trim().toLowerCase() != cardNameLower) continue;

      final String tId = t.id ?? '${t.title}_${t.paymentDay}_${t.value}';
      if (processedTransactionIds.contains(tId)) continue;
      processedTransactionIds.add(tId);

      final DateTime? d = PerformanceHelpers.safeParseDate(t.paymentDay!);
      if (d == null) continue;

      final double val = PerformanceHelpers.parseCurrencyValue(t.value);
      final parcela = parseParcela(t.title);

      int? atual = parcela.atual;
      int? total = parcela.total;
      String description =
          (parcela.description ?? t.title).trim().toLowerCase();

      try {
        int? tFromModel = (t as dynamic).installments as int?;
        if (tFromModel != null && tFromModel > 1) {
          total = tFromModel;
        }
      } catch (_) {}

      final bool isParcelado = (total != null && total > 1) || (atual != null);

      if (isParcelado) {
        final int tTotal = total ?? 1;
        final int tAtual = atual ?? 1;

        final DateTime startDate =
            DateTime(d.year, d.month - (tAtual - 1), d.day);
        final String seriesKey =
            '${description}_${val.toStringAsFixed(2)}_${tTotal}_${startDate.year}_${startDate.month}';

        if (!seriesMap.containsKey(seriesKey) ||
            (seriesMap[seriesKey]!.refAtual < tAtual)) {
          seriesMap[seriesKey] = (
            value: val,
            total: tTotal,
            refAtual: tAtual,
            refDate: d,
            description: description
          );
        }
      } else {
        // COMPRA AVULSA
        if (!d.isBefore(cycleClosed.openStart) &&
            !d.isAfter(cycleClosed.openEnd)) {
          closedInvoiceTotal += val;
        }
        if (!d.isBefore(cycle.openStart) && !d.isAfter(cycle.openEnd)) {
          currentInvoiceTotal += val;
        }
        if (!d.isBefore(cycleNext.openStart) && !d.isAfter(cycleNext.openEnd)) {
          nextInvoiceTotal += val;
        }

        final cycA = computeCycleDates(d, closingDay, paymentDay);
        final String invKey = generateInvoiceKey(card.id, card.name, cycA);
        final bool isPaid = card.paidInvoices?.contains(invKey) ?? false;

        // REGRA #2: Compras à vista bloqueiam o limite APENAS se pertencem à fatura atual ou futura
        if (!isPaid &&
            (d.isAfter(cycle.openStart.subtract(const Duration(seconds: 1))))) {
          blockedTotal += val;
        }
      }
    }

    // REGRA #1: Processar bloqueio de parcelados e faturas
    seriesMap.forEach((key, data) {
      for (int i = 1; i <= data.total; i++) {
        final int monthDiff = i - data.refAtual;
        DateTime di = DateTime(data.refDate.year,
            data.refDate.month + monthDiff, data.refDate.day);

        if (di.day != data.refDate.day && data.refDate.day > 28) {
          di = DateTime(di.year, di.month + 1, 0);
        }

        final cycI = computeCycleDates(di, closingDay, paymentDay);
        final String invKey = generateInvoiceKey(card.id, card.name, cycI);
        final bool isPaid = card.paidInvoices?.contains(invKey) ?? false;

        // Acúmulo de faturas
        if (!di.isBefore(cycleClosed.openStart) &&
            !di.isAfter(cycleClosed.openEnd)) {
          closedInvoiceTotal += data.value;
        }
        if (!di.isBefore(cycle.openStart) && !di.isAfter(cycle.openEnd)) {
          currentInvoiceTotal += data.value;
        }
        if (!di.isBefore(cycleNext.openStart) &&
            !di.isAfter(cycleNext.openEnd)) {
          nextInvoiceTotal += data.value;
        }

        // REGRA ÚNICA: Bloqueia o valor integral de todas as parcelas não pagas
        if (!isPaid) {
          blockedTotal += data.value;
        }
      }
    });

    final double availableLimit =
        (totalLimit - blockedTotal).clamp(0.0, totalLimit);

    return CardSummary(
      availableLimit: availableLimit,
      blockedTotal: blockedTotal,
      totalLimit: totalLimit,
      currentInvoiceTotal: currentInvoiceTotal,
      nextInvoiceTotal: nextInvoiceTotal,
      closedInvoiceTotal: closedInvoiceTotal,
    );
  }

  String generateInvoiceKey(
      String? cardIdOrNull, String cardName, CardCycleDates cycle) {
    final String cardKey = cardIdOrNull ?? cardName;
    return '$cardKey-${cycle.paymentDate.year}-${cycle.paymentDate.month}';
  }

  Future<void> addCard(CardsModel card) async {
    var cardWithUserId = card.copyWith(
        userId: Get.find<AuthController>().firebaseUser.value?.uid);

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

    _analyticsService.logAddCard(card.name);
  }

  Future<void> updateCard(CardsModel card) async {
    if (card.id == null) return;

    final int idx = this.card.indexWhere((c) => c.id == card.id);
    CardsModel? prev;
    String? oldName;
    if (idx != -1) {
      prev = this.card[idx];
      oldName = prev.name;
    }

    final normalizedCard = card.copyWith(name: card.name.trim());

    if (idx != -1) {
      this.card[idx] = normalizedCard;
    }

    try {
      await FirebaseFirestore.instance.collection('cards').doc(card.id).update(
            normalizedCard.toMap(),
          );

      if (oldName != null) {
        final oldNameTrimmed = oldName.trim();
        final newNameTrimmed = normalizedCard.name.trim();

        if (oldNameTrimmed != newNameTrimmed) {
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

    _analyticsService.logUpdateCard(card.name);
  }

  Future<void> _updateAllRelatedTransactions(
      String cardId, String oldName, String newName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) return;

      final oldNameLower = oldName.trim().toLowerCase();
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      if (transactionsSnapshot.docs.isEmpty) return;

      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType == null) return false;
        return paymentType.trim().toLowerCase() == oldNameLower;
      }).toList();

      if (transactionsToUpdate.isEmpty) return;

      final batches = <WriteBatch>[];
      WriteBatch? currentBatch;
      int batchCount = 0;

      for (final doc in transactionsToUpdate) {
        if (currentBatch == null || batchCount >= 500) {
          currentBatch = FirebaseFirestore.instance.batch();
          batches.add(currentBatch);
          batchCount = 0;
        }
        currentBatch.update(doc.reference, {'paymentType': newName.trim()});
        batchCount++;
      }

      for (final batch in batches) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar transações: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    final cardToDelete = card.firstWhereOrNull((c) => c.id == id);
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

    if (cardToDelete != null) {
      _analyticsService.logDeleteCard(cardToDelete.name);
    }
  }

  Future<void> markInvoicePaid(
      {required String cardId, required String invoiceKey}) async {
    final doc = FirebaseFirestore.instance.collection('cards').doc(cardId);
    await doc.update({
      'paidInvoices': FieldValue.arrayUnion([invoiceKey])
    });
  }

  Future<int> syncCardTransactions(String cardId, String cardName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) return 0;

      final cardNameTrimmed = cardName.trim();
      final cardNameNormalized = cardNameTrimmed.toLowerCase();

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      if (transactionsSnapshot.docs.isEmpty) return 0;

      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType = doc.data()['paymentType'] as String?;
        if (paymentType == null) return false;
        final ptNormalized = paymentType.trim().toLowerCase();
        return ptNormalized == cardNameNormalized &&
            paymentType.trim() != cardNameTrimmed;
      }).toList();

      if (transactionsToUpdate.isEmpty) return 0;

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

      return transactionsToUpdate.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> recoverCardTransactions(String cardId, String cardName) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      if (userId == null) return 0;

      final cardNameTrimmed = cardName.trim();
      final cardNameLower = cardNameTrimmed.toLowerCase();

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      if (transactionsSnapshot.docs.isEmpty) return 0;

      final transactionsToUpdate = transactionsSnapshot.docs.where((doc) {
        final paymentType =
            (doc.data()['paymentType'] as String?)?.trim().toLowerCase();
        if (paymentType == null || paymentType.isEmpty) return false;
        return paymentType == cardNameLower ||
            cardNameLower.contains(paymentType);
      }).toList();

      if (transactionsToUpdate.isEmpty) return 0;

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

      return transactionsToUpdate.length;
    } catch (e) {
      return 0;
    }
  }
}
