import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryValue extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const CategoryValue({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barrinha colorida à esquerda
        Container(
          height: 44.h,
          width: 2.w,
          color: color,
        ),
        SizedBox(width: 8.w),
        // Título e valor
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da categoria
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            // Valor da categoria
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
