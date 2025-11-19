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

// Utilitários extraídos em classe separada
class FixedAccountUtils {
  static String formatCurrency(String value) {
    // Remove 'R$' and replace comma with dot for decimal
    String cleanValue = value.replaceAll('R\$', '').trim();

    // If the value uses '.' as thousand separator and ',' as decimal
    if (cleanValue.contains('.') && cleanValue.contains(',')) {
      // Remove thousand separator
      cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
    }
    // If the value uses ',' as decimal separator
    else if (cleanValue.contains(',')) {
      cleanValue = cleanValue.replaceAll(',', '.');
    }

    // Parse the clean value
    double parsedValue = double.tryParse(cleanValue) ?? 0;

    // Use NumberFormat to format as Brazilian Real
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return formatter.format(parsedValue);
  }

  static String buildPaymentScheduleText(dynamic fixedAccount) {
    String baseText;
    final String? frequency = fixedAccount.frequency;

    if (frequency == 'quinzenal' &&
        fixedAccount.biweeklyDays != null &&
        fixedAccount.biweeklyDays.length >= 2) {
      baseText =
          "Dias ${fixedAccount.biweeklyDays[0]} e ${fixedAccount.biweeklyDays[1]} de cada mês";
    } else if (frequency == 'semanal' && fixedAccount.weeklyWeekday != null) {
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
      final weekdayName = weekdays[fixedAccount.weeklyWeekday];
      baseText = "Toda $weekdayName";
    } else if (frequency == 'bimestral') {
      baseText = "Dia ${fixedAccount.paymentDay} a cada 2 meses";
    } else if (frequency == 'trimestral') {
      baseText = "Dia ${fixedAccount.paymentDay} a cada 3 meses";
    } else {
      baseText = "Dia ${fixedAccount.paymentDay} de cada mês";
    }

    if (fixedAccount.startMonth != null && fixedAccount.startYear != null) {
      const List<String> monthNames = [
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
      baseText += " \n(desde $monthName/${fixedAccount.startYear})";
    }

    return baseText;
  }

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

// Widget principal refatorado
class FixedAccounts extends StatelessWidget {
  const FixedAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fixedAccountsController = Get.find<FixedAccountsController>();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAccountsList(fixedAccountsController, theme),
          _buildTotalSection(fixedAccountsController, theme),
        ],
      ),
    );
  }

  Widget _buildAccountsList(
      FixedAccountsController controller, ThemeData theme) {
    return Obx(() {
      final currentFixedAccounts = controller.fixedAccounts;

      if (currentFixedAccounts.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentFixedAccounts.length,
        itemBuilder: (context, index) {
          final fixedAccount = currentFixedAccounts[index];
          final isDeactivated = controller.isAccountDeactivated(fixedAccount);

          return _buildAccountItem(
            fixedAccount: fixedAccount,
            isDeactivated: isDeactivated,
            controller: controller,
            theme: theme,
            context: context,
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
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

  Widget _buildAccountItem({
    required dynamic fixedAccount,
    required bool isDeactivated,
    required FixedAccountsController controller,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Opacity(
        opacity: isDeactivated ? 0.6 : 1.0,
        child: _buildSlidableItem(
          fixedAccount: fixedAccount,
          isDeactivated: isDeactivated,
          controller: controller,
          theme: theme,
          context: context,
        ),
      ),
    );
  }

  Widget _buildSlidableItem({
    required dynamic fixedAccount,
    required bool isDeactivated,
    required FixedAccountsController controller,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Slidable(
          key: ValueKey('fixed-${fixedAccount.id ?? fixedAccount.title}'),
          endActionPane: _buildActionPane(
            fixedAccount: fixedAccount,
            isDeactivated: isDeactivated,
            controller: controller,
            theme: theme,
            context: context,
          ),
          child: _buildAccountContent(
            fixedAccount: fixedAccount,
            isDeactivated: isDeactivated,
            theme: theme,
            controller: controller,
            context: context,
          ),
        ),
      ),
    );
  }

  ActionPane _buildActionPane({
    required dynamic fixedAccount,
    required bool isDeactivated,
    required FixedAccountsController controller,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.60,
      children: [
        _buildEditAction(fixedAccount, isDeactivated, controller),
        _buildDeleteAction(
            fixedAccount, isDeactivated, controller, theme, context),
      ],
    );
  }

  CustomSlidableAction _buildEditAction(
    dynamic fixedAccount,
    bool isDeactivated,
    FixedAccountsController controller,
  ) {
    return CustomSlidableAction(
      onPressed: (_) {
        if (!isDeactivated) {
          Get.to(
            () => AddFixedAccountsFormPage(
              fixedAccount: fixedAccount,
              onSave: (fa) => controller.updateFixedAccount(fa),
            ),
          );
        }
      },
      backgroundColor: Colors.orange,
      flex: 1,
      child: _buildActionText('Editar'),
    );
  }

  CustomSlidableAction _buildDeleteAction(
    dynamic fixedAccount,
    bool isDeactivated,
    FixedAccountsController controller,
    ThemeData theme,
    BuildContext context,
  ) {
    return CustomSlidableAction(
      onPressed: (_) async {
        await _showDeleteDialog(
          context: context,
          theme: theme,
          controller: controller,
          fixedAccount: fixedAccount,
          isDeactivated: isDeactivated,
        );
      },
      backgroundColor: Colors.red,
      flex: 1,
      child: _buildActionText('Deletar'),
    );
  }

  Widget _buildActionText(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 10.sp,
        ),
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAccountContent({
    required dynamic fixedAccount,
    required bool isDeactivated,
    required ThemeData theme,
    required FixedAccountsController controller,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        Slidable.of(context)?.close();
        _showActionModal(
          context: context,
          theme: theme,
          fixedAccount: fixedAccount,
          isDeactivated: isDeactivated,
          controller: controller,
        );
      },
      child: Container(
        padding: EdgeInsets.only(
            right: MediaQuery.of(Get.context!).size.width * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildAccountInfo(fixedAccount, isDeactivated, theme),
            ),
            SizedBox(width: 8.w),
            _buildAccountValue(fixedAccount, isDeactivated, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(
      dynamic fixedAccount, bool isDeactivated, ThemeData theme) {
    return Row(
      children: [
        _buildAccountIcon(fixedAccount, isDeactivated),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountTitle(fixedAccount, isDeactivated, theme),
              _buildAccountSchedule(fixedAccount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountIcon(dynamic fixedAccount, bool isDeactivated) {
    return Container(
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: isDeactivated
            ? DefaultColors.grey.withOpacity(0.3)
            : DefaultColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Image.asset(
        categories_expenses.firstWhere(
            (element) => element['id'] == fixedAccount.category)['icon'],
        width: 19.w,
        height: 19.h,
        color: isDeactivated ? DefaultColors.grey : null,
      ),
    );
  }

  Widget _buildAccountTitle(
      dynamic fixedAccount, bool isDeactivated, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            fixedAccount.title,
            style: TextStyle(
              color: isDeactivated ? DefaultColors.grey : theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              decoration: isDeactivated
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isDeactivated) ...[
          SizedBox(width: 6.w),
          _buildDeactivatedBadge(),
        ],
      ],
    );
  }

  Widget _buildDeactivatedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
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

  Widget _buildAccountSchedule(dynamic fixedAccount) {
    final scheduleText = fixedAccount.deactivatedAt != null
        ? "Desativada em ${fixedAccount.deactivatedAt!.day}/${fixedAccount.deactivatedAt!.month}/${fixedAccount.deactivatedAt!.year}"
        : FixedAccountUtils.buildPaymentScheduleText(fixedAccount);

    return Text(
      scheduleText,
      style: TextStyle(
        color: DefaultColors.grey20,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAccountValue(
      dynamic fixedAccount, bool isDeactivated, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FixedAccountUtils.formatCurrency(fixedAccount.value),
          style: TextStyle(
            color: isDeactivated ? DefaultColors.grey : theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            decoration: isDeactivated
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        SizedBox(
          width: 100.w,
          child: Text(
            fixedAccount.paymentType,
            style: TextStyle(
              color: DefaultColors.grey20,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection(
      FixedAccountsController controller, ThemeData theme) {
    return Obx(() {
      final currentFixedAccounts = controller.fixedAccounts;
      final activeAccounts = currentFixedAccounts
          .where((account) => !controller.isAccountDeactivated(account))
          .toList();

      if (activeAccounts.isEmpty) return const SizedBox.shrink();

      final totalValue = FixedAccountUtils.calculateTotalValue(activeAccounts);

      return Padding(
        padding: EdgeInsets.only(top: 10.h, right: 10.h),
        child: Text(
          FixedAccountUtils.formatCurrency(totalValue.toString()),
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      );
    });
  }

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required ThemeData theme,
    required FixedAccountsController controller,
    required dynamic fixedAccount,
    required bool isDeactivated,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => FixedAccountDialog(
        theme: theme,
        controller: controller,
        fixedAccount: fixedAccount,
        isDeactivated: isDeactivated,
      ),
    );
  }

  void _showActionModal({
    required BuildContext context,
    required ThemeData theme,
    required dynamic fixedAccount,
    required bool isDeactivated,
    required FixedAccountsController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: DefaultColors.grey20.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(
                    fixedAccount.title,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  if (!isDeactivated)
                    _buildActionButton(
                      context: context,
                      theme: theme,
                      icon: Icons.edit,
                      label: 'Editar',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(modalContext).pop();
                        // Usar o contexto original, não o do modal
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (context.mounted) {
                            Get.to(
                              () => AddFixedAccountsFormPage(
                                fixedAccount: fixedAccount,
                                onSave: (fa) =>
                                    controller.updateFixedAccount(fa),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  if (!isDeactivated) SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.delete,
                    label: 'Deletar',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(modalContext).pop();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          _showDeleteDialog(
                            context: context,
                            theme: theme,
                            controller: controller,
                            fixedAccount: fixedAccount,
                            isDeactivated: isDeactivated,
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    context: context,
                    theme: theme,
                    icon: Icons.close,
                    label: 'Cancelar',
                    color: DefaultColors.grey20,
                    onTap: () => Navigator.of(modalContext).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

// Dialog extraído para widget separado
class FixedAccountDialog extends StatefulWidget {
  final ThemeData theme;
  final FixedAccountsController controller;
  final dynamic fixedAccount;
  final bool isDeactivated;

  const FixedAccountDialog({
    super.key,
    required this.theme,
    required this.controller,
    required this.fixedAccount,
    required this.isDeactivated,
  });

  @override
  State<FixedAccountDialog> createState() => _FixedAccountDialogState();
}

class _FixedAccountDialogState extends State<FixedAccountDialog> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
      actions: _buildDialogActions(),
    );
  }

  Widget _buildDialogTitle() {
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

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isDeactivated)
          _buildDeactivatedContent()
        else
          _buildActiveContent(),
      ],
    );
  }

  Widget _buildDeactivatedContent() {
    return Column(
      children: [
        _buildDeactivationDetails(),
        SizedBox(height: 16.h),
        Text(
          'Esta conta está desativada e não aparece nos próximos meses. Você pode reativá-la ou excluí-la permanentemente.',
          style: TextStyle(
            color: widget.theme.primaryColor,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveContent() {
    return Column(
      children: [
        Text(
          'Como deseja remover a conta fixa "${widget.fixedAccount.title}"?',
          style: TextStyle(
            color: widget.theme.primaryColor,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 16.h),
        _buildOptionContainer(
          icon: Icons.pause_circle_outline,
          color: Colors.orange,
          text:
              'Desabilitar: A conta não aparecerá nos próximos meses, mas será mantida no histórico',
        ),
        SizedBox(height: 8.h),
        _buildOptionContainer(
          icon: Icons.delete_forever,
          color: Colors.red,
          text: 'Excluir permanentemente: A conta será removida completamente',
        ),
      ],
    );
  }

  Widget _buildDeactivationDetails() {
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
              Expanded(
                child: Text(
                  'Detalhes da Desativação',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildAccountDetails(),
        ],
      ),
    );
  }

  Widget _buildAccountDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: widget.theme.scaffoldBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Conta:', widget.fixedAccount.title),
          SizedBox(height: 4.h),
          _buildDetailRow('Valor:',
              FixedAccountUtils.formatCurrency(widget.fixedAccount.value)),
          SizedBox(height: 4.h),
          _buildDetailRow(
            'Desativada em:',
            widget.fixedAccount.deactivatedAt != null
                ? '${widget.fixedAccount.deactivatedAt!.day.toString().padLeft(2, '0')}/${widget.fixedAccount.deactivatedAt!.month.toString().padLeft(2, '0')}/${widget.fixedAccount.deactivatedAt!.year}'
                : '',
            color: Colors.orange.shade700,
          ),
          if (widget.fixedAccount.deactivatedAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Tempo desativada: ${DateTime.now().difference(widget.fixedAccount.deactivatedAt!).inDays} dias',
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 10.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Text(
      '$label $value',
      style: TextStyle(
        color: color ?? widget.theme.primaryColor,
        fontSize: 11.sp,
        fontWeight: label.contains(':') ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildOptionContainer({
    required IconData icon,
    required Color color,
    required String text,
  }) {
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
              style: TextStyle(
                color: color,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: widget.theme.primaryColor,
            fontSize: 12.sp,
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
              fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ];
  }

  Future<void> _handleDisable() async {
    await widget.controller.disableFixedAccount(widget.fixedAccount.id!);
    if (mounted) {
      Navigator.of(context).pop();
      _showSnackBar(
        icon: Icons.pause_circle_outline,
        message: 'Conta "${widget.fixedAccount.title}" desabilitada',
        color: Colors.orange,
      );
    }
  }

  Future<void> _handleDelete() async {
    await widget.controller.deleteFixedAccount(widget.fixedAccount.id!);
    if (mounted) {
      Navigator.of(context).pop();
      _showSnackBar(
        icon: Icons.delete_forever,
        message:
            'Conta "${widget.fixedAccount.title}" excluída permanentemente',
        color: Colors.red,
      );
    }
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    required Color color,
  }) {
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
