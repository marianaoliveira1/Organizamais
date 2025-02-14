import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

final List<Map<String, dynamic>> categories_expenses = [
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png'
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png'
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png'
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png'
  },
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png'
  },
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png'
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png'
  },
  {
    'id': 8,
    'name': 'Dívidas e empréstimos',
    'icon': 'assets/icon-category/dividas.png'
  },
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png'
  },
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png'
  },
  {
    'id': 11,
    'name': 'Investimentos',
    'icon': 'assets/icon-category/investimentos.png'
  },
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png'
  },
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png'
  },
  {
    'id': 14,
    'name': 'Presentes e doações',
    'icon': 'assets/icon-category/gift.png'
  },
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png'
  },
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png'
  },
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png'
  },
  {
    'id': 18,
    'name': 'Viagem',
    'icon': 'assets/icon-category/aviao.png'
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png'
  },
  {
    'id': 20,
    'name': 'Roupas',
    'icon': 'assets/icon-category/roupas.png'
  },
  {
    'id': 21,
    'name': 'iFood',
    'icon': 'assets/icon-category/ifood.png'
  },
  {
    'id': 22,
    'name': 'Uber',
    'icon': 'assets/icon-category/uber.png'
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png'
  },
  {
    'id': 24,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png'
  },
];

final List<Map<String, dynamic>> categories_income = [
  {
    'id': 1,
    'name': 'Renda',
    'icon': 'assets/icon-category/mooney.png'
  },
  {
    'id': 2,
    'name': 'Poupança',
    'icon': 'assets/icon-category/renda.png'
  },
];

class Category extends StatelessWidget {
  const Category({super.key});

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
        itemCount: categories_expenses.length,
        itemBuilder: (context, index) {
          final category = categories_expenses[index];
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
              onTap: () {
                Get.back(
                  result: category['id'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
