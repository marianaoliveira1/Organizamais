import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class Category extends StatelessWidget {
  Category({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Alimentação',
      'icon': 'assets/icon-category/food.png'
    },
    {
      'name': 'Assinaturas e serviços',
      'icon': 'assets/icon-category/cartao.png'
    },
    {
      'name': 'Bares e restaurantes',
      'icon': 'assets/icon-category/wine.png'
    },
    {
      'name': 'Moradia',
      'icon': 'assets/icon-category/home.png'
    },
    {
      'name': 'Compras',
      'icon': 'assets/icon-category/shopping.png'
    },
    {
      'name': 'Cuidados pessoais',
      'icon': 'assets/icon-category/skincare.png'
    },
    {
      'name': 'Dívidas e empréstimos',
      'icon': 'assets/icon-category/mooney.png'
    },
    {
      'name': 'Educação',
      'icon': 'assets/icon-category/education.png'
    },
    {
      'name': 'Família e filhos',
      'icon': 'assets/icon-category/family.png'
    },
    {
      'name': 'Investimentos',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Lazer e hobbies',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Pets',
      'icon': 'assets/icon-category/dog.png'
    },
    {
      'name': 'Presentes e doações',
      'icon': 'assets/icon-category/gift.png'
    },
    {
      'name': 'Saúde',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Trabalho',
      'icon': 'assets/icon-category/work.png'
    },
    {
      'name': 'Transporte',
      'icon': 'assets/icon-category/car.png'
    },
    {
      'name': 'Viagem',
      'icon': 'assets/icon-category/aviao.png'
    },
    {
      'name': 'Manutenção e reparos',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Saúde e bem-estar',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Seguros',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Outros',
      'icon': 'assets/icon-category/digital.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
        title: Text(
          'Categorias',
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 20.w,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: EdgeInsets.only(
              bottom: 10.h,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 6.w,
            ),
            decoration: BoxDecoration(
              color: DefaultColors.white,
              borderRadius: BorderRadius.circular(
                14.r,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: DefaultColors.background,
                child: Image.asset(
                  category['icon'],
                  height: 26.h,
                ),
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.black,
                ),
              ),
              // onTap: () {
              //   Get.to(
              //     () => SubcategoriesPage(
              //       categoryName: category['name'],
              //       subcategories: category['subcategories'],
              //     ),
              //   );
              // },
            ),
          );
        },
      ),
    );
  }
}
