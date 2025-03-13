import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

import '../../transaction/pages/category_page.dart';
import '../graphics_page.dart';
import 'category_list_graphic.dart';
import 'pie_char_widget.dart';

class GraphicsSection extends StatelessWidget {
  final TransactionController transactionController;
  final RxString selectedMonth;
  final RxnInt selectedCategoryId;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;
  final ThemeData theme;

  const GraphicsSection({
    super.key,
    required this.transactionController,
    required this.selectedMonth,
    required this.selectedCategoryId,
    required this.currencyFormatter,
    required this.dateFormatter,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var filteredTransactions = _getFilteredTransactions(transactionController, selectedMonth);
      var categories = filteredTransactions.map((e) => e.category).where((e) => e != null).toSet().toList().cast<int>();

      var data = _prepareChartData(filteredTransactions, categories);
      double totalValue = data.fold(0.0, (previousValue, element) => previousValue + (element['value'] as double));

      if (data.isEmpty) {
        return Center(
          child: Text(
            "Nenhuma despesa encontrada${selectedMonth.value.isNotEmpty ? ' para $selectedMonth' : ''}",
            style: TextStyle(
              color: DefaultColors.grey,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        children: [
          PieChartWidget(data: data, theme: theme),
          SizedBox(height: 24.h),
          CategoryList(
            data: data,
            totalValue: totalValue,
            selectedCategoryId: selectedCategoryId,
            currencyFormatter: currencyFormatter,
            dateFormatter: dateFormatter,
            theme: theme,
            transactionController: transactionController,
            selectedMonth: selectedMonth,
            getFilteredTransactions: _getFilteredTransactions,
          ),
        ],
      );
    });
  }

  List<TransactionModel> _getFilteredTransactions(TransactionController transactionController, RxString selectedMonth) {
    var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();

    if (selectedMonth.value.isNotEmpty) {
      return despesas.where((transaction) {
        if (transaction.paymentDay == null) return false;
        DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
        String monthName = getAllMonths()[transactionDate.month - 1];
        return monthName == selectedMonth.value;
      }).toList();
    }

    return despesas;
  }

  List<Map<String, dynamic>> _prepareChartData(List<TransactionModel> filteredTransactions, List<int> categories) {
    var data = categories
        .map(
          (e) => {
            "category": e,
            "value": filteredTransactions.where((element) => element.category == e).fold<double>(
              0.0,
              (previousValue, element) {
                return previousValue + double.parse(element.value.replaceAll('.', '').replaceAll(',', '.'));
              },
            ),
            "name": findCategoryById(e)?['name'],
            "color": findCategoryById(e)?['color'],
            "icon": findCategoryById(e)?['icon'],
          },
        )
        .toList();

    data.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    return data;
  }
}
