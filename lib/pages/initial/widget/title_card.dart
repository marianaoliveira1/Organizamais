// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class DefaultTitleCard extends StatelessWidget {
  final String text;
  void Function() onTap;

  DefaultTitleCard({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: DefaultColors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Icon(
            Icons.add,
            size: 14.sp,
            color: DefaultColors.grey,
          ),
        ),
      ],
    );
  }
}
