// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/routes/route.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../model/fixed_account_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/payment_type.dart';
import '../../transaction/widget/text_field_transaction.dart';
import '../../transaction/widget/title_transaction.dart';
import '../widget/text_filed_value_fixed_accotuns.dart';

class AddFixedAccountsFormPage extends StatefulWidget {
  final FixedAccountModel? fixedAccount;
  final Function(FixedAccountModel fixedAccount)? onSave;

  const AddFixedAccountsFormPage({super.key, this.fixedAccount, this.onSave});

  @override
  State<AddFixedAccountsFormPage> createState() =>
      _AddFixedAccountsFormPageState();
}

class _AddFixedAccountsFormPageState extends State<AddFixedAccountsFormPage> {
  int? categoryId;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dayOfTheMonthController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.fixedAccount != null) {
      titleController.text = widget.fixedAccount!.title;
      valueController.text = widget.fixedAccount!.value;
      dayOfTheMonthController.text = widget.fixedAccount!.paymentDay;
      paymentTypeController.text = widget.fixedAccount!.paymentType ?? '';
      categoryId = widget.fixedAccount!.category;
      selectedMonth = widget.fixedAccount!.startMonth ?? DateTime.now().month;
      selectedYear = widget.fixedAccount!.startYear ?? DateTime.now().year;
    }
  }

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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.w,
            horizontal: 20.h,
          ),
          child: Column(
            spacing: 10.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
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
                title: "Mês e ano de início",
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          underline: SizedBox(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: List.generate(12, (index) {
                            int month = index + 1;
                            List<String> monthNames = [
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
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(monthNames[index]),
                            );
                          }),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50.h,
                      color: theme.primaryColor.withOpacity(.3),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          underline: SizedBox(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: List.generate(40, (index) {
                            int year = DateTime.now().year - 10 + index;
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedYear = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
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
                child: TextField(
                  controller: dayOfTheMonthController,
                  cursorColor: theme.primaryColor,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Aceita apenas números
                    _MaxNumberInputFormatter(28), // Restringe a 31
                  ],
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
                    focusColor: theme.primaryColor,
                    hintText: 'ex: 5',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor.withOpacity(.5),
                    ),
                  ),
                ),
              ),
              Text(
                "Máximo permitido: até 28, pois alguns meses têm no máximo 28 dias. Se for um número maior, a cobrança ocorrerá no dia 28.",
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 9.sp,
                ),
              ),
              DefaultTitleTransaction(
                title: "Tipo de pagamento",
              ),
              PaymentTypeField(
                controller: paymentTypeController,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Verificação se todos os campos estão preenchidos
                        if (titleController.text.isEmpty ||
                            valueController.text.isEmpty ||
                            dayOfTheMonthController.text.isEmpty ||
                            paymentTypeController.text.isEmpty ||
                            categoryId == null) {
                          // Mostrar mensagem de erro se algum campo estiver vazio
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Por favor, preencha todos os campos"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Se todos os campos estiverem preenchidos, continua com o salvamento
                        if (widget.onSave != null) {
                          widget.onSave!(FixedAccountModel(
                            id: widget.fixedAccount?.id,
                            title: titleController.text,
                            value: valueController.text,
                            category: categoryId ?? 0,
                            paymentDay: dayOfTheMonthController.text,
                            paymentType: paymentTypeController.text,
                            startMonth: selectedMonth,
                            startYear: selectedYear,
                          ));
                          Get.offAllNamed(Routes.HOME);
                          return;
                        }
                        fixedAccountsController
                            .addFixedAccount(FixedAccountModel(
                          title: titleController.text,
                          value: valueController.text,
                          category: categoryId ?? 0,
                          paymentDay: dayOfTheMonthController.text,
                          paymentType: paymentTypeController.text,
                          startMonth: selectedMonth,
                          startYear: selectedYear,
                        ));
                        Get.offAllNamed(Routes.HOME);
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
      ),
    );
  }
}

// Formatter para limitar o número máximo
class _MaxNumberInputFormatter extends TextInputFormatter {
  final int max;

  _MaxNumberInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value > max) {
      return oldValue; // Retorna o valor anterior se for inválido
    }
    return newValue;
  }
}
