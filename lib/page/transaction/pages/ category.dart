import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

final List<Map<String, dynamic>> categories_expenses = [
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': Colors.red
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': Colors.blue
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': Colors.green
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': Colors.yellow
  },
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': Colors.orange
  },
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': Colors.purple
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': Colors.pink
  },
  {
    'id': 8,
    'name': 'Dívidas e empréstimos',
    'icon': 'assets/icon-category/dividas.png',
    'color': Colors.red
  },
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': Colors.blue
  },
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': Colors.green
  },
  {
    'id': 11,
    'name': 'Investimentos',
    'icon': 'assets/icon-category/investimentos.png',
    'color': Colors.yellow
  },
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': Colors.purple
  },
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': Colors.pink
  },
  {
    'id': 14,
    'name': 'Presentes e doações',
    'icon': 'assets/icon-category/gift.png',
    'color': Colors.red
  },
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': Colors.blue
  },
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': Colors.green
  },
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': Colors.yellow
  },
  {
    'id': 18,
    'name': 'Viagem',
    'icon': 'assets/icon-category/aviao.png',
    'color': Colors.purple
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': Colors.red
  },
  {
    'id': 20,
    'name': 'Roupas',
    'icon': 'assets/icon-category/roupas.png',
    'color': Colors.blue
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/ifood.png',
    'color': Colors.green
  },
  {
    'id': 22,
    'name': 'Uber',
    'icon': 'assets/icon-category/uber.png',
    'color': Colors.yellow
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': Colors.purple
  },
  {
    'id': 24,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': Colors.red
  },
];

final List<Map<String, dynamic>> categories_income = [
  {
    'id': 25,
    'name': 'Renda',
    'icon': 'assets/icon-category/mooney.png',
    'color': Colors.green
  },
  {
    'id': 26,
    'name': 'Poupança',
    'icon': 'assets/icon-category/renda.png',
    'color': Colors.blue
  },
];

final List<Map<String, dynamic>> all_categories = [...categories_expenses, ...categories_income];

  Map<String, dynamic>? findCategoryById(int? id) {
    if (id == null) return null;

    final expenseCategory = categories_expenses.firstWhere(
      (category) => category['id'] == id,
      orElse: () => {
        'id': 0,
        'name': '',
        'icon': ''
      },
    );
    if (expenseCategory['id'] != 0) return expenseCategory;

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
