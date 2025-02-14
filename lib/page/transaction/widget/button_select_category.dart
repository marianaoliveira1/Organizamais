import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/color.dart';
import '../pages/  category.dart';

class DefaultButtonSelectCategory extends StatelessWidget {
  const DefaultButtonSelectCategory({
    super.key,
    required this.onTap,
    required this.selectedCategory,
  });

  final Function(int?) onTap;
  final int? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var category = await Get.to(() => Category());
        onTap(category as int?);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.h,
          vertical: 15.h,
        ),
        decoration: BoxDecoration(
          color: DefaultColors.greyLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.category, color: DefaultColors.grey),
            SizedBox(width: 10.w),
            Text(
              selectedCategory != null ? 'Categoria $selectedCategory' : 'Selecione uma categoria',
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 16.sp,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: DefaultColors.grey, size: 20.w),
          ],
        ),
      ),
    );
  }
}
