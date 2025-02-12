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

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      dayOfTheMonthController.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildDatePickerField() {
    return TextField(
      controller: dayOfTheMonthController,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: DefaultColors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "A data da sua conquista",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.grey,
          fontWeight: FontWeight.w500,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: DefaultColors.black),
        ),
      ),
      onTap: _selectDate,
    );
  }

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
            _buildDatePickerField(),
            SizedBox(
              height: 10.h,
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

class PaymentTypeField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o método de pagamento',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: DefaultColors.black,
              ),
            ),
            SizedBox(height: 20.h),
            _buildPaymentOption(
              context,
              'Cartão',
              Icons.credit_card,
              controller,
            ),
            _buildPaymentOption(
              context,
              'Dinheiro',
              Icons.attach_money,
              controller,
            ),
            _buildPaymentOption(
              context,
              'PIX',
              Icons.pix,
              controller,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    IconData icon,
    TextEditingController controller,
  ) {
    return ListTile(
      leading: Icon(icon, color: DefaultColors.black),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        controller.text = title;
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: DefaultColors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.grey,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: Icon(Icons.arrow_drop_down, color: DefaultColors.black),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: DefaultColors.black),
        ),
      ),
      onTap: () => _showPaymentOptions(context),
    );
  }
}
