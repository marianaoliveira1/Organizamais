import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class DefaultTitleTransaction extends StatelessWidget {
  final String title;

  const DefaultTitleTransaction({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: DefaultColors.grey20,
          ),
        ),
      ],
    );
  }
}
