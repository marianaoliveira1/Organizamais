// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import '../pages/fixed_accotuns_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ============================================================================
// UTILITY CLASS - Funções auxiliares
// ============================================================================
class FixedAccountUtils {
  /// Formata valores monetários para o padrão brasileiro (R$)
  static String formatCurrency(String value) {
    String cleanValue = value.replaceAll('R\$', '').trim();

    // Trata separadores de milhar e decimal
    if (cleanValue.contains('.') && cleanValue.contains(',')) {
      cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleanValue.contains(',')) {
      cleanValue = cleanValue.replaceAll(',', '.');
    }

    double parsedValue = double.tryParse(cleanValue) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return formatter.format(parsedValue);
  }

  /// Constrói o texto de agendamento de pagamento
  static String buildPaymentScheduleText(dynamic fixedAccount) {
    String baseText = _getFrequencyText(fixedAccount);
    String startDateText = _getStartDateText(fixedAccount);

    return startDateText.isEmpty ? baseText : '$baseText\n$startDateText';
  }

  static String _getFrequencyText(dynamic fixedAccount) {
    final frequency = fixedAccount.frequency;

    if (frequency == 'quinzenal' && fixedAccount.biweeklyDays?.length >= 2) {
      return "Dias ${fixedAccount.biweeklyDays[0]} e ${fixedAccount.biweeklyDays[1]} de cada mês";
    }

    if (frequency == 'semanal' && fixedAccount.weeklyWeekday != null) {
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
      return "Toda ${weekdays[fixedAccount.weeklyWeekday]}";
    }

    if (frequency == 'bimestral') {
      return "Dia ${fixedAccount.paymentDay} a cada 2 meses";
    }

    if (frequency == 'trimestral') {
      return "Dia ${fixedAccount.paymentDay} a cada 3 meses";
    }

    return "Dia ${fixedAccount.paymentDay} de cada mês";
  }

  static String _getStartDateText(dynamic fixedAccount) {
    if (fixedAccount.startMonth == null || fixedAccount.startYear == null) {
      return '';
    }

    const monthNames = [
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
    String monthName = monthNames[fixedAccount.startMonth! - 1];

    return "(desde $monthName/${fixedAccount.startYear})";
  }

  /// Calcula o valor total das contas
  static double calculateTotalValue(List<dynamic> accounts) {
    return accounts.fold(0.0, (total, account) {
      String cleanValue = account.value.replaceAll('R\$', '').trim();

      if (cleanValue.contains('.') && cleanValue.contains(',')) {
        cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleanValue.contains(',')) {
        cleanValue = cleanValue.replaceAll(',', '.');
      }

      return total + (double.tryParse(cleanValue) ?? 0);
    });
  }
}

// ============================================================================
// MAIN WIDGET - Lista de contas fixas
// ============================================================================
class FixedAccounts extends StatelessWidget {
  const FixedAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<FixedAccountsController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final isTablet = constraints.maxWidth >= 600;
        final horizontalPadding = isTablet
            ? 3.0
            : isCompact
                ? 0.0
                : 4.0;
        final verticalPadding = isTablet
            ? 3.0
            : isCompact
                ? 1.0
                : 4.0;
        final borderRadius = isTablet
            ? 12.0
            : isCompact
                ? 18.0
                : 24.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _AccountsList(controller: controller, theme: theme),
              _TotalSection(controller: controller, theme: theme),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// LISTA DE CONTAS
// ============================================================================
class _AccountsList extends StatelessWidget {
  final FixedAccountsController controller;
  final ThemeData theme;

  const _AccountsList({
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accounts = controller.fixedAccounts;

      if (accounts.isEmpty) {
        return _EmptyState();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isDeactivated = controller.isAccountDeactivated(account);

          return _AccountItem(
            account: account,
            isDeactivated: isDeactivated,
            controller: controller,
            theme: theme,
          );
        },
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Nenhuma conta fixa cadastrada",
        style: TextStyle(
          color: DefaultColors.grey20,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================================
// ITEM DE CONTA
// ============================================================================
class _AccountItem extends StatelessWidget {
  final dynamic account;
  final bool isDeactivated;
  final FixedAccountsController controller;
  final ThemeData theme;

  const _AccountItem({
    required this.account,
    required this.isDeactivated,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Opacity(
        opacity: isDeactivated ? 0.6 : 1.0,
        child: _buildSlidable(context),
      ),
    );
  }

  Widget _buildSlidable(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Slidable(
          key: ValueKey('fixed-${account.id ?? account.title}'),
          endActionPane: _buildActionPane(context),
          child: _buildContent(context),
        ),
      ),
    );
  }

  ActionPane _buildActionPane(BuildContext context) {
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.60,
      children: [
        _buildEditAction(),
        _buildDeleteAction(context),
      ],
    );
  }

  CustomSlidableAction _buildEditAction() {
    return CustomSlidableAction(
      onPressed: (_) {
        if (!isDeactivated) {
          Get.to(() => AddFixedAccountsFormPage(
                fixedAccount: account,
                onSave: (fa) => controller.updateFixedAccount(fa),
              ));
        }
      },
      backgroundColor: Colors.orange,
      flex: 1,
      child: _actionLabel('Editar'),
    );
  }

  CustomSlidableAction _buildDeleteAction(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => _showDeleteDialog(context),
      backgroundColor: Colors.red,
      flex: 1,
      child: _actionLabel('Deletar'),
    );
  }

  Widget _actionLabel(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    return InkWell(
      onTap: () {
        Slidable.of(context)?.close();
        _showActionModal(context);
      },
      child: Container(
        padding:
            EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.01),
        child: Row(
          children: [
            Expanded(
              child: _AccountInfo(
                account: account,
                isDeactivated: isDeactivated,
                theme: theme,
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: 8.w),
            _AccountValue(
                account: account, isDeactivated: isDeactivated, theme: theme),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DeleteAccountDialog(
        account: account,
        isDeactivated: isDeactivated,
        controller: controller,
        theme: theme,
      ),
    );
  }

  void _showActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ActionModal(
        account: account,
        isDeactivated: isDeactivated,
        controller: controller,
        theme: theme,
        parentContext: context,
      ),
    );
  }
}

// ============================================================================
// INFORMAÇÕES DA CONTA
// ============================================================================
class _AccountInfo extends StatelessWidget {
  final dynamic account;
  final bool isDeactivated;
  final ThemeData theme;
  final bool isTablet;

  const _AccountInfo({
    required this.account,
    required this.isDeactivated,
    required this.theme,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(isTablet),
              _buildSchedule(isTablet),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: DefaultColors.grey.withOpacity(isDeactivated ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Image.asset(
        categories_expenses.firstWhere(
          (e) => e['id'] == account.category,
        )['icon'],
        width: 19.w,
        height: 19.h,
        color: isDeactivated ? DefaultColors.grey : null,
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    final double fontSize = isTablet ? 8.sp : 14.sp;
    return Row(
      children: [
        Expanded(
          child: Text(
            account.title,
            style: TextStyle(
              color: isDeactivated ? DefaultColors.grey : theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              decoration: isDeactivated ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isDeactivated) ...[
          SizedBox(width: 6.w),
          _DeactivatedBadge(),
        ],
      ],
    );
  }

  Widget _buildSchedule(bool isTablet) {
    final scheduleText = account.deactivatedAt != null
        ? _formatDeactivationDate()
        : FixedAccountUtils.buildPaymentScheduleText(account);

    final double fontSize = isTablet ? 6.sp : 12.sp;

    return Text(
      scheduleText,
      style: TextStyle(
        color: DefaultColors.grey20,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDeactivationDate() {
    final date = account.deactivatedAt!;
    return "Desativada em ${date.day}/${date.month}/${date.year}";
  }
}

class _DeactivatedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        'DESATIVADA',
        style: TextStyle(
          color: Colors.red,
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================================
// VALOR DA CONTA
// ============================================================================
class _AccountValue extends StatelessWidget {
  final dynamic account;
  final bool isDeactivated;
  final ThemeData theme;

  const _AccountValue({
    required this.account,
    required this.isDeactivated,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final double valueFontSize = isTablet ? 8.sp : 14.sp;
    final double paymentFontSize = isTablet ? 6.sp : 12.sp;
    final maxWidth =
        MediaQuery.of(context).size.width * 0.35; // limita textos longos
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FixedAccountUtils.formatCurrency(account.value),
          style: TextStyle(
            color: isDeactivated ? DefaultColors.grey : theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
            decoration: isDeactivated ? TextDecoration.lineThrough : null,
          ),
        ),
        SizedBox(
          width: maxWidth.clamp(80.0, 140.0),
          child: Text(
            account.paymentType,
            style: TextStyle(
              color: DefaultColors.grey20,
              fontSize: paymentFontSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SEÇÃO DE TOTAL
// ============================================================================
class _TotalSection extends StatelessWidget {
  final FixedAccountsController controller;
  final ThemeData theme;

  const _TotalSection({
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final totalFontSize = isTablet ? 8.sp : 12.sp;

    return Obx(() {
      final activeAccounts = controller.fixedAccounts
          .where((a) => !controller.isAccountDeactivated(a))
          .toList();

      if (activeAccounts.isEmpty) return const SizedBox.shrink();

      final total = FixedAccountUtils.calculateTotalValue(activeAccounts);

      return Padding(
        padding: EdgeInsets.only(top: 10.h, right: 10.h),
        child: Text(
          FixedAccountUtils.formatCurrency(total.toString()),
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: totalFontSize,
          ),
        ),
      );
    });
  }
}

// ============================================================================
// MODAL DE AÇÕES
// ============================================================================
class ActionModal extends StatelessWidget {
  final dynamic account;
  final bool isDeactivated;
  final FixedAccountsController controller;
  final ThemeData theme;
  final BuildContext parentContext;

  const ActionModal({
    super.key,
    required this.account,
    required this.isDeactivated,
    required this.controller,
    required this.theme,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildTitle(),
                SizedBox(height: 20.h),
                if (!isDeactivated) ...[
                  _buildEditButton(context),
                  SizedBox(height: 12.h),
                ],
                _buildDeleteButton(context),
                SizedBox(height: 12.h),
                _buildCancelButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: DefaultColors.grey20.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      account.title,
      style: TextStyle(
        color: theme.primaryColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return _ActionButton(
      icon: Icons.edit,
      label: 'Editar',
      color: Colors.orange,
      onTap: () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (parentContext.mounted) {
            Get.to(() => AddFixedAccountsFormPage(
                  fixedAccount: account,
                  onSave: (fa) => controller.updateFixedAccount(fa),
                ));
          }
        });
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return _ActionButton(
      icon: Icons.delete,
      label: 'Deletar',
      color: Colors.red,
      onTap: () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (parentContext.mounted) {
            showDialog(
              context: parentContext,
              builder: (_) => DeleteAccountDialog(
                account: account,
                isDeactivated: isDeactivated,
                controller: controller,
                theme: theme,
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return _ActionButton(
      icon: Icons.close,
      label: 'Cancelar',
      color: DefaultColors.grey20,
      onTap: () => Navigator.pop(context),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DIALOG DE EXCLUSÃO
// ============================================================================
class DeleteAccountDialog extends StatefulWidget {
  final dynamic account;
  final bool isDeactivated;
  final FixedAccountsController controller;
  final ThemeData theme;

  const DeleteAccountDialog({
    super.key,
    required this.account,
    required this.isDeactivated,
    required this.controller,
    required this.theme,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: widget.theme.primaryColor.withOpacity(0.06)),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      title: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: (widget.isDeactivated
                      ? Colors.orange
                      : widget.theme.primaryColor)
                  .withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isDeactivated
                  ? Icons.pause_circle
                  : Icons.remove_circle_outline,
              color: widget.isDeactivated
                  ? Colors.orange
                  : widget.theme.primaryColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(child: _buildTitle()),
        ],
      ),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          widget.isDeactivated
              ? Icons.pause_circle
              : Icons.remove_circle_outline,
          color:
              widget.isDeactivated ? Colors.orange : widget.theme.primaryColor,
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            widget.isDeactivated ? 'Conta Desativada' : 'Remover Conta Fixa',
            style: TextStyle(
              color: widget.theme.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return widget.isDeactivated
        ? _DeactivatedContent(account: widget.account, theme: widget.theme)
        : _ActiveContent(account: widget.account, theme: widget.theme);
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: widget.theme.primaryColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (!widget.isDeactivated)
        TextButton(
          onPressed: _handleDisable,
          child: Text(
            'Desabilitar',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      TextButton(
        onPressed: _handleDelete,
        child: Text(
          'Excluir',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }

  Future<void> _handleDisable() async {
    await widget.controller.disableFixedAccount(widget.account.id!);
    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('Conta "${widget.account.title}" desabilitada',
          Colors.orange, Icons.pause_circle_outline);
    }
  }

  Future<void> _handleDelete() async {
    await widget.controller.deleteFixedAccount(widget.account.id!);
    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('Conta "${widget.account.title}" excluída permanentemente',
          Colors.red, Icons.delete_forever);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Conteúdo do dialog para conta ativa
class _ActiveContent extends StatelessWidget {
  final dynamic account;
  final ThemeData theme;

  const _ActiveContent({required this.account, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Como deseja remover a conta fixa "${account.title}"?',
          style: TextStyle(color: theme.primaryColor, fontSize: 13.sp),
        ),
        SizedBox(height: 16.h),
        _OptionCard(
          icon: Icons.pause_circle_outline,
          color: Colors.orange,
          text:
              'Desabilitar: A conta não aparecerá nos próximos meses, mas será mantida no histórico',
        ),
        SizedBox(height: 8.h),
        _OptionCard(
          icon: Icons.delete_forever,
          color: Colors.red,
          text: 'Excluir permanentemente: A conta será removida completamente',
        ),
      ],
    );
  }
}

// Conteúdo do dialog para conta desativada
class _DeactivatedContent extends StatelessWidget {
  final dynamic account;
  final ThemeData theme;

  const _DeactivatedContent({required this.account, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DeactivationDetails(account: account, theme: theme),
        SizedBox(height: 16.h),
        Text(
          'Esta conta está desativada e não aparece nos próximos meses. Você pode reativá-la ou excluí-la permanentemente.',
          style: TextStyle(color: theme.primaryColor, fontSize: 13.sp),
        ),
      ],
    );
  }
}

class _DeactivationDetails extends StatelessWidget {
  final dynamic account;
  final ThemeData theme;

  const _DeactivationDetails({required this.account, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'Detalhes da Desativação',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildAccountInfo(),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    final daysDeactivated = account.deactivatedAt != null
        ? DateTime.now().difference(account.deactivatedAt!).inDays
        : 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoText('Conta: ${account.title}'),
          SizedBox(height: 4.h),
          _infoText(
              'Valor: ${FixedAccountUtils.formatCurrency(account.value)}'),
          SizedBox(height: 4.h),
          _infoText(
            'Desativada em: ${_formatDate(account.deactivatedAt)}',
            color: Colors.orange.shade700,
          ),
          if (account.deactivatedAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Tempo desativada: $daysDeactivated dias',
              style: TextStyle(color: DefaultColors.grey, fontSize: 10.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoText(String text, {Color? color}) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? theme.primaryColor,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _OptionCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
