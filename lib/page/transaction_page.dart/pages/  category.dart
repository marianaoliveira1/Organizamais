import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';

import 'sub_category.dart';

class Category extends StatelessWidget {
  Category({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Moradia e Contas Fixas',
      'color': DefaultColors.blue,
      'icon': 'assets/icon-category/home.png',
      'subcategories': [
        'Aluguel / Financiamento',
        'IPTU',
        'Água',
        'Energia elétrica',
        'Gás',
        'Internet',
        'Telefone',
        'TV a cabo / Streaming',
      ],
    },
    {
      'name': 'Transporte',
      'color': DefaultColors.orange,
      'icon': 'assets/icon-category/car.png',
      'subcategories': [
        'Combustível',
        'Transporte público',
        'Táxi / Uber',
        'Manutenção do carro',
        'Seguro do carro',
        'Pedágios e estacionamento',
      ],
    },
    {
      'name': 'Alimentação',
      'color': DefaultColors.green,
      'icon': 'assets/icon-category/food.png',
      'subcategories': [
        'Supermercado',
        'Restaurantes',
        'Delivery',
        'Cafés e lanchonetes',
      ],
    },
    {
      'name': 'Educação',
      'color': DefaultColors.purple,
      'icon': 'assets/icon-category/education.png',
      'subcategories': [
        'Mensalidade escolar',
        'Cursos online',
        'Livros e materiais',
        'Uniformes escolares',
      ],
    },
    {
      'name': 'Beleza e Cuidados Pessoais',
      'color': DefaultColors.pink,
      'icon': 'assets/icon-category/happy.png',
      'subcategories': [
        'Cabeleireiro',
        'Manicure',
        'Cosméticos',
        'Academia',
      ],
    },
    {
      'name': 'Saúde',
      'color': DefaultColors.red,
      'icon': 'assets/icon-category/emergency.png',
      'subcategories': [
        'Plano de saúde',
        'Consultas médicas',
        'Exames',
        'Medicamentos',
      ],
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
                  height: 24.h,
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
                Get.to(
                  () => SubcategoriesPage(
                    categoryName: category['name'],
                    subcategories: category['subcategories'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
