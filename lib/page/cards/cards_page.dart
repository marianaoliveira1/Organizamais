import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});

  final List<String> months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    // Adiciona uma variável observável para o mês selecionado
    final selectedMonth = 0.obs; // Janeiro como padrão (0-based index)

    return Scaffold(
      backgroundColor: DefaultColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meses ScrollView
            Container(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  return Obx(() => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedMonth.value == index ? DefaultColors.green : DefaultColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () => selectedMonth.value = index,
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color: selectedMonth.value == index ? DefaultColors.white : DefaultColors.black,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTransactionSection(
                          transactionController,
                          TransactionType.receita,
                          'Entradas',
                          Colors.green,
                          selectedMonth.value,
                        ),
                        SizedBox(height: 20.h),
                        _buildTransactionSection(
                          transactionController,
                          TransactionType.despesa,
                          'Saídas',
                          Colors.red,
                          selectedMonth.value,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    TransactionController controller,
    TransactionType type,
    String title,
    Color color,
    int selectedMonth,
  ) {
    return Obx(() {
      // Filtra as transações por tipo e mês
      var transactions = controller.transaction.where((t) {
        bool matchesType = t.type == type;
        DateTime transactionDate = DateTime.parse(t.paymentDay ?? '');
        bool matchesMonth = transactionDate.month == (selectedMonth + 1);
        return matchesType && matchesMonth;
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: DefaultColors.grey,
            ),
          ),
          SizedBox(height: 10.h),
          transactions.isEmpty
              ? Text(
                  'Nenhuma transação registrada neste mês.',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: transactions
                      .map((t) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _buildTransactionCard(t, color),
                          ))
                      .toList(),
                ),
        ],
      );
    });
  }

  final NumberFormat formatter = NumberFormat.currency(
    locale: "pt_BR",
    symbol: "R\$",
  );

  Widget _buildTransactionCard(TransactionModel transaction, Color color) {
    double valueDouble = double.tryParse(transaction.value) ?? 0.0;
    String formattedValue = formatter.format(valueDouble);

    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 16.h,
        horizontal: 12.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            transaction.title,
            style: TextStyle(
              color: DefaultColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formattedValue,
            style: TextStyle(
              color: DefaultColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
