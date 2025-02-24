// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../model/transaction_model.dart';

final List<Map<String, dynamic>> categories_expenses = [
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': DefaultColors.orange, // Comida geralmente remete a tons quentes
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': DefaultColors.navy, // Um tom mais sério, remetendo a tecnologia
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': DefaultColors.purple, // Um tom mais sofisticado e noturno
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': DefaultColors.orange, // Mesma lógica de alimentação
  },
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': DefaultColors.blue, // Estabilidade e segurança
  },
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': DefaultColors.teal, // Uma cor vibrante que remete a consumo
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': DefaultColors.pink, // Associado a bem-estar e beleza
  },
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': DefaultColors.purple, // Conhecimento e criatividade
  },
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': DefaultColors.green, // Crescimento e harmonia
  },
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': DefaultColors.teal, // Algo mais descontraído e versátil
  },
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': DefaultColors.orange, // Cor vibrante e amigável
  },
  {
    'id': 14,
    'name': 'Presentes e doações',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.red, // Paixão e generosidade
  },
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': DefaultColors.brightRed, // Urgência e vitalidade
  },
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': DefaultColors.darkBlue, // Profissionalismo e seriedade
  },
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': DefaultColors.darkGrey, // Remete a asfalto e veículos
  },
  {
    'id': 18,
    'name': 'Viagem',
    'icon': 'assets/icon-category/aviao.png',
    'color': DefaultColors.blue, // Céu, liberdade e aventura
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': DefaultColors.grey, // Algo mais neutro e técnico
  },
  {
    'id': 20,
    'name': 'Roupas',
    'icon': 'assets/icon-category/roupas.png',
    'color': DefaultColors.pink, // Moda e estilo
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/delivery-bike.png',
    'color': DefaultColors.orange, // Remete a comida rápida
  },
  {
    'id': 22,
    'name': 'Uber',
    'icon': 'assets/icon-category/uber.png',
    'color': DefaultColors.darkGrey, // Tecnologia e mobilidade
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': DefaultColors.brightRed, // Tecnologia e entretenimento
  },
  {
    'id': 24,
    'name': 'Farmacia',
    'icon': 'assets/icon-category/farmacia.png',
    'color': DefaultColors.orangeDark, // Categoria genérica e neutra
  },
  {
    'id': 25,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.grey, // Categoria genérica e neutra
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

final List<Map<String, dynamic>> all_categories = [
  ...categories_expenses,
  ...categories_income
];

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
  final TransactionType? transactionType;

  const Category({
    super.key,
    this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Escolher lista baseada no tipo, se não especificado usa expenses como padrão
    final categoriesList = transactionType == TransactionType.receita ? categories_income : categories_expenses;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Categorias',
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 20.w,
        ),
        itemCount: categoriesList.length,
        itemBuilder: (context, index) {
          final category = categoriesList[index];
          return Container(
            margin: EdgeInsets.only(
              bottom: 10.h,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 6.w,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(
                14.r,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: DefaultColors.grey.withOpacity(
                  .3,
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    8.h,
                  ),
                  child: Image.asset(
                    category['icon'],
                    height: 26.h,
                  ),
                ),
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
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
