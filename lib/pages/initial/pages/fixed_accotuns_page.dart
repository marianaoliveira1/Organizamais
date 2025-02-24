// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';

import '../../../model/fixed_account_model.dart';

import '../../../model/transaction_model.dart';

import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/payment_type.dart';
import '../../transaction/widget/text_field_transaction.dart';
import '../../transaction/widget/title_transaction.dart';
import '../widget/text_filed_value_fixed_accotuns.dart';

class FixedAccotunsPage extends StatefulWidget {
  final FixedAccountModel? fixedAccount;

  const FixedAccotunsPage({super.key, this.fixedAccount});

  @override
  State<FixedAccotunsPage> createState() => _FixedAccotunsPageState();
}

class _FixedAccotunsPageState extends State<FixedAccotunsPage> {
  int? categoryId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dayOfTheMonthController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FixedAccountsController fixedAccountsController = Get.put(
      FixedAccountsController(),
    );

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.cardColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text(
          "Contas fixas",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleTransaction(
              title: "Titulo",
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DefaultTextFieldTransaction(
                hintText: 'ex: Aluguel',
                controller: titleController,
                keyboardType: TextInputType.text,
              ),
            ),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextFieldValueFixedAccotuns(
                valueController: valueController,
                theme: theme,
              ),
            ),
            DefaultTitleTransaction(
              title: "Categoria",
            ),
            DefaultButtonSelectCategory(
              selectedCategory: categoryId,
              transactionType: TransactionType.despesa,
              onTap: (category) {
                setState(() {
                  categoryId = category;
                });
              },
            ),
            DefaultTitleTransaction(
              title: "Dia do pagamento ",
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DefaultTextFieldTransaction(
                hintText: 'ex: 5',
                controller: dayOfTheMonthController,
                keyboardType: TextInputType.number,
              ),
            ),
            DefaultTitleTransaction(
              title: "Tipo de pagamento",
            ),
            PaymentTypeField(
              controller: paymentTypeController,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (categoryId != null) {
                        fixedAccountsController.addFixedAccount(FixedAccountModel(
                          title: titleController.text,
                          value: valueController.text,
                          category: categoryId ?? 0,
                          paymentDay: dayOfTheMonthController.text,
                          paymentType: paymentTypeController.text,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: EdgeInsets.all(15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        color: theme.cardColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
