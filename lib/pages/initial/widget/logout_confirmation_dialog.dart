import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final AuthController authController;
  const LogoutConfirmationDialog({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: theme.primaryColor.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.error.withOpacity(.12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Deseja sair?',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Você poderá acessar novamente quando quiser usando seu e-mail e senha.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (Get.isSnackbarOpen == true) {
                        Get.closeCurrentSnackbar();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(
                          color: theme.primaryColor.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Get.isSnackbarOpen == true) {
                        Get.closeCurrentSnackbar();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      await authController.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        'Sair agora',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.cardColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
