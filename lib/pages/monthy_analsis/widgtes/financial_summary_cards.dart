import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';

import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../../controller/transaction_controller.dart';
import 'financial_card.dart';
import 'saldo_card.dart';

class FinancialSummaryCards extends StatelessWidget {
  const FinancialSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final totalReceita = controller.totalReceitaAno;
      final totalDespesas = controller.totalDespesasAno;
      final saldo = totalReceita - totalDespesas;

      return Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Anual ${DateTime.now().year} (até hoje)',
              style: TextStyle(
                fontSize: 12.sp,
                color: DefaultColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Cards de Receita e Despesa
            Row(
              children: [
                // Card de Receitas
                Expanded(
                  child: FinancialCard(
                    title: 'Receitas',
                    value: totalReceita,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),

                // Card de Despesas
                Expanded(
                  child: FinancialCard(
                    title: 'Despesas',
                    value: totalDespesas,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card de Saldo
            SaldoCard(saldo: saldo),
          ],
        ),
      );
    });
  }
}
