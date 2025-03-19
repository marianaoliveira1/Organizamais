// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../transaction/transaction_page.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/title_transaction.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final GoalController goalController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int? categoryId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Adicionar Meta',
          style: TextStyle(color: theme.primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleTransaction(
              title: "Titulo",
            ),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                hintText: 'ex: Comprar um carro',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(.5),
                ),
              ),
            ),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            TextField(
              controller: valueController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                fillColor: theme.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                ),
                prefixIconColor: DefaultColors.grey,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                focusColor: theme.primaryColor,
                hintText: "0,00",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(0.5),
                ),
              ),
            ),
            DefaultTitleTransaction(
              title: "Data",
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(
                  16.r,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                child: Text(
                  "Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            DefaultTitleTransaction(
              title: "Categoria",
            ),
            DefaultButtonSelectCategory(
              selectedCategory: categoryId,
              onTap: (category) {
                setState(() {
                  categoryId = category;
                });
              },
              transactionType: TransactionType.despesa,
            ),
            Spacer(),
            InkWell(
              onTap: () {
                final double value = double.tryParse(valueController.text.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll(',', '.')) ?? 0.0;
                final goal = GoalModel(
                  name: nameController.text,
                  value: NumberFormat.currency(locale: 'pt_BR').format(value), // Formata para Real Brasileiro
                  date: DateFormat('dd/MM/yyyy').format(selectedDate),
                  categoryId: categoryId ?? 0,
                  currentValue: 0,
                );
                goalController.addGoal(goal);
                Get.back();
              },
              child: Container(
                padding: EdgeInsets.all(
                  16.r,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                child: Text(
                  "Salvar",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
