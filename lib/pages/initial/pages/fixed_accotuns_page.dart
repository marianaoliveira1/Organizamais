// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/routes/route.dart';
import 'package:organizamais/routes/route.dart' as app_routes;
import '../../../ads_banner/ads_banner.dart';
import '../../../model/fixed_account_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/widget/button_select_category.dart';
import '../../transaction/widget/payment_type.dart';
import '../../transaction/widget/text_field_transaction.dart';
import '../widget/text_filed_value_fixed_accotuns.dart';
import 'periodicity_selection_page.dart';

class AddFixedAccountsFormPage extends StatefulWidget {
  final FixedAccountModel? fixedAccount;
  final Function(FixedAccountModel fixedAccount)? onSave;
  final bool fromOnboarding;

  const AddFixedAccountsFormPage(
      {super.key, this.fixedAccount, this.onSave, this.fromOnboarding = false});

  @override
  State<AddFixedAccountsFormPage> createState() =>
      _AddFixedAccountsFormPageState();
}

class _AddFixedAccountsFormPageState extends State<AddFixedAccountsFormPage> {
  int? categoryId;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dayOfTheMonthController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();
  final TextEditingController biweeklyDay1Controller = TextEditingController();
  final TextEditingController biweeklyDay2Controller = TextEditingController();
  String selectedFrequency = 'mensal';
  int? selectedWeeklyWeekday; // 1=Monday .. 7=Sunday
  bool isSaving = false;

  String _getFrequencyDisplayText() {
    // Verificar se a periodicidade está completa
    bool isComplete = false;

    switch (selectedFrequency) {
      case 'mensal':
      case 'bimestral':
      case 'trimestral':
        isComplete = dayOfTheMonthController.text.isNotEmpty;
        break;
      case 'quinzenal':
        isComplete = biweeklyDay1Controller.text.isNotEmpty &&
            biweeklyDay2Controller.text.isNotEmpty;
        break;
      case 'semanal':
        isComplete = selectedWeeklyWeekday != null;
        break;
      default:
        isComplete = false;
    }

    // Se não está completa, mostrar placeholder
    if (!isComplete) {
      return 'Selecione a periodicidade';
    }

    // Se está completa, mostrar texto formatado
    switch (selectedFrequency) {
      case 'mensal':
        return 'Mensal dia ${dayOfTheMonthController.text}';
      case 'bimestral':
        return 'Bimestral dia ${dayOfTheMonthController.text}';
      case 'trimestral':
        return 'Trimestral dia ${dayOfTheMonthController.text}';
      case 'quinzenal':
        return 'Quinzenal dias ${biweeklyDay1Controller.text} e ${biweeklyDay2Controller.text}';
      case 'semanal':
        const weekdays = [
          '',
          'segundas',
          'terças',
          'quartas',
          'quintas',
          'sextas',
          'sábados',
          'domingos'
        ];
        return 'Semanal todas as ${weekdays[selectedWeeklyWeekday!]}';
      default:
        return 'Selecione a periodicidade';
    }
  }

  String _frequencySummary() {
    switch (selectedFrequency) {
      case 'mensal':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Mensal no dia ${dayOfTheMonthController.text}'
            : 'Mensal (defina o dia ao tocar)';
      case 'bimestral':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Bimestral no dia ${dayOfTheMonthController.text}'
            : 'Bimestral (defina o dia ao tocar)';
      case 'trimestral':
        return dayOfTheMonthController.text.isNotEmpty
            ? 'Trimestral no dia ${dayOfTheMonthController.text}'
            : 'Trimestral (defina o dia ao tocar)';
      case 'quinzenal':
        if (biweeklyDay1Controller.text.isNotEmpty &&
            biweeklyDay2Controller.text.isNotEmpty) {
          return 'Quinzenal nos dias ${biweeklyDay1Controller.text} e ${biweeklyDay2Controller.text}';
        }
        return 'Quinzenal (defina os dias ao tocar)';
      case 'semanal':
        if (selectedWeeklyWeekday != null) {
          const weekdays = [
            '',
            'Segunda-feira',
            'Terça-feira',
            'Quarta-feira',
            'Quinta-feira',
            'Sexta-feira',
            'Sábado',
            'Domingo'
          ];
          return 'Semanal toda ${weekdays[selectedWeeklyWeekday!]}';
        }
        return 'Semanal (defina o dia ao tocar)';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.fixedAccount != null) {
      titleController.text = widget.fixedAccount!.title;
      valueController.text = widget.fixedAccount!.value;
      dayOfTheMonthController.text = widget.fixedAccount!.paymentDay;
      paymentTypeController.text = widget.fixedAccount!.paymentType ?? '';
      categoryId = widget.fixedAccount!.category;
      selectedMonth = widget.fixedAccount!.startMonth ?? DateTime.now().month;
      selectedYear = widget.fixedAccount!.startYear ?? DateTime.now().year;
      selectedFrequency = widget.fixedAccount!.frequency ?? 'mensal';
      if (widget.fixedAccount!.biweeklyDays != null &&
          widget.fixedAccount!.biweeklyDays!.isNotEmpty) {
        biweeklyDay1Controller.text =
            widget.fixedAccount!.biweeklyDays![0].toString();
        if (widget.fixedAccount!.biweeklyDays!.length > 1) {
          biweeklyDay2Controller.text =
              widget.fixedAccount!.biweeklyDays![1].toString();
        }
      }
      selectedWeeklyWeekday = widget.fixedAccount!.weeklyWeekday;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    valueController.dispose();
    dayOfTheMonthController.dispose();
    paymentTypeController.dispose();
    biweeklyDay1Controller.dispose();
    biweeklyDay2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FixedAccountsController>()) {
      Get.put(FixedAccountsController());
    }
    final FixedAccountsController fixedAccountsController =
        Get.find<FixedAccountsController>();

    final theme = Theme.of(context);
    final pageTitle =
        widget.fixedAccount == null ? 'Nova conta fixa' : 'Editar conta fixa';

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
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdsBanner(),
                        SizedBox(height: 16.h),
                        // _buildInfoCard(theme),
                        // SizedBox(height: 24.h),
                        _buildSectionTitle(theme, 'Informações básicas'),
                        SizedBox(height: 12.h),
                        _buildCardContainer(
                          theme,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(theme, 'Título'),
                              SizedBox(height: 8.h),
                              DefaultTextFieldTransaction(
                                hintText: 'Ex: aluguel, internet...',
                                controller: titleController,
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 16.h),
                              _buildFieldLabel(theme, 'Valor'),
                              SizedBox(height: 8.h),
                              TextFieldValueFixedAccotuns(
                                valueController: valueController,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionTitle(theme, 'Início'),
                        SizedBox(height: 12.h),
                        _buildMonthYearSelector(theme),
                        SizedBox(height: 24.h),
                        _buildSectionTitle(theme, 'Periodicidade'),
                        SizedBox(height: 12.h),
                        _buildFrequencySelector(theme),
                        SizedBox(height: 16.h),
                        _buildSummaryBox(theme),
                        SizedBox(height: 24.h),
                        _buildSectionTitle(theme, 'Categoria e pagamento'),
                        SizedBox(height: 12.h),
                        _buildCategoryPicker(theme),
                        SizedBox(height: 16.h),
                        _buildPaymentTypeField(theme),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
                _buildPrimaryButton(theme, fixedAccountsController),
              ],
            ),
          ),
          if (isSaving) _buildSavingOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final isEditing = widget.fixedAccount != null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.12),
            theme.primaryColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.calendar_edit,
                color: theme.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Atualize suas contas fixas'
                      : 'Planeje as contas recorrentes',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'As contas fixas entram automaticamente nas projeções, comparativos e alertas mensais.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
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

  Widget _buildFieldLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: theme.primaryColor.withOpacity(0.85),
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
        boxShadow: [],
      ),
      child: child,
    );
  }

  Widget _buildMonthYearSelector(ThemeData theme) {
    final monthNames = const [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return _buildCardContainer(
      theme,
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel(theme, 'Mês'),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16.r),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(
                          monthNames[index],
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedMonth = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel(theme, 'Ano'),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16.r),
                    items: List.generate(30, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedYear = value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme) {
    final displayText = _getFrequencyDisplayText();
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PeriodicitySelectionPage(
              initialFrequency: selectedFrequency,
              initialMonthlyDay: dayOfTheMonthController.text.isNotEmpty
                  ? dayOfTheMonthController.text
                  : null,
              initialBiweeklyDays: (biweeklyDay1Controller.text.isNotEmpty &&
                      biweeklyDay2Controller.text.isNotEmpty)
                  ? [
                      int.parse(biweeklyDay1Controller.text),
                      int.parse(biweeklyDay2Controller.text)
                    ]
                  : null,
              initialWeeklyWeekday: selectedWeeklyWeekday,
            ),
          ),
        );
        if (result is Map) {
          setState(() {
            selectedFrequency =
                result['frequency'] as String? ?? selectedFrequency;
            if (selectedFrequency == 'mensal' ||
                selectedFrequency == 'bimestral' ||
                selectedFrequency == 'trimestral') {
              dayOfTheMonthController.text =
                  (result['monthlyDay'] as String?) ?? '';
              biweeklyDay1Controller.clear();
              biweeklyDay2Controller.clear();
              selectedWeeklyWeekday = null;
            } else if (selectedFrequency == 'quinzenal') {
              final days = (result['biweeklyDays'] as List?)?.cast<int>();
              if (days != null && days.length >= 2) {
                biweeklyDay1Controller.text = days[0].toString();
                biweeklyDay2Controller.text = days[1].toString();
              }
              dayOfTheMonthController.clear();
              selectedWeeklyWeekday = null;
            } else if (selectedFrequency == 'semanal') {
              selectedWeeklyWeekday = result['weeklyWeekday'] as int?;
              dayOfTheMonthController.clear();
              biweeklyDay1Controller.clear();
              biweeklyDay2Controller.clear();
            }
          });
        }
      },
      child: _buildCardContainer(
        theme,
        Row(
          children: [
            Icon(Iconsax.repeat, color: theme.primaryColor, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: displayText == 'Selecione a periodicidade'
                      ? theme.primaryColor.withOpacity(0.5)
                      : theme.primaryColor,
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3,
                color: theme.primaryColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(ThemeData theme) {
    return _buildCardContainer(
      theme,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.document_text,
                color: theme.primaryColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo configurado',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _frequencySummary(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker(ThemeData theme) {
    return _buildCardContainer(
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(theme, 'Categoria'),
          SizedBox(height: 8.h),
          DefaultButtonSelectCategory(
            selectedCategory: categoryId,
            transactionType: TransactionType.despesa,
            onTap: (category) {
              setState(() => categoryId = category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeField(ThemeData theme) {
    return _buildCardContainer(
      theme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(theme, 'Tipo de pagamento'),
          SizedBox(height: 8.h),
          PaymentTypeField(
            controller: paymentTypeController,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
      ThemeData theme, FixedAccountsController controller) {
    final actionLabel = widget.fixedAccount == null
        ? 'Salvar conta fixa'
        : 'Atualizar conta fixa';
    final onboardingLabel = widget.fromOnboarding ? 'Criar conta fixa' : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : () => _handleSubmit(controller),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.scaffoldBackgroundColor,
            textStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: isSaving
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(widget.fixedAccount == null
                        ? 'Salvando...'
                        : 'Atualizando...'),
                  ],
                )
              : Text(onboardingLabel ?? actionLabel),
        ),
      ),
    );
  }

  Widget _buildSavingOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Salvando conta fixa...',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  bool _isFrequencyValid() {
    switch (selectedFrequency) {
      case 'mensal':
      case 'bimestral':
      case 'trimestral':
        return dayOfTheMonthController.text.isNotEmpty;
      case 'quinzenal':
        return biweeklyDay1Controller.text.isNotEmpty &&
            biweeklyDay2Controller.text.isNotEmpty;
      case 'semanal':
        return selectedWeeklyWeekday != null;
      default:
        return false;
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty ||
        valueController.text.trim().isEmpty ||
        paymentTypeController.text.trim().isEmpty ||
        categoryId == null) {
      _showError('Preencha título, valor, categoria e tipo de pagamento.');
      return false;
    }

    if (!_isFrequencyValid()) {
      _showError('Defina a periodicidade e os dias correspondentes.');
      return false;
    }

    return true;
  }

  Future<void> _handleSubmit(FixedAccountsController controller) async {
    if (isSaving) return;
    if (!_validateForm()) return;

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    final model = _buildFixedAccountModel(includeId: widget.onSave != null);

    try {
      if (widget.onSave != null) {
        widget.onSave!(model);
        if (widget.fromOnboarding) {
          Get.offAllNamed(app_routes.Routes.FIXED_SUCCESS);
        } else {
          Get.back();
        }
      } else {
        await controller
            .addFixedAccount(_buildFixedAccountModel(includeId: false));
        if (widget.fromOnboarding) {
          Get.offAllNamed(app_routes.Routes.FIXED_SUCCESS);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      }
    } catch (e) {
      _showError('Erro ao salvar conta fixa. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  FixedAccountModel _buildFixedAccountModel({bool includeId = false}) {
    List<int>? biweeklyDays;
    if (selectedFrequency == 'quinzenal' &&
        biweeklyDay1Controller.text.isNotEmpty &&
        biweeklyDay2Controller.text.isNotEmpty) {
      biweeklyDays = [
        int.parse(biweeklyDay1Controller.text),
        int.parse(biweeklyDay2Controller.text),
      ];
    }

    final paymentDay = (selectedFrequency == 'mensal' ||
            selectedFrequency == 'bimestral' ||
            selectedFrequency == 'trimestral')
        ? dayOfTheMonthController.text
        : (selectedFrequency == 'quinzenal'
            ? biweeklyDay1Controller.text
            : '1');

    return FixedAccountModel(
      id: includeId ? widget.fixedAccount?.id : null,
      title: titleController.text.trim(),
      value: valueController.text.trim(),
      category: categoryId ?? 0,
      paymentDay: paymentDay,
      paymentType: paymentTypeController.text.trim(),
      startMonth: selectedMonth,
      startYear: selectedYear,
      frequency: selectedFrequency,
      biweeklyDays: biweeklyDays,
      weeklyWeekday:
          selectedFrequency == 'semanal' ? selectedWeeklyWeekday : null,
    );
  }
}

// Formatter para limitar o número máximo
// Removed unused formatter in this page (now lives in periodicity page)
