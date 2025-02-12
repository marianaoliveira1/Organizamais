import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../../utils/color.dart';
import 'widget/button_select_category.dart';

class TransactionPage extends StatelessWidget {
  final TransactionType? transactionType;
  final bool isEditing;
  final String? transactionId;
  final controller = Get.find<TransactionController>();

  TransactionPage({
    this.transactionType,
    this.isEditing = false,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: _getColor(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Adicione a descrição',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onChanged: controller.setDescription,
              controller: TextEditingController(text: controller.description),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Valor',
                hintText: '0,00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                controller.setAmount(double.tryParse(value.replaceAll(',', '.')) ?? 0);
              },
              controller: TextEditingController(
                text: controller.amount > 0 ? controller.amount.toString() : '',
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => DefaultButtonSelectCategory(
                  selectedCategory: controller.selectedCategory != null ? int.tryParse(controller.selectedCategory!) : null,
                  onTap: (categoryId) {
                    if (categoryId != null) {
                      controller.setCategory(
                        categoryId.toString(),
                      );
                    }
                  },
                )),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildCheckbox(
                        'Fixo',
                        controller.isRecurring,
                        controller.toggleRecurring,
                      )),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Obx(() => _buildCheckbox(
                        'Parcelado',
                        controller.isInstallment,
                        controller.toggleInstallment,
                      )),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                if (transactionType == null) return;

                if (isEditing && transactionId != null) {
                  controller.updateTransaction(
                    transactionId!,
                    transactionType!,
                    'contaInicial',
                  );
                } else {
                  controller.addTransaction(
                    transactionType!,
                    'contaInicial',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, VoidCallback onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.greyLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 14.sp),
        ),
        value: value,
        onChanged: (_) => onChanged(),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  String _getTitle() {
    if (transactionType == null) return '';
    final prefix = isEditing ? 'Editar' : 'Nova';
    switch (transactionType!) {
      case TransactionType.receita:
        return '$prefix Receita';
      case TransactionType.despesa:
        return '$prefix Despesa';
      case TransactionType.transferencia:
        return '$prefix Transferência';
    }
  }

  Color _getColor() {
    if (transactionType == null) return DefaultColors.grey;
    switch (transactionType!) {
      case TransactionType.receita:
        return DefaultColors.green;
      case TransactionType.despesa:
        return DefaultColors.red;
      case TransactionType.transferencia:
        return DefaultColors.grey;
    }
  }
}
