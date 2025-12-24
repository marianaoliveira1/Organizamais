// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/card_controller.dart';
import '../../../model/cards_model.dart';
import '../../../utils/snackbar_helper.dart';
import 'select_icon_page.dart';
import '../../../routes/route.dart';
import '../../../widgetes/currency_ipunt_formated.dart';

class AddCardPage extends StatefulWidget {
  final bool isEditing;
  final CardsModel? card;
  final bool fromOnboarding;

  const AddCardPage({
    super.key,
    required this.isEditing,
    this.card,
    this.fromOnboarding = false,
  });

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final nameController = TextEditingController();
  final limitController = TextEditingController();
  final closingDayController = TextEditingController();
  final paymentDayController = TextEditingController();
  String? selectedIconPath;
  String? selectedBankName;
  final CardController cardController = Get.find();
  bool _isSaving = false;
  bool isTotalLimit = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.card != null) {
      nameController.text = widget.card!.name;
      if (widget.card!.limit != null) {
        final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        limitController.text = currency.format(widget.card!.limit);
      } else {
        limitController.text = '';
      }
      selectedIconPath = widget.card!.iconPath;
      selectedBankName = widget.card!.bankName;
      closingDayController.text = widget.card!.closingDay?.toString() ?? '';
      paymentDayController.text = widget.card!.paymentDay?.toString() ?? '';
      isTotalLimit = widget.card!.isTotalLimit;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    limitController.dispose();
    closingDayController.dispose();
    paymentDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageTitle = widget.isEditing ? 'Editar cartão' : 'Criar cartão';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        title: Text(
          pageTitle,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdsBanner(),
                    SizedBox(height: 16.h),
                    _buildIconSelectorCard(theme),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(theme, 'Informações do cartão'),
                    SizedBox(height: 12.h),
                    _buildFilledTextField(
                      theme: theme,
                      label: 'Nome do cartão',
                      controller: nameController,
                      hint: 'Digite o nome do cartão',
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    _buildFilledTextField(
                      theme: theme,
                      label: 'Limite do cartão',
                      controller: limitController,
                      hint: 'Limite do cartão (R\$)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilledTextField(
                            theme: theme,
                            label: 'Fecha no dia',
                            controller: closingDayController,
                            hint: '1 a 31',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                              DayRangeFormatter(max: 31),
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildFilledTextField(
                            theme: theme,
                            label: 'Paga no dia',
                            controller: paymentDayController,
                            hint: '1 a 31',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                              DayRangeFormatter(max: 31),
                            ],
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildLimitSystemSelector(theme),
                    SizedBox(height: 28.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                            color: theme.primaryColor.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconsax.info_circle,
                                color: theme.primaryColor, size: 16.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Use os mesmos dias de fechamento e pagamento da sua fatura para que alertas e controles fiquem alinhados.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            _buildPrimaryButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelectorCard(ThemeData theme) {
    final hasIcon = selectedIconPath != null;
    return GestureDetector(
      onTap: _isSaving
          ? null
          : () {
              Get.to(() => SelectIconPage(
                    onIconSelected: (path, name) {
                      setState(() {
                        selectedIconPath = path;
                        selectedBankName = name;
                      });
                    },
                  ));
            },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: theme.primaryColor.withOpacity(0.06),
              ),
              child: hasIcon
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Image.asset(
                        selectedIconPath!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(Iconsax.card_add,
                      color: theme.primaryColor, size: 26.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasIcon ? 'Banco selecionado' : 'Escolha um ícone',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    hasIcon
                        ? (selectedBankName ?? 'Personalizado')
                        : 'Toque para selecionar o banco/cartão',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3,
                color: theme.primaryColor.withOpacity(0.6), size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSystemSelector(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.setting_4, color: theme.primaryColor, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Sistema de limite',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              isTotalLimit ? 'Limite Total' : 'Limite Parcelado',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
            subtitle: Text(
              isTotalLimit
                  ? 'Todo o valor da compra parcelada bloqueia o limite.'
                  : 'Apenas a parcela do mês bloqueia o limite.',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.primaryColor.withOpacity(0.6),
              ),
            ),
            value: isTotalLimit,
            onChanged: (val) {
              setState(() {
                isTotalLimit = val;
              });
            },
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilledTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: theme.primaryColor.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.primaryColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.primaryColor.withOpacity(0.45),
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: theme.primaryColor.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: theme.primaryColor.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: theme.primaryColor.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _isSaving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.scaffoldBackgroundColor),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(widget.isEditing
                          ? 'Atualizando...'
                          : 'Adicionando...'),
                    ],
                  )
                : Text(
                    widget.isEditing ? 'Atualizar cartão' : 'Adicionar cartão',
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;

    if (nameController.text.trim().isEmpty || selectedIconPath == null) {
      SnackbarHelper.showError('Preencha todos os campos e selecione um ícone');
      return;
    }

    final closingDay = int.tryParse(closingDayController.text);
    if (closingDay == null || closingDay < 1 || closingDay > 31) {
      SnackbarHelper.showError('Informe o dia de fechamento entre 1 e 31');
      return;
    }

    final paymentDay = int.tryParse(paymentDayController.text);
    if (paymentDay == null || paymentDay < 1 || paymentDay > 31) {
      SnackbarHelper.showError('Informe o dia de pagamento entre 1 e 31');
      return;
    }

    String limitText = limitController.text.trim();
    String rawLimit = limitText.replaceAll('R\$', '').trim();
    double? parsedLimit;
    if (rawLimit.isNotEmpty) {
      if (rawLimit.contains(',')) {
        rawLimit = rawLimit.replaceAll('.', '').replaceAll(',', '.');
      } else {
        rawLimit = rawLimit.replaceAll(' ', '');
      }
      parsedLimit = double.tryParse(rawLimit);
    }

    final cardData = CardsModel(
      id: widget.isEditing ? widget.card!.id : null,
      name: nameController.text.trim(),
      iconPath: selectedIconPath,
      bankName: selectedBankName,
      userId: widget.isEditing ? widget.card!.userId : null,
      limit: parsedLimit,
      closingDay: closingDay,
      paymentDay: paymentDay,
      isTotalLimit: isTotalLimit,
    );

    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await cardController.updateCard(cardData);
      } else {
        await cardController.addCard(cardData);
      }

      if (!mounted) return;

      if (widget.fromOnboarding) {
        Get.offAllNamed(Routes.CARD_SUCCESS);
      } else {
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            'Erro ao ${widget.isEditing ? 'atualizar' : 'adicionar'} cartão: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Formata entrada numérica para restringir o valor máximo por dígitos.
class DayRangeFormatter extends TextInputFormatter {
  final int max;
  const DayRangeFormatter({this.max = 31});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Mantém apenas dígitos (já garantido pelo Filtering, mas por segurança)
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }

    int value = int.tryParse(digits) ?? 0;
    if (value == 0) {
      // Evita 00/0
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }
    if (value > max) value = max;

    final textOut = value.toString();
    return TextEditingValue(
      text: textOut,
      selection: TextSelection.collapsed(offset: textOut.length),
    );
  }
}
