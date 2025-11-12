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
  final ValueNotifier<GoalModel> goalNotifier;

  GoalDetailsPage({
    super.key,
    required this.initialGoal,
  }) : goalNotifier = ValueNotifier<GoalModel>(initialGoal);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: ValueListenableBuilder<GoalModel>(
          valueListenable: goalNotifier,
          builder: (context, currentGoal, _) => Text(
            currentGoal.name,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
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
                    initialGoal: goalNotifier.value,
                  ));
              if (edited is GoalModel) {
                goalNotifier.value = edited;
              }
            },
          ),
          IconButton(
            icon: Icon(
              Iconsax.trash,
              color: theme.primaryColor,
            ),
            onPressed: () async {
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    backgroundColor: theme.cardColor,
                    title: Text(
                      'Confirmar exclusão',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: Text(
                      'Tem certeza que deseja deletar esta meta?',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(
                          'Deletar',
                          style: TextStyle(
                            color: DefaultColors.darkGrey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
              if (confirmed == true) {
                await goalController.deleteGoal(initialGoal.id!);
                // Volta apenas uma vez para a página anterior
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: initialGoal.id == null
              ? const Stream.empty()
              : FirebaseFirestore.instance
                  .collection('goals')
                  .doc(initialGoal.id!)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data?.data() != null) {
              final data = snapshot.data!.data()!;
              goalNotifier.value =
                  GoalModel.fromMap(data).copyWith(id: initialGoal.id);
            }
            return ValueListenableBuilder<GoalModel>(
              valueListenable: goalNotifier,
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
                // final String formattedDate = currentGoal.date;
                final String headerForecast = (() {
                  try {
                    final parts = currentGoal.date.split('/');
                    final d = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(d);
                  } catch (_) {
                    return currentGoal.date;
                  }
                })();

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
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: (category != null &&
                                            category['color'] != null)
                                        ? category['color'] as Color
                                        : DefaultColors.grey,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                if (category != null &&
                                    (category['icon'] as String).isNotEmpty)
                                  Image.asset(
                                    category['icon'] as String,
                                    width: 30.w,
                                    height: 30.w,
                                  )
                                else
                                  Icon(
                                    Icons.category,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Categoria: ',
                                        style: TextStyle(
                                          color: DefaultColors.grey,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: category != null
                                            ? (category['name'] as String)
                                            : '—',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Text(
                                      'Previsão: ',
                                      style: TextStyle(
                                        color: DefaultColors.grey,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      headerForecast,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    int daysLeft = 0;
                                    try {
                                      final parts = currentGoal.date.split('/');
                                      final dl = DateTime(
                                        int.parse(parts[2]),
                                        int.parse(parts[1]),
                                        int.parse(parts[0]),
                                      );
                                      final now = DateTime.now();
                                      final todayOnly = DateTime(
                                          now.year, now.month, now.day);
                                      final dueOnly =
                                          DateTime(dl.year, dl.month, dl.day);
                                      daysLeft =
                                          dueOnly.difference(todayOnly).inDays;
                                    } catch (_) {}
                                    final String daysLabel = daysLeft > 0
                                        ? 'Faltam $daysLeft dia${daysLeft == 1 ? '' : 's'}'
                                        : (daysLeft == 0
                                            ? 'Vence hoje'
                                            : 'Atrasada há ${daysLeft.abs()} dia${daysLeft.abs() == 1 ? '' : 's'}');
                                    return Text(
                                      " ($daysLabel)",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: daysLeft < 0
                                            ? DefaultColors.redDark
                                            : theme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Icon and information section

                    SizedBox(height: 14.h),

                    // Ação de Dicas (antes do valor do saldo atual)
                    InkWell(
                      onTap: () => _showTipsBottomSheet(context, currentGoal),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              size: 14.sp,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Dicas',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),
                    // Progress values
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "R\$ $formattedCurrentValue",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              "Saldo atual",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "R\$ $formattedTargetValue",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              "Meta",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: DefaultColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        )
                      ],
                    ),

                    SizedBox(
                      height: 30.h,
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
                      // dias restantes não utilizados na versão atual
                      // final String daysLabel = daysLeft > 0
                      //     ? 'Faltam ${daysLeft} dia${daysLeft == 1 ? '' : 's'}'
                      //     : (daysLeft == 0
                      //         ? 'Vence hoje'
                      //         : 'Atrasada há ${daysLeft.abs()} dia${daysLeft.abs() == 1 ? '' : 's'}');
                      final bool isCompleted = numericValue > 0 &&
                          currentGoal.currentValue >= numericValue;
                      if (isCompleted) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'A recompensa do esforço chega com nome e sobrenome: meta conquistada! 💪',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Faltam R\$ ${_formatCurrencyBRL(remaining)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 10.h),

                    // Transações
                    Text(
                      'Transações',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: DefaultColors.grey,
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
                          // Resumo de totais
                          double added = 0;
                          double removed = 0;
                          for (final d in docs) {
                            final m = d.data();
                            final double amount =
                                (m['amount'] as num?)?.toDouble() ?? 0.0;
                            final bool isAddition = m['isAddition'] == true;
                            if (isAddition) {
                              added += amount;
                            } else {
                              removed += amount;
                            }
                          }
                          // final double net = added - removed;

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color:
                                          theme.primaryColor.withOpacity(0.08)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _summaryPill(context,
                                        label: 'Total adicionado',
                                        value: added,
                                        color: Colors.green,
                                        prefix: '+'),
                                    _summaryPill(context,
                                        label: 'Total retirado',
                                        value: removed,
                                        color: DefaultColors.redDark,
                                        prefix: '-'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: docs.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 8.h),
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data();
                                    final bool isAddition =
                                        data['isAddition'] == true;
                                    final double amount =
                                        (data['amount'] as num?)?.toDouble() ??
                                            0.0;
                                    final Timestamp? ts =
                                        data['date'] as Timestamp?;
                                    final DateTime date =
                                        ts?.toDate() ?? DateTime.now();
                                    final String label = isAddition
                                        ? 'Valor adicionado'
                                        : 'Valor retirado';
                                    final String dateStr =
                                        DateFormat('dd/MM/yyyy').format(date);

                                    return Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 18.w,
                                                height: 18.w,
                                                decoration: BoxDecoration(
                                                  color: (isAddition
                                                          ? Colors.green
                                                          : DefaultColors
                                                              .redDark)
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                ),
                                                child: Icon(
                                                  isAddition
                                                      ? Icons.arrow_downward
                                                      : Icons.arrow_upward,
                                                  size: 12.sp,
                                                  color: isAddition
                                                      ? Colors.green
                                                      : DefaultColors.redDark,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    label,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => _showRemoveValueBottomSheet(
                                context, goalNotifier),
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
                            onTap: () =>
                                _showAddValueBottomSheet(context, goalNotifier),
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
                    SizedBox(height: 10.h),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _summaryPill(BuildContext context,
      {required String label,
      required double value,
      required Color color,
      required String prefix,
      bool showPrefixAsSign = true}) {
    String textValue = _formatCurrencyBRL(value);
    String display =
        showPrefixAsSign ? '$prefix $textValue' : '$prefix$textValue';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: DefaultColors.grey),
        ),
        SizedBox(height: 2.h),
        Text(
          display,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
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
      BuildContext context, ValueNotifier<GoalModel> goalNotifierParam) {
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
                  AdsBanner(),
                  SizedBox(
                    height: 10.h,
                  ),
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
                              final updatedGoal =
                                  goalNotifierParam.value.copyWith(
                                currentValue:
                                    goalNotifierParam.value.currentValue +
                                        valueToAdd,
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
                              goalNotifierParam.value = updatedGoal;
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
      BuildContext context, ValueNotifier<GoalModel> goalNotifierParam) {
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
                              final updatedGoal =
                                  goalNotifierParam.value.copyWith(
                                currentValue:
                                    goalNotifierParam.value.currentValue -
                                        valueToRemove,
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
                              goalNotifierParam.value = updatedGoal;
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

void _showTipsBottomSheet(BuildContext context, GoalModel goal) {
  final theme = Theme.of(context);

  // Parse target value
  String sanitized = goal.value.replaceAll(RegExp(r'[^0-9,\.]'), '');
  final int lastComma = sanitized.lastIndexOf(',');
  final int lastDot = sanitized.lastIndexOf('.');
  final int sepIndex = lastComma > lastDot ? lastComma : lastDot;
  String numeric;
  if (sepIndex != -1) {
    final String intPart =
        sanitized.substring(0, sepIndex).replaceAll(RegExp(r'[^0-9]'), '');
    final String decPart =
        sanitized.substring(sepIndex + 1).replaceAll(RegExp(r'[^0-9]'), '');
    numeric = '$intPart.$decPart';
  } else {
    numeric = sanitized.replaceAll(RegExp(r'[^0-9]'), '');
  }
  final double target = double.tryParse(numeric) ?? 0.0;
  final double current = goal.currentValue;
  final double remaining = (target - current).clamp(0, double.infinity);

  // Deadline
  DateTime? deadline;
  try {
    final parts = goal.date.split('/');
    deadline = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  } catch (_) {
    deadline = null;
  }

  final DateTime today = DateTime.now();
  final DateTime start = DateTime(today.year, today.month, today.day);
  final DateTime end = deadline != null
      ? DateTime(deadline.year, deadline.month, deadline.day)
      : start;
  final int totalDays = end.isAfter(start) ? end.difference(start).inDays : 0;

  double perDay = totalDays > 0 ? remaining / totalDays : remaining;
  double perWeek = totalDays > 0 ? remaining / (totalDays / 7.0) : remaining;
  double perFortnight =
      totalDays > 0 ? remaining / (totalDays / 15.0) : remaining;
  double perMonth = totalDays > 0 ? remaining / (totalDays / 30.0) : remaining;
  // Only show 3m/6m/1y when prazo >= respectivo período
  double per3Months = (totalDays >= 90) ? remaining / (totalDays / 90.0) : 0.0;
  double per6Months =
      (totalDays >= 180) ? remaining / (totalDays / 180.0) : 0.0;
  double per1Year = (totalDays >= 365) ? remaining / (totalDays / 365.0) : 0.0;

  String brl(double v) {
    String s = v.isFinite ? v.toStringAsFixed(2) : '0.00';
    s = s.replaceAll('.', ',');
    final parts = s.split(',');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '00';
    if (intPart.length > 3) {
      String result = '';
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        result = intPart[i] + result;
        count++;
        if (count % 3 == 0 && i > 0) result = '.$result';
      }
      intPart = result;
    }
    return 'R\$ $intPart,$decPart';
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            16.w, 16.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.lightbulb_outline,
                        size: 16.sp, color: Colors.amber.shade700),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Dicas inteligentes',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Transforme suas economias em conquistas! Coloque seu dinheiro para render na caixinha do Nubank ou no cofrinho do Inter e veja seus sonhos ganharem vida 🚀',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),
              Text(
                'Vamos calcular quanto você precisa colocar na caixinha para alcançar sua meta? ',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _forecastLine('Por dia', brl(perDay)),
                    _forecastLine('Por semana', brl(perWeek)),
                    _forecastLine('Por quinzena', brl(perFortnight)),
                    _forecastLine('Por mês', brl(perMonth)),
                    if (per3Months > 0)
                      _forecastLine('A cada 3 meses', brl(per3Months)),
                    if (per6Months > 0)
                      _forecastLine('A cada 6 meses', brl(per6Months)),
                    if (per1Year > 0) _forecastLine('Por ano', brl(per1Year)),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Fechar',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _forecastLine(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12.sp, color: DefaultColors.grey)),
        Text(value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
