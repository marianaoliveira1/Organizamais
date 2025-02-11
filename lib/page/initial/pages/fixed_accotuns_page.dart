import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/utils/color.dart';

import '../../../model/fixed_account_model.dart';
import '../../transaction_page.dart/transaction_page.dart';
import '../../transaction_page.dart/widget/text_field_transaction.dart';
import '../../transaction_page.dart/widget/title_transaction.dart';

class FixedAccotunsPage extends StatefulWidget {
  const FixedAccotunsPage({super.key});

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
    final FixedAccountsController fixedAccountsController = Get.put(FixedAccountsController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
        title: const Text("Contas fixas"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleTransaction(
              title: "Titulo",
            ),
            DefaultTextFieldTransaction(
              hintText: 'ex: Aluguel',
              controller: titleController,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            DefaultTextFieldTransaction(
              hintText: '0,00',
              controller: valueController,
              icon: Icon(
                Icons.attach_money,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Categoria",
            ),
            DefaultButtonSelectCategory(
              onTap: (category) {
                setState(() {
                  categoryId = category;
                });
              },
              selectedCategory: categoryId,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Dia do pagamento ",
            ),
            DefaultTextFieldTransaction(
              hintText: 'ex: 5',
              controller: dayOfTheMonthController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Tipo de pagamento",
            ),
            DefaultTextFieldTransaction(
              hintText: 'ex: Pix',
              controller: paymentTypeController,
              keyboardType: TextInputType.text,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (categoryId != null) {
                        fixedAccountsController.addFixedAccount(FixedAccount(
                          title: titleController.text,
                          value: valueController.text,
                          category: categoryId ?? 0,
                          paymentDay: dayOfTheMonthController.text,
                          paymentType: paymentTypeController.text,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DefaultColors.black,
                      padding: EdgeInsets.all(15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        color: DefaultColors.white,
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
