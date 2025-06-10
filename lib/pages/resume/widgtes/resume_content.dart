import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/pages/resume/widgtes/month_selector_resume.dart';

import '../../../ads_banner/ads_banner.dart';
import 'transaction_list_resume.dart';

class ResumeContent extends StatelessWidget {
  ResumeContent({super.key});
  final TransactionController _transactionController =
      Get.put(TransactionController());
  final RxString _selectedMonth = getAllMonths()[DateTime.now().month - 1].obs;
  final NumberFormat _formatter =
      NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  static List<String> getAllMonths() => [
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdsBanner(),
        SizedBox(
          height: 20.h,
        ),
        MonthSelectorResume(
          selectedMonth: _selectedMonth,
          initialMonth:
              DateTime.now().month - 1, // Posição do mês atual (abril = 3)
          centerCurrentMonth: true, // Adicione esta propriedade
        ),
        SizedBox(height: 20.h),
        TransactionsList(
          transactionController: _transactionController,
          selectedMonth: _selectedMonth,
          formatter: _formatter,
        ),
      ],
    );
  }
}
