import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../transaction/pages/category_page.dart';

class GoalDetailsPage extends StatelessWidget {
  final GoalModel initialGoal;
  final GoalController goalController = Get.find();

  GoalDetailsPage({
    super.key,
    required this.initialGoal,
  });

  @override
  Widget build(BuildContext context) {
    final goal = ValueNotifier<GoalModel>(initialGoal);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          initialGoal.name,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.trash,
              color: theme.primaryColor,
            ),
            onPressed: () {
              goalController.deleteGoal(initialGoal.id!);
              Get.back();
            },
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ValueListenableBuilder<GoalModel>(
          valueListenable: goal,
          builder: (context, currentGoal, child) {
            if (currentGoal == null) {
              return Center(child: Text('Meta não encontrada.'));
            }

            final String cleanedValue = currentGoal.value.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll(',', '.');
            final double numericValue = double.tryParse(cleanedValue) ?? 0.0;
            final double progress = currentGoal.currentValue / numericValue;
            final category = findCategoryById(currentGoal.categoryId);
            final currentDate = DateTime.now();
            final formattedDate = "${currentDate.day}, ${_getMonthName(currentDate.month)}. ${currentDate.year}";

            // Format values in Brazilian Real standard
            final String formattedCurrentValue = _formatCurrencyBRL(currentGoal.currentValue);
            final String formattedTargetValue = _formatCurrencyBRL(numericValue);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    category != null
                        ? Image.asset(
                            category['icon'],
                            height: 38.h,
                            width: 38.w,
                          )
                        : Icon(
                            Icons.category,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                // Icon and information section

                SizedBox(height: 8.h),

                // Progress values
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "R\$ $formattedCurrentValue",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      "R\$ $formattedTargetValue",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 32.h),

                Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _showRemoveValueBottomSheet(context, goal),
                        child: Container(
                          padding: EdgeInsets.all(14.h),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            'Retirar valor',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showAddValueBottomSheet(context, goal),
                        child: Container(
                          padding: EdgeInsets.all(14.h),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            'Adicionar valor',
                            style: TextStyle(
                              color: theme.cardColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final List<String> months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    return months[month - 1];
  }

  // Helper method to format currency in Brazilian Real standard
  String _formatCurrencyBRL(double value) {
    // Convert to string with 2 decimal places
    String stringValue = value.toStringAsFixed(2);

    // Replace dot with comma for decimal separator
    stringValue = stringValue.replaceAll('.', ',');

    // Add thousand separators
    List<String> parts = stringValue.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Add thousands separator (.) for values over 999
    if (integerPart.length > 3) {
      String result = '';
      int count = 0;

      for (int i = integerPart.length - 1; i >= 0; i--) {
        result = integerPart[i] + result;
        count++;

        if (count % 3 == 0 && i > 0) {
          result = '.' + result;
        }
      }

      integerPart = result;
    }

    return "$integerPart,$decimalPart";
  }

  void _showAddValueBottomSheet(BuildContext context, ValueNotifier<GoalModel> goal) {
    double valueToAdd = 0;
    DateTime selectedDate = DateTime.now();
    TextEditingController valueController = TextEditingController();
    bool isFormValid = false; // Added form validation flag

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            // Function to validate form
            void validateForm() {
              modalSetState(() {
                isFormValid = valueController.text.isNotEmpty && valueToAdd > 0;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Adicionar valor',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Valor a adicionar',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
                    ),
                    onChanged: (value) {
                      // Permite entrada no formato brasileiro (com vírgula)
                      String cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
                      valueToAdd = double.tryParse(cleanValue) ?? 0;
                      validateForm(); // Validate after change
                    },
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        modalSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid ? Colors.black : Colors.grey, // Change color based on validation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: isFormValid
                          ? () {
                              // Only allow press when form is valid
                              if (goal.value == null) return;
                              final updatedGoal = goal.value.copyWith(
                                currentValue: goal.value.currentValue + valueToAdd,
                              );
                              goalController.updateGoal(updatedGoal);
                              goal.value = updatedGoal;
                              Navigator.pop(context);
                            }
                          : null, // Disable button when not valid
                      child: Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRemoveValueBottomSheet(BuildContext context, ValueNotifier<GoalModel> goal) {
    double valueToRemove = 0;
    DateTime selectedDate = DateTime.now();
    TextEditingController valueController = TextEditingController();
    bool isFormValid = false; // Added form validation flag

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            // Function to validate form
            void validateForm() {
              modalSetState(() {
                isFormValid = valueController.text.isNotEmpty && valueToRemove > 0;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Retirar valor',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'R\$ Valor a retirar',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
                    ),
                    onChanged: (value) {
                      // Permite entrada no formato brasileiro (com vírgula)
                      String cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
                      valueToRemove = double.tryParse(cleanValue) ?? 0;
                      validateForm(); // Validate after change
                    },
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        modalSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid ? Colors.black : Colors.grey, // Change color based on validation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: isFormValid
                          ? () {
                              // Only allow press when form is valid
                              if (goal.value == null) return;
                              final updatedGoal = goal.value.copyWith(
                                currentValue: goal.value.currentValue - valueToRemove,
                              );
                              goalController.updateGoal(updatedGoal);
                              goal.value = updatedGoal;
                              Navigator.pop(context);
                            }
                          : null, // Disable button when not valid
                      child: Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
