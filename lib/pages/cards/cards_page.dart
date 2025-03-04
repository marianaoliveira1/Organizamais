// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

import 'widgtes/transaction_section.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});

  final List<String> months = [
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

  final NumberFormat formatter = NumberFormat.currency(
    locale: "pt_BR",
    symbol: "R\$",
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController = Get.put(TransactionController());

    // Variável observável para o mês selecionado, iniciando no mês atual
    final selectedMonth = (DateTime.now().month - 1).obs;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meses ScrollView
              SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return Obx(() => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                side: BorderSide(
                                  color: selectedMonth.value == index ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
                                ),
                              ),
                            ),
                            onPressed: () => selectedMonth.value = index,
                            child: Text(
                              months[index],
                              style: TextStyle(
                                color: selectedMonth.value == index ? theme.primaryColor : DefaultColors.grey,
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
                          TransactionSection(
                            controller: transactionController,
                            type: TransactionType.receita,
                            title: 'Entradas',
                            color: Colors.green,
                            selectedMonth: selectedMonth.value,
                          ),
                          SizedBox(height: 20.h),
                          TransactionSection(
                            controller: transactionController,
                            type: TransactionType.despesa,
                            title: 'Saídas',
                            color: Colors.red,
                            selectedMonth: selectedMonth.value,
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
