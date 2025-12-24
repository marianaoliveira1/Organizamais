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
    final mediaQuery = MediaQuery.of(context);
    final bool isTablet = mediaQuery.size.width >= 600;
    final double titleFontSize = isTablet ? 8.sp : 12.sp;
    final double iconSize = isTablet ? 12.sp : 16.sp;
    final double verticalPadding = isTablet ? 8.h : 12.h;
    final double horizontalPadding = isTablet ? 10.w : 14.w;
    final double spacing = isTablet ? 6.h : 8.h;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                color: DefaultColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon != null)
              GestureDetector(
                onTap: onIconTap ?? onTap,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: DefaultColors.textGrey,
                ),
              )
          ],
        ),
        SizedBox(height: spacing), // ← Espaçamento adicionado
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
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
