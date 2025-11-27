import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PaymentOption extends StatelessWidget {
  final String title;
  final String assetPath;
  final TextEditingController controller;

  const PaymentOption({
    super.key,
    required this.title,
    required this.assetPath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        color: theme.cardColor,
      ),
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 28.w,
          height: 28.h,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          // Retorna o título e o caminho do ícone para que o chamador possa exibir ambos
          // Fechar qualquer snackbar aberto antes de navegar
          try {
            if (Get.isSnackbarOpen == true) {
              Get.closeCurrentSnackbar();
              Future.delayed(const Duration(milliseconds: 200), () {
                if (context.mounted) {
                  Navigator.of(context).pop({
                    'title': title,
                    'assetPath': assetPath,
                  });
                }
              });
            } else {
              Navigator.of(context).pop({
                'title': title,
                'assetPath': assetPath,
              });
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop({
                'title': title,
                'assetPath': assetPath,
              });
            }
          }
        },
      ),
    );
  }
}
