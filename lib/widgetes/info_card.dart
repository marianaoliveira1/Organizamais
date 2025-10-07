// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget content;
  final void Function()? onTap; // ← Adicionar 'final' aqui
  final void Function()? onIconTap;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    this.onIconTap,
    required this.content,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: DefaultColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon != null)
              GestureDetector(
                onTap: onIconTap ?? onTap,
                child: Icon(
                  icon,
                  size: 14.sp,
                  color: DefaultColors.textGrey,
                ),
              )
          ],
        ),
        SizedBox(height: 8.h), // ← Espaçamento adicionado
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 14.w,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: content,
          ),
        )
      ],
    );
  }
}
