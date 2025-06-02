import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';

import '../../model/transaction_model.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  final TransactionController controller = Get.find<TransactionController>();

  MonthlyAnalysisPage({super.key});

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final t in transactions) {
      if (t.paymentDay != null) {
        final date = DateTime.parse(t.paymentDay!);
        final key = DateFormat('yyyy-MM').format(date);
        grouped.putIfAbsent(key, () => []).add(t);
      }
    }

    return grouped;
  }

  Map<int, String> categoryNames = {
    1: 'Alimentação',
    2: 'Transporte',
    3: 'Educação',
    4: 'Lazer',
    5: 'Casa',
    6: 'Saúde',
    // adicione mais conforme seu app
  };

  @override
  Widget build(BuildContext context) {
    final transactions = controller.transaction;
    final grouped = _groupTransactionsByMonth(transactions);

    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise Mensal'),
      ),
      body: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (_, index) {
          final key = sortedKeys[index];
          final monthTransactions = grouped[key]!;
          final receitas =
              monthTransactions.where((t) => t.type == TransactionType.receita);
          final despesas =
              monthTransactions.where((t) => t.type == TransactionType.despesa);

          double totalReceita = receitas.fold(
              0,
              (sum, t) =>
                  sum +
                  double.parse(
                      t.value.replaceAll('.', '').replaceAll(',', '.')));
          double totalDespesa = despesas.fold(
              0,
              (sum, t) =>
                  sum +
                  double.parse(
                      t.value.replaceAll('.', '').replaceAll(',', '.')));

          final categoriaDespesas = <int, double>{};

          for (final t in despesas) {
            if (t.category != null) {
              categoriaDespesas[t.category!] =
                  (categoriaDespesas[t.category!] ?? 0) +
                      double.parse(
                          t.value.replaceAll('.', '').replaceAll(',', '.'));
            }
          }

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMM('pt_BR').format(DateTime.parse('$key-01')),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Receita: R\$ ${totalReceita.toStringAsFixed(2).replaceAll('.', ',')}'),
                  Text(
                      'Despesa: R\$ ${totalDespesa.toStringAsFixed(2).replaceAll('.', ',')}'),
                  const Divider(),
                  ...categoriaDespesas.entries.map((entry) {
                    final catId = entry.key;
                    final valor = entry.value;
                    final catName = categoryNames[catId] ?? 'Categoria $catId';

                    double? valorAnterior;
                    if (index > 0) {
                      final mesAnteriorKey = sortedKeys[index - 1];
                      final mesAnterior = grouped[mesAnteriorKey]!;
                      final despesasAnterior = mesAnterior.where((t) =>
                          t.type == TransactionType.despesa &&
                          t.category == catId);

                      valorAnterior = despesasAnterior.fold(
                          0.0,
                          (sum, t) =>
                              sum! +
                              double.parse(t.value
                                  .replaceAll('.', '')
                                  .replaceAll(',', '.')));
                    }

                    String? dica;
                    if (valorAnterior != null && valor > valorAnterior) {
                      dica = 'Você gastou mais com $catName este mês. '
                          'Considere estratégias para economizar, como planejar compras ou evitar gastos impulsivos.';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '$catName: R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}'),
                          if (dica != null)
                            Text(
                              dica,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
