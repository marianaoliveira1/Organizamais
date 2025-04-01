import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/graphics/widgtes/default_text_graphic.dart';

import '../../../utils/color.dart';
import 'finance_legend.dart';

class FinancePieChart extends StatelessWidget {
  final num totalReceita;
  final num totalDespesas;

  const FinancePieChart({
    super.key,
    required this.totalReceita,
    required this.totalDespesas,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    num total = totalReceita + totalDespesas;
    double receitaPercent = total == 0 ? 0 : (totalReceita / total) * 100;
    double despesasPercent = total == 0 ? 0 : (totalDespesas / total) * 100;

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextGraphic(text: "Gráfico porcentagem de receita e despesas"),
          SizedBox(
            height: 16.h,
          ),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: totalReceita.toDouble(),
                    title: "",
                    color: DefaultColors.green,
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: totalDespesas.toDouble(),
                    title: "",
                    color: DefaultColors.red,
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FinanceLegend(
                title: "Receita",
                color: DefaultColors.green,
                percent: receitaPercent,
                value: totalReceita,
                formatter: formatter,
              ),
              SizedBox(width: 24),
              FinanceLegend(
                title: "Despesas",
                color: DefaultColors.red,
                percent: despesasPercent,
                value: totalDespesas,
                formatter: formatter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
