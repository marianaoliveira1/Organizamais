// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/routes/route.dart';
import 'package:organizamais/routes/route.dart' as app_routes;
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../model/fixed_account_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/payment_type.dart';
import '../../transaction/widget/text_field_transaction.dart';
import '../../transaction/widget/title_transaction.dart';
import '../widget/text_filed_value_fixed_accotuns.dart';
import 'periodicity_selection_page.dart';

class AddFixedAccountsFormPage extends StatefulWidget {
  final FixedAccountModel? fixedAccount;
  final Function(FixedAccountModel fixedAccount)? onSave;
  final bool fromOnboarding;

  const AddFixedAccountsFormPage(
      {super.key, this.fixedAccount, this.onSave, this.fromOnboarding = false});

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
  final TextEditingController biweeklyDay1Controller = TextEditingController();
  final TextEditingController biweeklyDay2Controller = TextEditingController();
  String selectedFrequency = 'mensal';
  int? selectedWeeklyWeekday; // 1=Monday .. 7=Sunday
  bool isSaving = false;

  String _frequencyLabel(String value) {
    switch (value) {
      case 'mensal':
        return 'Periodicidade: Mensal';
      case 'quinzenal':
        return 'Periodicidade: Quinzenal';
      case 'semanal':
        return 'Periodicidade: Semanal';
      case 'bimestral':
        return 'Periodicidade: Bimestral';
      case 'trimestral':
        return 'Periodicidade: Trimestral';
      default:
        return 'Periodicidade';
    }
  }

  String _frequencySummary() {
    switch (selectedFrequency) {
      case 'mensal':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Mensal no dia ${dayOfTheMonthController.text}'
            : 'Mensal (defina o dia ao tocar)';
      case 'bimestral':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Bimestral no dia ${dayOfTheMonthController.text}'
            : 'Bimestral (defina o dia ao tocar)';
      case 'trimestral':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Trimestral no dia ${dayOfTheMonthController.text}'
            : 'Trimestral (defina o dia ao tocar)';
      case 'quinzenal':
        if (biweeklyDay1Controller.text.isNotEmpty &&
            biweeklyDay2Controller.text.isNotEmpty) {
          return 'Quinzenal nos dias ${biweeklyDay1Controller.text} e ${biweeklyDay2Controller.text}';
        }
        return 'Quinzenal (defina os dias ao tocar)';
      case 'semanal':
        if (selectedWeeklyWeekday != null) {
          const weekdays = [
            '',
            'Segunda-feira',
            'Terça-feira',
            'Quarta-feira',
            'Quinta-feira',
            'Sexta-feira',
            'Sábado',
            'Domingo'
          ];
          return 'Semanal toda ${weekdays[selectedWeeklyWeekday!]}';
        }
        return 'Semanal (defina o dia ao tocar)';
      default:
        return '';
    }
  }

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
      selectedFrequency = widget.fixedAccount!.frequency ?? 'mensal';
      if (widget.fixedAccount!.biweeklyDays != null &&
          widget.fixedAccount!.biweeklyDays!.isNotEmpty) {
        biweeklyDay1Controller.text =
            widget.fixedAccount!.biweeklyDays![0].toString();
        if (widget.fixedAccount!.biweeklyDays!.length > 1) {
          biweeklyDay2Controller.text =
              widget.fixedAccount!.biweeklyDays![1].toString();
        }
      }
      selectedWeeklyWeekday = widget.fixedAccount!.weeklyWeekday;
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
              Text(
                "para que os gráficos sejam exibidos de maneira mais equilibrada",
                style: TextStyle(
                  color: DefaultColors.grey20,
                  fontSize: 9.sp,
                ),
              ),
              DefaultTitleTransaction(
                title: "Periodicidade",
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PeriodicitySelectionPage(
                        initialFrequency: selectedFrequency,
                        initialMonthlyDay:
                            dayOfTheMonthController.text.isNotEmpty
                                ? dayOfTheMonthController.text
                                : null,
                        initialBiweeklyDays:
                            (biweeklyDay1Controller.text.isNotEmpty &&
                                    biweeklyDay2Controller.text.isNotEmpty)
                                ? [
                                    int.parse(biweeklyDay1Controller.text),
                                    int.parse(biweeklyDay2Controller.text)
                                  ]
                                : null,
                        initialWeeklyWeekday: selectedWeeklyWeekday,
                      ),
                    ),
                  );
                  if (result is Map) {
                    setState(() {
                      selectedFrequency =
                          result['frequency'] as String? ?? selectedFrequency;
                      if (selectedFrequency == 'mensal' ||
                          selectedFrequency == 'bimestral' ||
                          selectedFrequency == 'trimestral') {
                        dayOfTheMonthController.text =
                            (result['monthlyDay'] as String?) ?? '';
                        biweeklyDay1Controller.clear();
                        biweeklyDay2Controller.clear();
                        selectedWeeklyWeekday = null;
                      } else if (selectedFrequency == 'quinzenal') {
                        final days =
                            (result['biweeklyDays'] as List?)?.cast<int>();
                        if (days != null && days.length >= 2) {
                          biweeklyDay1Controller.text = days[0].toString();
                          biweeklyDay2Controller.text = days[1].toString();
                        }
                        dayOfTheMonthController.clear();
                        selectedWeeklyWeekday = null;
                      } else if (selectedFrequency == 'semanal') {
                        selectedWeeklyWeekday = result['weeklyWeekday'] as int?;
                        dayOfTheMonthController.clear();
                        biweeklyDay1Controller.clear();
                        biweeklyDay2Controller.clear();
                      }
                    });
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _frequencyLabel(selectedFrequency),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: theme.primaryColor),
                    ],
                  ),
                ),
              ),
              // Resumo da periodicidade selecionada
              if (selectedFrequency.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _frequencySummary(),
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
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
                      onPressed: isSaving
                          ? null
                          : () async {
                              setState(() {
                                isSaving = true;
                              });
                              // Verificação se todos os campos estão preenchidos
                              bool invalid = false;
                              if (titleController.text.isEmpty ||
                                  valueController.text.isEmpty ||
                                  paymentTypeController.text.isEmpty ||
                                  categoryId == null) {
                                invalid = true;
                              }
                              if (!invalid) {
                                if ((selectedFrequency == 'mensal' ||
                                        selectedFrequency == 'bimestral' ||
                                        selectedFrequency == 'trimestral') &&
                                    dayOfTheMonthController.text.isEmpty) {
                                  invalid = true;
                                } else if (selectedFrequency == 'quinzenal' &&
                                    (biweeklyDay1Controller.text.isEmpty ||
                                        biweeklyDay2Controller.text.isEmpty)) {
                                  invalid = true;
                                } else if (selectedFrequency == 'semanal' &&
                                    selectedWeeklyWeekday == null) {
                                  invalid = true;
                                }
                              }
                              if (invalid) {
                                // Mostrar mensagem de erro se algum campo estiver vazio
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Por favor, preencha todos os campos"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                setState(() {
                                  isSaving = false;
                                });
                                return;
                              }

                              // Se todos os campos estiverem preenchidos, continua com o salvamento
                              if (widget.onSave != null) {
                                widget.onSave!(FixedAccountModel(
                                  id: widget.fixedAccount?.id,
                                  title: titleController.text,
                                  value: valueController.text,
                                  category: categoryId ?? 0,
                                  paymentDay: (selectedFrequency == 'mensal' ||
                                          selectedFrequency == 'bimestral' ||
                                          selectedFrequency == 'trimestral')
                                      ? dayOfTheMonthController.text
                                      : (selectedFrequency == 'quinzenal'
                                          ? biweeklyDay1Controller.text
                                          : '1'),
                                  paymentType: paymentTypeController.text,
                                  startMonth: selectedMonth,
                                  startYear: selectedYear,
                                  frequency: selectedFrequency,
                                  biweeklyDays: selectedFrequency == 'quinzenal'
                                      ? [
                                          int.parse(
                                              biweeklyDay1Controller.text),
                                          int.parse(biweeklyDay2Controller.text)
                                        ]
                                      : null,
                                  weeklyWeekday: selectedFrequency == 'semanal'
                                      ? selectedWeeklyWeekday
                                      : null,
                                ));
                                if (widget.fromOnboarding) {
                                  Get.offAllNamed(
                                      app_routes.Routes.FIXED_SUCCESS);
                                } else {
                                  Get.offAllNamed(Routes.HOME);
                                }
                                setState(() {
                                  isSaving = false;
                                });
                                return;
                              }
                              await fixedAccountsController
                                  .addFixedAccount(FixedAccountModel(
                                title: titleController.text,
                                value: valueController.text,
                                category: categoryId ?? 0,
                                paymentDay: (selectedFrequency == 'mensal' ||
                                        selectedFrequency == 'bimestral' ||
                                        selectedFrequency == 'trimestral')
                                    ? dayOfTheMonthController.text
                                    : (selectedFrequency == 'quinzenal'
                                        ? biweeklyDay1Controller.text
                                        : '1'),
                                paymentType: paymentTypeController.text,
                                startMonth: selectedMonth,
                                startYear: selectedYear,
                                frequency: selectedFrequency,
                                biweeklyDays: selectedFrequency == 'quinzenal'
                                    ? [
                                        int.parse(biweeklyDay1Controller.text),
                                        int.parse(biweeklyDay2Controller.text)
                                      ]
                                    : null,
                                weeklyWeekday: selectedFrequency == 'semanal'
                                    ? selectedWeeklyWeekday
                                    : null,
                              ));
                              setState(() {
                                isSaving = false;
                              });
                              if (widget.fromOnboarding) {
                                Get.offAllNamed(
                                    app_routes.Routes.FIXED_SUCCESS);
                              } else {
                                Get.offAllNamed(Routes.HOME);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: EdgeInsets.all(15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isSaving
                          ? SizedBox(
                              width: 20.h,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.cardColor,
                                ),
                              ),
                            )
                          : Text(
                              widget.fromOnboarding
                                  ? "Criar conta fixa"
                                  : "Salvar",
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
// Removed unused formatter in this page (now lives in periodicity page)
