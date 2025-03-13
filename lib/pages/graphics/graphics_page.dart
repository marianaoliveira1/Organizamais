// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';

import 'widgtes/graphics_section.dart';
import 'widgtes/month_selector.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController = Get.put(TransactionController());
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final selectedCategoryId = RxnInt(null);
    final selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                MonthSelector(selectedMonth: selectedMonth, selectedCategoryId: selectedCategoryId, theme: theme),
                SizedBox(height: 20.h),
                GraphicsSection(
                  transactionController: transactionController,
                  selectedMonth: selectedMonth,
                  selectedCategoryId: selectedCategoryId,
                  currencyFormatter: currencyFormatter,
                  dateFormatter: dateFormatter,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<String> getAllMonths() {
  return [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];
}
