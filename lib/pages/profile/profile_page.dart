// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/auth_controller.dart';
import '../../controller/card_controller.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../controller/transaction_controller.dart';
import '../../utils/color.dart';
import '../initial/widget/edit_name_dialog.dart';
import '../../widgetes/privacy_policy_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    void _showDeleteConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: theme.primaryColor.withOpacity(0.06)),
            ),
            insetPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
            actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            title: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "Deletar conta",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              "Tem certeza que deseja deletar sua conta? Esta ação não pode ser desfeita.",
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.primaryColor.withOpacity(0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 8.w),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 8.w),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        authController.deleteAccount();
                      },
                      child: Text(
                        "Deletar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    }

    void _showEditNameDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditNameDialog(authController: authController);
        },
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.primaryColor,
            size: 18.sp,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          "Meu perfil",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 18.h),
              _buildProfileHeaderCard(
                context,
                theme,
                authController,
                _showEditNameDialog,
              ),
              SizedBox(height: 18.h),
              _buildAccountInfoCard(theme, authController),
              SizedBox(height: 18.h),
              _buildQuickStatsRow(theme),
              SizedBox(height: 24.h),
              // Text(
              //   'Preferências',
              //   style: TextStyle(
              //     fontSize: 13.sp,
              //     fontWeight: FontWeight.w600,
              //     color: theme.primaryColor,
              //   ),
              // ),
              // SizedBox(height: 12.h),
              _buildPreferencesCard(
                theme,
                onPrivacyTap: () => showPrivacyPolicyDialog(context),
                onDeleteTap: _showDeleteConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    ThemeData theme,
    AuthController authController,
    VoidCallback onEditName,
  ) {
    return Obx(() {
      final user = authController.firebaseUser.value;
      if (user == null) {
        return _buildSignedOutHeader(theme);
      }

      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final firestoreName = snapshot.data?.data()?['name'] as String?;
          final effectiveName =
              (firestoreName != null && firestoreName.trim().isNotEmpty)
                  ? firestoreName
                  : (user.displayName ?? '');
          final email = user.email ?? 'Email não disponível';

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(34.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 78.w,
                  height: 78.w,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 38.sp,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  effectiveName.isEmpty ? 'Usuário Organiza+' : effectiveName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.primaryColor.withOpacity(0.65),
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: 150.w,
                  child: TextButton.icon(
                    onPressed: onEditName,
                    style: TextButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      foregroundColor: theme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                    ),
                    icon: Icon(Icons.edit_outlined, size: 16.sp),
                    label: Text(
                      'Editar nome',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildAccountInfoCard(ThemeData theme, AuthController authController) {
    final user = authController.firebaseUser.value;
    if (user == null) return const SizedBox.shrink();

    final creationDate = user.metadata.creationTime;
    final lastLogin = user.metadata.lastSignInTime;
    final formatter = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');

    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return formatter.format(date.toLocal());
    }

    final int? daysUsing = creationDate != null
        ? DateTime.now().difference(creationDate).inDays
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da conta',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          _AccountInfoRow(
            icon: Icons.event_available_outlined,
            label: 'Criada em',
            value: formatDate(creationDate),
            theme: theme,
          ),
          SizedBox(height: 10.h),
          _AccountInfoRow(
            icon: Icons.history_toggle_off_outlined,
            label: 'Último acesso',
            value: formatDate(lastLogin),
            theme: theme,
          ),
          if (daysUsing != null) ...[
            SizedBox(height: 10.h),
            _AccountInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tempo usando o app',
              value: '$daysUsing dias',
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(ThemeData theme) {
    Widget buildRow(int categories, int cards, int fixed) {
      return Row(
        children: [
          Expanded(
            child: _QuickStatTile(
              label: 'Categorias com uso',
              value: categories,
              theme: theme,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _QuickStatTile(
              label: 'Cartões cadastrados',
              value: cards,
              theme: theme,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _QuickStatTile(
              label: 'Contas \nfixas',
              value: fixed,
              theme: theme,
            ),
          ),
        ],
      );
    }

    if (!Get.isRegistered<TransactionController>() ||
        !Get.isRegistered<CardController>() ||
        !Get.isRegistered<FixedAccountsController>()) {
      return buildRow(0, 0, 0);
    }

    final transactionController = Get.find<TransactionController>();
    final cardController = Get.find<CardController>();
    final fixedController = Get.find<FixedAccountsController>();

    return Obx(() {
      final categoryCount = transactionController.transactionRx
          .where((t) => t.category != null)
          .map((t) => t.category)
          .toSet()
          .length;
      final cardCount = cardController.card.length;
      final fixedCount = fixedController.fixedAccountsWithDeactivated.length;
      return buildRow(categoryCount, cardCount, fixedCount);
    });
  }

  Widget _buildSignedOutHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: _profileHeaderDecoration(theme),
      child: Stack(
        children: [
          ..._buildProfileBackgroundShapes(theme),
          Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalize o Organiza+',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Entre ou crie uma conta para salvar seu nome, alertas e preferências.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.75),
                  ),
                ),
                SizedBox(height: 16.h),
                _ProfileInfoChip(
                  icon: Icons.lock_outline,
                  text: 'Dados protegidos por criptografia',
                  foregroundColor: theme.primaryColor,
                  backgroundColor: theme.cardColor.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _profileHeaderDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          theme.primaryColor.withOpacity(0.2),
          theme.primaryColor.withOpacity(0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28.r),
      border: Border.all(color: theme.primaryColor.withOpacity(0.12)),
    );
  }

  List<Widget> _buildProfileBackgroundShapes(ThemeData theme) {
    return [
      Positioned(
        right: -30.w,
        top: -10.h,
        child: Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        left: -18.w,
        bottom: -28.h,
        child: Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
      ),
    ];
  }

  Widget _buildPreferencesCard(
    ThemeData theme, {
    required VoidCallback onPrivacyTap,
    required VoidCallback onDeleteTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _ProfileActionTile(
            icon: Icons.policy_outlined,
            title: 'Política de Privacidade',
            subtitle: 'Veja como cuidamos dos seus dados.',
            iconColor: theme.primaryColor,
            titleColor: theme.primaryColor,
            onTap: onPrivacyTap,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.primaryColor.withOpacity(0.06),
          ),
          _ProfileActionTile(
            icon: Icons.delete_outline,
            title: 'Deletar conta',
            subtitle: 'Remove seu perfil, histórico e configurações.',
            iconColor: Colors.redAccent,
            titleColor: Colors.redAccent,
            onTap: onDeleteTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.primaryColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.primaryColor.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.primaryColor.withOpacity(0.65),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  const _QuickStatTile({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final int value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: theme.cardColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.primaryColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoChip extends StatelessWidget {
  const _ProfileInfoChip({
    required this.icon,
    required this.text,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String text;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: foregroundColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: foregroundColor),
          SizedBox(width: 6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200.w),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
