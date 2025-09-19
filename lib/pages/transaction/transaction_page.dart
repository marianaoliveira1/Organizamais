// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/transaction_controller.dart';
import 'widget/button_back.dart';
import 'widget/button_select_category.dart';
import 'widget/payment_type.dart';
import 'widget/textifield_description.dart';
import 'widget/title_transaction.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({
    super.key,
    this.transaction,
    this.overrideTransactionSalvar,
  });
  final TransactionModel? transaction;
  final Function(TransactionModel transaction)? overrideTransactionSalvar;

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TransactionType _selectedType = TransactionType.despesa;
  int? categoryId;
  DateTime? _selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valuecontroller = TextEditingController();
  final TextEditingController dayOfTheMonthController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();

  bool _isInstallment = false;
  int _installments = 1;

  final bool _isSaving = false;

  @override
  void dispose() {
    valuecontroller.dispose();
    titleController.dispose();
    dayOfTheMonthController.dispose();
    paymentTypeController.dispose();
    installmentsController.dispose();
    super.dispose();
  }

  void _setTransactionType(TransactionType type) {
    setState(() {
      _selectedType = type;
    });
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.receita:
        return Colors.green;
      case TransactionType.despesa:
        return Colors.red;
      case TransactionType.transferencia:
        return Colors.grey;
    }
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == DateTime(now.year, now.month, now.day)) {
      return 'Hoje';
    } else if (selectedDate == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      locale: const Locale("pt", "BR"),
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: ThemeData(
            primaryColor: theme.primaryColor,
            colorScheme: ColorScheme.light(
              primary: theme.primaryColor,
              onPrimary: theme.cardColor,
              surface: theme.scaffoldBackgroundColor,
              onSurface: theme.primaryColor,
            ),
            dialogBackgroundColor: theme.primaryColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      dayOfTheMonthController.text = _getFormattedDate(date);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      titleController.text = widget.transaction!.title;
      valuecontroller.text = widget.transaction!.value.startsWith('R\$ ')
          ? widget.transaction!.value
          : 'R\$ ${widget.transaction!.value}';
      _selectedType = widget.transaction!.type;
      categoryId = widget.transaction!.category;
      _selectedDate = DateTime.parse(widget.transaction!.paymentDay ?? '');
      dayOfTheMonthController.text = _getFormattedDate(_selectedDate!);
      paymentTypeController.text = widget.transaction!.paymentType ?? '';
    } else {
      // Data padrão: hoje
      _selectedDate = DateTime.now();
      dayOfTheMonthController.text = _getFormattedDate(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _getTypeColor(_selectedType);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.cardColor,
      body: SingleChildScrollView(
        child: Column(
          spacing: 4.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              color: _selectedType == TransactionType.receita
                  ? Colors.green
                  : Colors.red,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypeButton("Receita", TransactionType.receita),
                      _buildTypeButton("Despesa", TransactionType.despesa),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: valuecontroller,
                    decoration: InputDecoration(
                      hintText: "R\$0,00",
                      hintStyle: TextStyle(
                        color: DefaultColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 38.sp,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: DefaultColors.white,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            AdsBanner(),
            SizedBox(height: 8.h),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTitleTransaction(
                    title: "Descrição",
                  ),
                  TextFieldDescriptionTransaction(
                    titleController: titleController,
                  ),
                ],
              ),
            ),
            Divider(
              color: DefaultColors.grey20,
            ),
            // if (_selectedType != TransactionType.transferencia)
            Column(
              spacing: 4.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTitleTransaction(
                        title: "Categoria",
                      ),
                      DefaultButtonSelectCategory(
                        selectedCategory: categoryId,
                        transactionType: _selectedType,
                        onTap: (category) {
                          setState(() {
                            categoryId = category;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: DefaultColors.grey20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedType == TransactionType.receita)
                        DefaultTitleTransaction(
                          title: "Recebi em",
                        ),
                      if (_selectedType == TransactionType.despesa)
                        DefaultTitleTransaction(
                          title: "Pago com",
                        ),
                      PaymentTypeField(
                        controller: paymentTypeController,
                      ),
                    ],
                  ),
                ),
                if (_selectedType == TransactionType.despesa)
                  Divider(
                    color: DefaultColors.grey20,
                  ),
                if (_selectedType == TransactionType.despesa)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTitleTransaction(
                          title: "Forma de pagamento",
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  "À vista",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                value: false,
                                groupValue: _isInstallment,
                                onChanged: (value) {
                                  setState(() {
                                    _isInstallment = value!;
                                    _installments = 1;
                                    installmentsController.text = "1";
                                  });
                                },
                                activeColor: theme.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text(
                                  "A prazo",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                value: true,
                                groupValue: _isInstallment,
                                onChanged: (value) {
                                  setState(() {
                                    _isInstallment = value!;
                                    if (_installments < 2) {
                                      _installments = 2;
                                      installmentsController.text = "2";
                                    }
                                  });
                                },
                                activeColor: theme.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        if (_isInstallment)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Número de parcelas",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<int>(
                                  dropdownColor: theme.cardColor,
                                  focusColor: theme.primaryColor,
                                  value: _installments,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide:
                                          BorderSide(color: DefaultColors.grey),
                                    ),
                                    focusColor: DefaultColors.grey,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide:
                                          BorderSide(color: DefaultColors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                  ),
                                  items: List.generate(23, (index) => index + 2)
                                      .map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        value.toString(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _installments = newValue;
                                        installmentsController.text =
                                            newValue.toString();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                Divider(
                  color: DefaultColors.grey,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTitleTransaction(title: "Data"),
                  TextField(
                    controller: dayOfTheMonthController,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Data",
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: DefaultColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                      prefixIcon: SizedBox(
                        width: 40.w,
                        height: 40.h,
                        child: Center(
                          child: Icon(
                            Icons.calendar_month,
                            color: DefaultColors.grey20,
                            size: 22.w,
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    onTap: _selectDate,
                  ),
                ],
              ),
            ),
            Divider(
              color: DefaultColors.grey,
            ),

            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: ButtonBackTransaction()),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final TransactionController transactionController =
                            Get.find<TransactionController>();

                        if (titleController.text.isEmpty ||
                            valuecontroller.text.isEmpty ||
                            _selectedDate == null ||
                            (_selectedType != TransactionType.transferencia &&
                                categoryId == null) ||
                            (_selectedType != TransactionType.transferencia &&
                                paymentTypeController.text.isEmpty)) {
                          Get.snackbar(
                            'Erro',
                            'Preencha todos os campos obrigatórios',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final TransactionModel transaction = TransactionModel(
                          title: titleController.text,
                          value:
                              valuecontroller.text.replaceAll('R\$', '').trim(),
                          type: _selectedType,
                          category: categoryId,
                          paymentDay: _selectedDate!.toString().split(' ')[0],
                          paymentType: paymentTypeController.text,
                        );

                        try {
                          if (widget.overrideTransactionSalvar != null) {
                            await widget.overrideTransactionSalvar!(
                                transaction.copyWith(
                              id: widget.transaction!.id,
                            ));
                            Navigator.pop(context);
                            return;
                          }

                          await transactionController.addTransaction(
                              transaction,
                              isInstallment: _isInstallment,
                              installments: _installments);

                          // Navegar para ResumePage após salvar
                          Navigator.pop(
                              context, 3); // Retorna índice 3 (ResumePage)
                        } catch (e) {
                          Get.snackbar(
                            'Erro',
                            'Erro ao salvar a transação: ${e.toString()}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: _isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.cardColor),
                                strokeWidth: 2,
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  "Salvar",
                                  style: TextStyle(
                                    color: theme.cardColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type) {
    bool isSelected = _selectedType == type;
    Color typeColor = _getTypeColor(type);

    return GestureDetector(
      onTap: () => _setTransactionType(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: DefaultColors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 85.w,
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: isSelected ? typeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildShimmerSkeleton(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        spacing: 4.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for header section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            color: Colors.red,
            child: Column(
              children: [
                // Shimmer for type buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTypeButtonSkeleton(),
                    _buildTypeButtonSkeleton(),
                  ],
                ),
                SizedBox(height: 20.h),
                // Shimmer for value input
                Shimmer(
                  duration: const Duration(milliseconds: 1400),
                  color: Colors.white.withOpacity(0.3),
                  child: Container(
                    height: 40.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // Shimmer for form fields
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description field shimmer
                _buildFormFieldSkeleton("Descrição"),
                SizedBox(height: 16.h),
                Divider(color: DefaultColors.grey),
                SizedBox(height: 16.h),
                // Category field shimmer
                _buildFormFieldSkeleton("Categoria"),
                SizedBox(height: 16.h),
                Divider(color: DefaultColors.grey),
                SizedBox(height: 16.h),
                // Payment type field shimmer
                _buildFormFieldSkeleton("Pago com"),
                SizedBox(height: 16.h),
                Divider(color: DefaultColors.grey),
                SizedBox(height: 16.h),
                // Date field shimmer
                _buildFormFieldSkeleton("Data"),
                SizedBox(height: 24.h),
                // Buttons shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(milliseconds: 1400),
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButtonSkeleton() {
    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      color: Colors.white.withOpacity(0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 16.h,
            width: 80.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            width: 85.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldSkeleton(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label shimmer
        Shimmer(
          duration: const Duration(milliseconds: 1400),
          color: Colors.white.withOpacity(0.6),
          child: Container(
            height: 16.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Field shimmer
        Shimmer(
          duration: const Duration(milliseconds: 1400),
          color: Colors.white.withOpacity(0.6),
          child: Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formatter para converter a entrada em formato de moeda (R$)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove tudo que não for dígito
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return TextEditingValue(
        text: "R\$0,00",
        selection: TextSelection.collapsed(offset: "R\$0,00".length),
      );
    }

    // Interpreta o valor como centavos
    double value = double.parse(newText) / 100;
    String formattedText = currencyFormat.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
