// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';

class PeriodicitySelectionPage extends StatefulWidget {
  final String initialFrequency;
  final String? initialMonthlyDay;
  final List<int>? initialBiweeklyDays;
  final int? initialWeeklyWeekday; // 1..7

  const PeriodicitySelectionPage({
    super.key,
    required this.initialFrequency,
    this.initialMonthlyDay,
    this.initialBiweeklyDays,
    this.initialWeeklyWeekday,
  });

  @override
  State<PeriodicitySelectionPage> createState() =>
      _PeriodicitySelectionPageState();
}

class _PeriodicitySelectionPageState extends State<PeriodicitySelectionPage> {
  late String selectedFrequency;
  final TextEditingController monthlyDayController = TextEditingController();
  final TextEditingController biweeklyDay1Controller = TextEditingController();
  final TextEditingController biweeklyDay2Controller = TextEditingController();
  int? selectedWeeklyWeekday; // 1..7
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.initialFrequency;
    if (widget.initialMonthlyDay != null) {
      monthlyDayController.text = widget.initialMonthlyDay!;
    }
    if (widget.initialBiweeklyDays != null &&
        widget.initialBiweeklyDays!.isNotEmpty) {
      biweeklyDay1Controller.text = widget.initialBiweeklyDays![0].toString();
      if (widget.initialBiweeklyDays!.length > 1) {
        biweeklyDay2Controller.text = widget.initialBiweeklyDays![1].toString();
      }
    }
    selectedWeeklyWeekday = widget.initialWeeklyWeekday;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.cardColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text(
          'Periodicidade',
          style: TextStyle(color: theme.primaryColor, fontSize: 16.sp),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.h,
            children: [
              AdsBanner(),
              Text(
                'Tipo de periodicidade',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.primaryColor.withOpacity(.5)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: DropdownButton<String>(
                  value: selectedFrequency,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                  dropdownColor: theme.scaffoldBackgroundColor,
                  items: const [
                    DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                    DropdownMenuItem(
                        value: 'quinzenal', child: Text('Quinzenal')),
                    DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                    DropdownMenuItem(
                        value: 'bimestral', child: Text('Bimestral')),
                    DropdownMenuItem(
                        value: 'trimestral', child: Text('Trimestral')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedFrequency = value;
                    });
                  },
                ),
              ),
              if (selectedFrequency == 'mensal' ||
                  selectedFrequency == 'bimestral' ||
                  selectedFrequency == 'trimestral') ...[
                Text(
                  'Dia do pagamento',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: monthlyDayController,
                    cursorColor: theme.primaryColor,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _MaxNumberInputFormatter(31),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(.5),
                        ),
                      ),
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
                  'Máximo permitido: 31',
                  style: TextStyle(color: DefaultColors.grey20, fontSize: 9.sp),
                ),
              ] else if (selectedFrequency == 'quinzenal') ...[
                Text(
                  'Dias do pagamento (quinzenal)',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextField(
                          controller: biweeklyDay1Controller,
                          cursorColor: theme.primaryColor,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _MaxNumberInputFormatter(31),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.primaryColor.withOpacity(.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.primaryColor.withOpacity(.5),
                              ),
                            ),
                            hintText: 'ex: 5',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextField(
                          controller: biweeklyDay2Controller,
                          cursorColor: theme.primaryColor,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _MaxNumberInputFormatter(31),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.primaryColor.withOpacity(.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.primaryColor.withOpacity(.5),
                              ),
                            ),
                            hintText: 'ex: 20',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (selectedFrequency == 'semanal') ...[
                Text(
                  'Dia da semana',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(.5)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: DropdownButton<int>(
                    value: selectedWeeklyWeekday,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                    dropdownColor: theme.scaffoldBackgroundColor,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Segunda-feira')),
                      DropdownMenuItem(value: 2, child: Text('Terça-feira')),
                      DropdownMenuItem(value: 3, child: Text('Quarta-feira')),
                      DropdownMenuItem(value: 4, child: Text('Quinta-feira')),
                      DropdownMenuItem(value: 5, child: Text('Sexta-feira')),
                      DropdownMenuItem(value: 6, child: Text('Sábado')),
                      DropdownMenuItem(value: 7, child: Text('Domingo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWeeklyWeekday = value;
                      });
                    },
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          setState(() {
                            isSaving = true;
                          });
                          bool invalid = false;
                          if (selectedFrequency == 'mensal' ||
                              selectedFrequency == 'bimestral' ||
                              selectedFrequency == 'trimestral') {
                            if (monthlyDayController.text.isEmpty) {
                              invalid = true;
                            }
                          } else if (selectedFrequency == 'quinzenal') {
                            if (biweeklyDay1Controller.text.isEmpty ||
                                biweeklyDay2Controller.text.isEmpty) {
                              invalid = true;
                            }
                          } else if (selectedFrequency == 'semanal') {
                            if (selectedWeeklyWeekday == null) invalid = true;
                          }
                          if (invalid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Preencha os campos obrigatórios'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setState(() {
                              isSaving = false;
                            });
                            return;
                          }
                          Navigator.of(context).pop({
                            'frequency': selectedFrequency,
                            'monthlyDay': monthlyDayController.text,
                            'biweeklyDays': (selectedFrequency == 'quinzenal')
                                ? [
                                    int.parse(biweeklyDay1Controller.text),
                                    int.parse(biweeklyDay2Controller.text)
                                  ]
                                : null,
                            'weeklyWeekday': selectedFrequency == 'semanal'
                                ? selectedWeeklyWeekday
                                : null,
                          });
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.cardColor),
                          ),
                        )
                      : Text(
                          'Salvar',
                          style: TextStyle(
                              color: theme.cardColor, fontSize: 14.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaxNumberInputFormatter extends TextInputFormatter {
  final int max;
  _MaxNumberInputFormatter(this.max);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final int? value = int.tryParse(newValue.text);
    if (value == null || value > max) {
      return oldValue;
    }
    return newValue;
  }
}
