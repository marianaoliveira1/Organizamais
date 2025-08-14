import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/spending_goal_controller.dart';
import '../../../model/spending_goal_model.dart';
import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../../transaction/transaction_page.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/title_transaction.dart';
import '../spending_goals_page.dart';

class AddSpendingGoalPage extends StatefulWidget {
  const AddSpendingGoalPage({super.key});

  @override
  _AddSpendingGoalPageState createState() => _AddSpendingGoalPageState();
}

class _AddSpendingGoalPageState extends State<AddSpendingGoalPage> {
  final SpendingGoalController spendingGoalController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController limitValueController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? categoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Define um nome padrão baseado no mês atual
    final monthName = DateFormat.MMMM('pt_BR').format(_selectedDate);
    nameController.text =
        'Meta ${monthName[0].toUpperCase()}${monthName.substring(1)}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecionar mês/ano da meta',
      fieldHintText: 'dd/mm/aaaa',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Atualiza o nome da meta com o novo mês
        final monthName = DateFormat.MMMM('pt_BR').format(_selectedDate);
        nameController.text =
            'Meta ${monthName[0].toUpperCase()}${monthName.substring(1)}';
      });
    }
  }

  bool _isFormValid() {
    return nameController.text.isNotEmpty &&
        limitValueController.text.isNotEmpty &&
        categoryId != null;
  }

  bool _hasExistingGoal() {
    if (categoryId == null) return false;
    return spendingGoalController.hasGoalForCategory(
      categoryId!,
      _selectedDate.month,
      _selectedDate.year,
    );
  }

  double _parseLimitValue() {
    return double.tryParse(
          limitValueController.text
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim(),
        ) ??
        0.0;
  }

  Future<void> _saveSpendingGoal() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final spendingGoal = SpendingGoalModel(
        name: nameController.text.trim(),
        limitValue: _parseLimitValue(),
        categoryId: categoryId!,
        month: _selectedDate.month,
        year: _selectedDate.year,
      );

      await spendingGoalController.addSpendingGoal(spendingGoal);
      Get.offAll(() => SpendingGoalsPage());
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar meta: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Nova Meta de Gasto',
          style: TextStyle(color: theme.primaryColor),
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: theme.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          spacing: 16.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            DefaultTitleTransaction(title: "Nome da Meta"),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
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
                hintText: 'ex: Meta Alimentação Dezembro',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            DefaultTitleTransaction(title: "Limite de Gasto"),
            TextField(
              controller: limitValueController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                fillColor: theme.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.attach_money),
                prefixIconColor: DefaultColors.grey,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                focusColor: theme.primaryColor,
                hintText: "0,00",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(0.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            DefaultTitleTransaction(title: "Mês/Ano"),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "${DateFormat.MMMM('pt_BR').format(_selectedDate)[0].toUpperCase()}${DateFormat.MMMM('pt_BR').format(_selectedDate).substring(1)} ${_selectedDate.year}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DefaultTitleTransaction(title: "Categoria"),
            DefaultButtonSelectCategory(
              selectedCategory: categoryId,
              onTap: (category) {
                setState(() {
                  categoryId = category;
                });
              },
              transactionType: TransactionType.despesa,
            ),
            if (_hasExistingGoal() && categoryId != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Já existe uma meta para esta categoria neste mês. Você pode adicionar múltiplas metas para melhor controle.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metas existentes para esta categoria:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...spendingGoalController
                        .getGoalsForMonth(
                            _selectedDate.month, _selectedDate.year)
                        .where((goal) => goal.categoryId == categoryId)
                        .map((goal) => Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    spendingGoalController
                                        .formatCurrency(goal.limitValue),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid() && !_isLoading
                      ? theme.primaryColor
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                onPressed:
                    _isFormValid() && !_isLoading ? _saveSpendingGoal : null,
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _hasExistingGoal() && categoryId != null
                            ? 'Adicionar Nova Meta'
                            : 'Criar Meta',
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
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    limitValueController.dispose();
    super.dispose();
  }
}
