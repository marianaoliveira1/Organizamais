import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/snackbar_helper.dart'; // Import added

class ButtonBackTransaction extends StatelessWidget {
  const ButtonBackTransaction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Fechar qualquer snackbar aberto de forma segura
        SnackbarHelper.closeAllSnackbars();
        Navigator.of(context).pop();
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
