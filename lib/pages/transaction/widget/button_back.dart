import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ButtonBackTransaction extends StatelessWidget {
  const ButtonBackTransaction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Fechar qualquer snackbar aberto antes de navegar
        // para evitar LateInitializationError
        try {
          if (Get.isSnackbarOpen == true) {
            Get.closeCurrentSnackbar();
            // Aguardar o snackbar fechar antes de navegar
            Future.delayed(const Duration(milliseconds: 200), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          } else {
            // Se não há snackbar, navegar diretamente
            Navigator.of(context).pop();
          }
        } catch (e) {
          // Se houver erro, tentar navegar diretamente
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: theme.primaryColor,
            width: 1.w,
          ),
        ),
        child: Center(
          child: Text(
            "Cancelar",
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
