import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
        padding: EdgeInsets.symmetric(),
        child: Row(
          children: [
            if (selectedCategoryData != null)
              Image.asset(
                selectedCategoryData['icon'],
                height: 28.h,
                width: 28.w,
              )
            else
              Icon(
                Iconsax.textalign_justifycenter,
                color: DefaultColors.grey,
              ),
            SizedBox(width: 10.w),
            Text(
              selectedCategoryData != null ? selectedCategoryData['name'] : 'Selecione uma categoria',
              style: TextStyle(
                color: DefaultColors.grey,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
