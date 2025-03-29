import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultTextGraphic extends StatelessWidget {
  final String text;
  const DefaultTextGraphic({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: theme.primaryColor,
      ),
    );
  }
}
