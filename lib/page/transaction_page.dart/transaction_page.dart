import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../../utils/color.dart';
import 'widget/button_select_category.dart';
import 'widget/text_field_transaction.dart';
import 'widget/title_transaction.dart';

class TransactionPage extends StatefulWidget {
  final TransactionType? transactionType;

  const TransactionPage({
    this.transactionType,
    super.key,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int? categoryId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dayOfTheMonthController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    return Scaffold(
      appBar: AppBar(),
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
                        transactionController.addTransaction(TransactionModel(
                          title: titleController.text,
                          value: valueController.text,
                          category: categoryId ?? 0,
                          paymentDay: dayOfTheMonthController.text,
                          paymentType: paymentTypeController.text,
                          type: widget.transactionType!,
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
