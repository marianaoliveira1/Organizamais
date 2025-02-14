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

  Map<String, dynamic>? _findCategoryById(int? id) {
    if (id == null) return null;

    // First search in expenses categories
    final expenseCategory = categories_expenses.firstWhere(
      (category) => category['id'] == id,
      orElse: () => {
        'id': 0,
        'name': '',
        'icon': ''
      },
    );
    if (expenseCategory['id'] != 0) return expenseCategory;

    // If not found in expenses, search in income categories
    final incomeCategory = categories_income.firstWhere(
      (category) => category['id'] == id,
      orElse: () => {
        'id': 0,
        'name': '',
        'icon': ''
      },
    );
    if (incomeCategory['id'] != 0) return incomeCategory;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryData = _findCategoryById(selectedCategory);

    return InkWell(
      onTap: () async {
        var categoryId = await Get.to(() => const Category());
        onTap(categoryId as int?);
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
            if (selectedCategoryData != null)
              Image.asset(
                selectedCategoryData['icon'],
                height: 24.h,
                width: 24.w,
              )
            else
              Icon(Icons.category, color: DefaultColors.grey),
            SizedBox(width: 10.w),
            Text(
              selectedCategoryData != null ? selectedCategoryData['name'] : 'Selecione uma categoria',
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: DefaultColors.grey, size: 20.w),
          ],
        ),
      ),
    );
  }
}
