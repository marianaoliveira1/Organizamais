import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../transaction/pages/category_page.dart';
import 'add_goal_page.dart';
import '../../../widgetes/currency_ipunt_formated.dart';
import '../../../utils/color.dart';

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
              Iconsax.edit,
              color: theme.primaryColor,
            ),
            onPressed: () async {
              final edited = await Get.to(() => AddGoalPage(
                    isEditing: true,
                    initialGoal: goal.value,
                  ));
              if (edited is GoalModel) {
                goal.value = edited;
              }
            },
          ),
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
            final String sanitized =
                currentGoal.value.replaceAll(RegExp(r'[^0-9,\.]'), '');
            final int lastComma = sanitized.lastIndexOf(',');
            final int lastDot = sanitized.lastIndexOf('.');
            final int sepIndex = lastComma > lastDot ? lastComma : lastDot;
            String numeric;
            if (sepIndex != -1) {
              final String intPart = sanitized
                  .substring(0, sepIndex)
                  .replaceAll(RegExp(r'[^0-9]'), '');
              final String decPart = sanitized
                  .substring(sepIndex + 1)
                  .replaceAll(RegExp(r'[^0-9]'), '');
              numeric = '$intPart.$decPart';
            } else {
              numeric = sanitized.replaceAll(RegExp(r'[^0-9]'), '');
            }
            final double numericValue = double.tryParse(numeric) ?? 0.0;
            final double progress = currentGoal.currentValue / numericValue;
            final category = findCategoryById(currentGoal.categoryId);
            final String formattedDate = currentGoal.date;

            // Format values in Brazilian Real standard
            final String formattedCurrentValue =
                _formatCurrencyBRL(currentGoal.currentValue);
            final String formattedTargetValue =
                _formatCurrencyBRL(numericValue);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdsBanner(),
                SizedBox(height: 10.h),
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

                SizedBox(height: 14.h),

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

                // Progress bar with percentage bubble
                SizedBox(
                  height: 20.h,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double barWidth = constraints.maxWidth;
                    final double clamped = progress.clamp(0.0, 1.0);
                    final double markerLeft =
                        (barWidth * clamped - 20).clamp(0, barWidth - 40);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: clamped,
                            backgroundColor: Colors.grey.shade300,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 8.h,
                          ),
                        ),
                        Positioned(
                          left: markerLeft,
                          top: -22.h,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${(clamped * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                width: 2.w,
                                height: 10.h,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // Resumo: quanto falta e dias restantes
                Builder(builder: (context) {
                  final double remaining =
                      (numericValue - currentGoal.currentValue)
                          .clamp(0, double.infinity);
                  int daysLeft = 0;
                  try {
                    final parts = currentGoal.date.split('/');
                    final dl = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                    final now = DateTime.now();
                    final todayOnly = DateTime(now.year, now.month, now.day);
                    final dueOnly = DateTime(dl.year, dl.month, dl.day);
                    daysLeft = dueOnly.difference(todayOnly).inDays;
                  } catch (_) {}
                  final String daysLabel = daysLeft > 0
                      ? 'Faltam ${daysLeft} dia${daysLeft == 1 ? '' : 's'}'
                      : (daysLeft == 0
                          ? 'Vence hoje'
                          : 'Atrasada há ${daysLeft.abs()} dia${daysLeft.abs() == 1 ? '' : 's'}');
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Faltam R\$ ${_formatCurrencyBRL(remaining)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          daysLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: daysLeft < 0
                                ? DefaultColors.redDark
                                : theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 10.h),
                Text(
                  "A dica é: coloque esse valor onde possa render juros, como na Caixinha do Nubank ou no Cofrinho do Inter! Porque assim seu dinheiro vai render, no final você vai ter mais e merece aquele emoji de lâmpada 💡",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: DefaultColors.grey,
                  ),
                ),
                SizedBox(height: 10.h),

                // Transações
                Text(
                  'Transações',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: initialGoal.id == null
                        ? const Stream.empty()
                        : FirebaseFirestore.instance
                            .collection('goals')
                            .doc(initialGoal.id!)
                            .collection('transactions')
                            .orderBy('date', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Text(
                          'Nenhuma transação registrada.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final bool isAddition = data['isAddition'] == true;
                          final double amount =
                              (data['amount'] as num?)?.toDouble() ?? 0.0;
                          final Timestamp? ts = data['date'] as Timestamp?;
                          final DateTime date = ts?.toDate() ?? DateTime.now();
                          final String label = isAddition
                              ? 'Valor adicionado'
                              : 'Valor retirado';
                          final String dateStr =
                              DateFormat('dd/MM/yyyy').format(date);

                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'R\$ ${_formatCurrencyBRL(amount)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isAddition
                                        ? Colors.green
                                        : DefaultColors.redDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

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

  // _getMonthName was used previously for current date label; no longer needed.

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
          result = '.$result';
        }
      }

      integerPart = result;
    }

    return "$integerPart,$decimalPart";
  }

  void _showAddValueBottomSheet(
      BuildContext context, ValueNotifier<GoalModel> goal) {
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
                    inputFormatters: [CurrencyCentsInputFormatter()],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      fillColor: theme.primaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(.5),
                        ),
                      ),
                      focusColor: theme.primaryColor,
                      hintText: 'R\$ 0,00',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (value) {
                      // Converte "R$ 1.234,56" para double
                      String numeric = value
                          .replaceAll('R\$', '')
                          .trim()
                          .replaceAll('.', '')
                          .replaceAll(',', '.');
                      valueToAdd = double.tryParse(numeric) ?? 0;
                      validateForm();
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
                        backgroundColor: isFormValid
                            ? Colors.black
                            : Colors.grey, // Change color based on validation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: isFormValid
                          ? () async {
                              // Only allow press when form is valid
                              final updatedGoal = goal.value.copyWith(
                                currentValue:
                                    goal.value.currentValue + valueToAdd,
                              );
                              await goalController.updateGoal(updatedGoal);
                              try {
                                if (initialGoal.id != null) {
                                  await FirebaseFirestore.instance
                                      .collection('goals')
                                      .doc(initialGoal.id!)
                                      .collection('transactions')
                                      .add({
                                    'amount': valueToAdd,
                                    'date': selectedDate,
                                    'isAddition': true,
                                  });
                                }
                              } catch (_) {}
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

  void _showRemoveValueBottomSheet(
      BuildContext context, ValueNotifier<GoalModel> goal) {
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
                isFormValid =
                    valueController.text.isNotEmpty && valueToRemove > 0;
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
                    inputFormatters: [CurrencyCentsInputFormatter()],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
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
                      hintText: 'R\$ 0,00',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (value) {
                      String numeric = value
                          .replaceAll('R\$', '')
                          .trim()
                          .replaceAll('.', '')
                          .replaceAll(',', '.');
                      valueToRemove = double.tryParse(numeric) ?? 0;
                      validateForm();
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
                        backgroundColor: isFormValid
                            ? Colors.black
                            : Colors.grey, // Change color based on validation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: isFormValid
                          ? () async {
                              // Only allow press when form is valid
                              final updatedGoal = goal.value.copyWith(
                                currentValue:
                                    goal.value.currentValue - valueToRemove,
                              );
                              await goalController.updateGoal(updatedGoal);
                              try {
                                if (initialGoal.id != null) {
                                  await FirebaseFirestore.instance
                                      .collection('goals')
                                      .doc(initialGoal.id!)
                                      .collection('transactions')
                                      .add({
                                    'amount': valueToRemove,
                                    'date': selectedDate,
                                    'isAddition': false,
                                  });
                                }
                              } catch (_) {}
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
