// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/transaction_page.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/title_transaction.dart';
import '../../../routes/route.dart';

class AddGoalPage extends StatefulWidget {
  final bool isEditing;
  final GoalModel? initialGoal;
  const AddGoalPage({super.key, this.isEditing = false, this.initialGoal});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final GoalController goalController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  DateTime _selectedDate =
      DateTime.now(); // Use um nome diferente para evitar confusão
  int? categoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialGoal != null) {
      final g = widget.initialGoal!;
      nameController.text = g.name;
      valueController.text = g.value; // já está formatado em BRL
      try {
        final parts = g.date.split('/');
        _selectedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (_) {}
      categoryId = g.categoryId;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) {
        final t = Theme.of(ctx);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              surface: theme.cardColor,
              primary: theme.primaryColor,
              onPrimary: theme.cardColor,
              onSurface: theme.primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: theme.cardColor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isFormValid() {
    return nameController.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        categoryId != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          widget.isEditing ? 'Editar Meta' : 'Adicionar Meta',
          style: TextStyle(color: theme.primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            DefaultTitleTransaction(
              title: "Titulo",
            ),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
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
                hintText: 'ex: Comprar um carro',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(.5),
                ),
              ),
              onChanged: (_) =>
                  setState(() {}), // Atualiza o estado ao mudar o texto
            ),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            TextField(
              controller: valueController,
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
                  borderRadius: BorderRadius.circular(
                    12.r,
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
                focusColor: theme.primaryColor,
                hintText: "R\$ 0,00",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(0.5),
                ),
              ),
              onChanged: (_) =>
                  setState(() {}), // Atualiza o estado ao mudar o texto
            ),
            DefaultTitleTransaction(
              title: "Data",
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(
                  16.r,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(.5),
                  ),
                ),
                child: Text(
                  "Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
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
              transactionType: TransactionType.despesa,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: (_isFormValid() && !_isSaving)
                    ? () async {
                        setState(() {
                          _isSaving = true;
                        });
                        try {
                          final String raw = valueController.text;
                          // Sanitiza mantendo apenas dígitos e separadores , .
                          final String sanitized =
                              raw.replaceAll(RegExp(r'[^0-9,\.]'), '');
                          // Converte BRL preservando centavos: usa o ÚLTIMO separador (vírgula ou ponto) como decimal
                          final int lastComma = sanitized.lastIndexOf(',');
                          final int lastDot = sanitized.lastIndexOf('.');
                          final int sepIndex =
                              lastComma > lastDot ? lastComma : lastDot;
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
                            numeric =
                                sanitized.replaceAll(RegExp(r'[^0-9]'), '');
                          }
                          final double value = double.tryParse(numeric) ?? 0.0;

                          if (widget.isEditing && widget.initialGoal != null) {
                            // Se o usuário não alterou o texto do valor visualmente,
                            // preserve exatamente o valor salvo (evita reformatar para 0,00 por parse)
                            String finalValueStr;
                            if (valueController.text.trim() ==
                                widget.initialGoal!.value.trim()) {
                              finalValueStr = widget.initialGoal!.value;
                            } else {
                              finalValueStr = NumberFormat.currency(
                                locale: 'pt_BR',
                              ).format(value);
                              // Fallback APENAS se o valor numérico ficou exatamente 0
                              if (value == 0.0) {
                                final String prevSanitized = widget
                                    .initialGoal!.value
                                    .replaceAll(RegExp(r'[^0-9,\.]'), '');
                                if (prevSanitized.isNotEmpty) {
                                  finalValueStr = widget.initialGoal!.value;
                                }
                              }
                            }
                            final updated = widget.initialGoal!.copyWith(
                              name: nameController.text,
                              value: finalValueStr,
                              date: DateFormat('dd/MM/yyyy')
                                  .format(_selectedDate),
                              categoryId:
                                  categoryId ?? widget.initialGoal!.categoryId,
                            );
                            await goalController.updateGoal(updated);
                            // Volta para a tela anterior; se não houver stack, cai para a home
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(updated);
                            } else {
                              Get.offAllNamed(Routes.INITIAL);
                            }
                          } else {
                            final goal = GoalModel(
                              name: nameController.text,
                              value: NumberFormat.currency(locale: 'pt_BR')
                                  .format(value),
                              date: DateFormat('dd/MM/yyyy')
                                  .format(_selectedDate),
                              categoryId: categoryId ?? 0,
                              currentValue: 0,
                            );
                            await goalController.addGoal(goal);
                            // Navega para a página inicial com o card de metas
                            Get.offAllNamed(Routes.INITIAL);
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        }
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: (_isFormValid() && !_isSaving)
                          ? theme.primaryColor.withOpacity(.5)
                          : Colors.grey.withOpacity(.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _isSaving
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryColor,
                          ),
                        )
                      : Text(
                          widget.isEditing ? "Atualizar" : "Salvar",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: (_isFormValid() && !_isSaving)
                                ? theme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
