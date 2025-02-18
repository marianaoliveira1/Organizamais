// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/model/transaction_model.dart';

import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';
import 'widget/button_select_category.dart';
import 'widget/payment_type.dart';
import 'widget/title_transaction.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

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

  @override
  void dispose() {
    valuecontroller.dispose();
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

  Widget _buildTransactionFields() {
    switch (_selectedType) {
      case TransactionType.transferencia:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recebi de"),
            TextField(
              decoration: const InputDecoration(
                hintText: "Digite quem enviou",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Para"),
            TextField(
              decoration: const InputDecoration(
                hintText: "Digite o destinatário",
                border: UnderlineInputBorder(),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      dayOfTheMonthController.text = _getFormattedDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color currentTypeColor = _getTypeColor(_selectedType);
    Get.put(TransactionController());

    return Scaffold(
      backgroundColor: DefaultColors.white,
      appBar: AppBar(
        backgroundColor: DefaultColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeButton("Receita", TransactionType.receita),
                _buildTypeButton("Despesa", TransactionType.despesa),
                _buildTypeButton("Transferencia", TransactionType.transferencia),
              ],
            ),
            _buildTransactionFields(),
            SizedBox(height: 20.h),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            TextField(
              controller: valuecontroller,
              decoration: InputDecoration(
                hintText: "R\$0,00",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 30.sp,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: currentTypeColor,
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultTitleTransaction(
              title: "Descrição",
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Adicione a descrição',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  color: Colors.grey,
                  size: 24.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
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
            ),
            SizedBox(
              height: 10.h,
            ),
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
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Data",
            ),
            TextField(
              controller: dayOfTheMonthController,
              readOnly: true,
              style: TextStyle(
                fontSize: 16.sp,
                color: DefaultColors.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Data",
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: DefaultColors.grey,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.calendar_month,
                  color: DefaultColors.black,
                ),
                border: InputBorder.none,
              ),
              onTap: _selectDate,
            ),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              child: Container(
                width: 1.sw,
                height: 50.h,
                decoration: BoxDecoration(
                  color: DefaultColors.black,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      color: DefaultColors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
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
          mainAxisSize: MainAxisSize.min, // Minimiza o tamanho vertical
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? typeColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
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
}
