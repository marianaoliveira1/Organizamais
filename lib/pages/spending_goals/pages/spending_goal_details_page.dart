import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/spending_goal_controller.dart';
import '../../../model/spending_goal_model.dart';
import '../../../widgetes/currency_ipunt_formated.dart';
import '../../transaction/pages/category_page.dart';
import '../../../utils/snackbar_helper.dart';

class SpendingGoalDetailsPage extends StatefulWidget {
  final SpendingGoalModel spendingGoal;

  const SpendingGoalDetailsPage({
    super.key,
    required this.spendingGoal,
  });

  @override
  State<SpendingGoalDetailsPage> createState() =>
      _SpendingGoalDetailsPageState();
}

class _SpendingGoalDetailsPageState extends State<SpendingGoalDetailsPage> {
  final SpendingGoalController spendingGoalController = Get.find();
  final TextEditingController valueController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = findCategoryById(widget.spendingGoal.categoryId);
    final spentAmount = spendingGoalController.calculateSpentAmount(
      widget.spendingGoal.categoryId,
      widget.spendingGoal.month,
      widget.spendingGoal.year,
    );
    final progress =
        spendingGoalController.calculateProgress(widget.spendingGoal);
    final isExceeded =
        spendingGoalController.isGoalExceeded(widget.spendingGoal);
    final remainingAmount =
        spendingGoalController.getRemainingAmount(widget.spendingGoal);

    Color progressColor = isExceeded
        ? Colors.red
        : progress > 0.8
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Detalhes da Meta',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da meta
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Ícone da categoria
                            if (category != null)
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Image.asset(
                                  category['icon'],
                                  height: 32.h,
                                  width: 32.w,
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: Colors.grey.shade600,
                                  size: 28.sp,
                                ),
                              ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.spendingGoal.name,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    category?['name'] ??
                                        'Categoria não encontrada',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Barra de progresso
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progresso',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: LinearProgressIndicator(
                                value: progress > 1.0 ? 1.0 : progress,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    progressColor),
                                minHeight: 12.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Informações financeiras
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações Financeiras',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Valores
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gasto Atual',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    spendingGoalController
                                        .formatCurrency(spentAmount),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isExceeded
                                          ? Colors.red
                                          : theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Limite da Meta',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    spendingGoalController.formatCurrency(
                                        widget.spendingGoal.limitValue),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Valor restante
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isExceeded
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isExceeded
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isExceeded ? Icons.warning : Icons.check_circle,
                                color: isExceeded ? Colors.red : Colors.green,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  isExceeded
                                      ? 'Limite ultrapassado em ${spendingGoalController.formatCurrency(-remainingAmount)}'
                                      : 'Restante: ${spendingGoalController.formatCurrency(remainingAmount)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isExceeded ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Botões de ajuste
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajustar Meta',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAdjustmentModal(context, true),
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  'Adicionar Valor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAdjustmentModal(context, false),
                                icon: Icon(Icons.remove, color: Colors.white),
                                label: Text(
                                  'Subtrair Valor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentModal(BuildContext context, bool isAddition) {
    valueController.clear();
    selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAddition ? 'Adicionar Valor' : 'Subtrair Valor',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'Valor',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  hintText: '0,00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Data',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey),
                      SizedBox(width: 12.w),
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (valueController.text.isNotEmpty) {
                      _processAdjustment(isAddition);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAddition ? Colors.green : Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    isAddition ? 'Adicionar' : 'Subtrair',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processAdjustment(bool isAddition) {
    final value = double.tryParse(
          valueController.text
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim(),
        ) ??
        0.0;

    if (value > 0) {
      // Aqui você implementaria a lógica para salvar o ajuste
      // Por exemplo, criar uma transação de ajuste ou atualizar a meta
      if (isAddition) {
        SnackbarHelper.showSuccess('Valor adicionado com sucesso');
      } else {
        SnackbarHelper.showError('Valor subtraído com sucesso',
            title: 'Sucesso');
      }
    }
  }
}
