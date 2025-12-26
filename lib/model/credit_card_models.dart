import 'package:flutter/foundation.dart';

/// Representa uma compra parcelada (dívida) do ponto de vista do cartão.
@immutable
class InstallmentPurchase {
  /// Identificador estável da série (não depende do id da transação).
  final String seriesKey;

  /// Descrição normalizada da compra (ex: nome do estabelecimento).
  final String description;

  /// Valor de cada parcela.
  final double installmentValue;

  /// Número total de parcelas.
  final int totalInstallments;

  /// Data da primeira parcela (mês 1/total).
  final DateTime firstInstallmentDate;

  const InstallmentPurchase({
    required this.seriesKey,
    required this.description,
    required this.installmentValue,
    required this.totalInstallments,
    required this.firstInstallmentDate,
  });

  double get totalValue => installmentValue * totalInstallments;
}

/// Dados de uma fatura (mês) para exibição e projeção.
@immutable
class InvoiceMonth {
  /// Data do vencimento usada como chave (ano/mês).
  final DateTime paymentDate;

  /// Total da fatura (compras à vista + parcelas do mês).
  final double invoiceTotal;

  /// Somente parcelas que vencem neste mês.
  final double installmentPortion;

  /// Somente compras à vista lançadas neste mês.
  final double oneTimePortion;

  /// Total de parcelas futuras (dívida remanescente) APÓS pagar este mês.
  final double remainingInstallmentCommitmentAfterPay;

  const InvoiceMonth({
    required this.paymentDate,
    required this.invoiceTotal,
    required this.installmentPortion,
    required this.oneTimePortion,
    required this.remainingInstallmentCommitmentAfterPay,
  });
}

/// Métricas completas do cartão para o card de UI.
@immutable
class CreditCardMetrics {
  final double totalLimit;
  final double availableLimit;

  /// Total bloqueado/comprometido no limite agora (outstanding).
  final double blockedTotal;

  /// Total da fatura atual (mês corrente).
  final double currentInvoiceTotal;

  /// Valor comprometido com parcelas futuras (somente meses > atual).
  final double futureInstallmentsCommitted;

  /// Total estimado da próxima fatura (mês seguinte).
  final double nextInvoiceTotal;

  /// Lista mês a mês com a projeção das próximas faturas.
  final List<InvoiceMonth> upcomingInvoices;

  const CreditCardMetrics({
    required this.totalLimit,
    required this.availableLimit,
    required this.blockedTotal,
    required this.currentInvoiceTotal,
    required this.futureInstallmentsCommitted,
    required this.nextInvoiceTotal,
    required this.upcomingInvoices,
  });

  double get usageRatio =>
      totalLimit <= 0 ? 0.0 : (blockedTotal / totalLimit).clamp(0.0, 1.0);
  double get usagePercent => usageRatio * 100.0;
}

/// Representação normalizada de uma transação vinculada a um cartão de crédito.
/// Serve como “fonte da verdade” interna para cálculos (mesmo que o Firestore não tenha esses campos).
@immutable
class CreditCardTransaction {
  final String id;
  final String creditCardId;

  /// Valor total da compra (para à vista == amount; para parcelado == installmentAmount * installments).
  final double amount;

  final int installments;
  final double installmentAmount;
  final int currentInstallment;

  /// Data de compra / início do parcelamento (data da 1ª parcela).
  final DateTime purchaseDate;

  /// Data de vencimento desta parcela (ou desta compra à vista).
  final DateTime dueDate;

  const CreditCardTransaction({
    required this.id,
    required this.creditCardId,
    required this.amount,
    required this.installments,
    required this.installmentAmount,
    required this.currentInstallment,
    required this.purchaseDate,
    required this.dueDate,
  });

  bool get isInstallment => installments > 1;
}
