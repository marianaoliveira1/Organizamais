import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

import '../pages/finance_details_page.dart';
import 'category_value.dart';

class FinanceSummaryWidget extends StatelessWidget {
  const FinanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    final theme = Theme.of(context);

    // Verifica se hoje é o primeiro dia do mês
    final bool isFirstDay = DateTime.now().day == 1;

    // Pega o mês e o ano atuais
    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    return Obx(() {
      // Se for o primeiro dia, os valores serão zerados.
      num totalReceita = isFirstDay
          ? 0
          : transactionController.transaction.where((t) {
              // Verifica se paymentDay não é nulo e se a data corresponde ao mês e ano atuais
              if (t.paymentDay != null) {
                DateTime paymentDate = DateTime.parse(t.paymentDay!); // Converte a string para DateTime
                return t.type == TransactionType.receita && paymentDate.month == currentMonth && paymentDate.year == currentYear;
              }
              return false; // Caso paymentDay seja nulo
            }).fold(
              0,
              (sum, t) =>
                  sum +
                  double.parse(
                    t.value.replaceAll('.', '').replaceAll(',', '.'),
                  ),
            );

      num totalDespesas = isFirstDay
          ? 0
          : transactionController.transaction.where((t) {
              // Verifica se paymentDay não é nulo e se a data corresponde ao mês e ano atuais
              if (t.paymentDay != null) {
                DateTime paymentDate = DateTime.parse(t.paymentDay!); // Converte a string para DateTime
                return t.type == TransactionType.despesa && paymentDate.month == currentMonth && paymentDate.year == currentYear;
              }
              return false; // Caso paymentDay seja nulo
            }).fold(
              0,
              (sum, t) =>
                  sum +
                  double.parse(
                    t.value.replaceAll('.', '').replaceAll(',', '.'),
                  ),
            );

      num total = totalReceita - totalDespesas;

      return GestureDetector(
        onTap: () {
          // Navega para a página de detalhes financeiros quando o widget for clicado
          Get.to(() => const FinanceDetailsPage());
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.h,
            horizontal: 16.w,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DefaultColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Adiciona um ícone para indicar que é clicável
                  // Icon(
                  //   Icons.arrow_forward_ios,
                  //   size: 14.sp,
                  //   color: DefaultColors.grey,
                  // ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                formatter.format(total),
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  CategoryValue(
                    title: "Receita",
                    value: formatter.format(totalReceita),
                    color: DefaultColors.green,
                  ),
                  SizedBox(width: 24.w),
                  CategoryValue(
                    title: "Despesas",
                    value: formatter.format(totalDespesas),
                    color: DefaultColors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
