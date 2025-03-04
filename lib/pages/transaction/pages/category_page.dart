// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../model/transaction_model.dart';

final List<Map<String, dynamic>> categories_expenses = [
  // Categorias relacionadas a CASA
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': DefaultColors.blue,
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': DefaultColors.grey,
  },
  {
    'id': 26,
    'name': 'Contas (água, luz, gás, internet)',
    'icon': 'assets/icon-category/contas.png',
    'color': DefaultColors.lightBlue,
  },
  // {
  //   'id': 27,
  //   'name': 'Aluguel/Prestação da Casa',
  //   'icon': 'assets/icon-category/energia.png',
  //   'color': DefaultColors.yellow,
  // },
  {
    'id': 29,
    'name': 'Mercado',
    'icon': 'assets/icon-category/mercado.png',
    'color': DefaultColors.deepOrange,
  },

  // Categorias relacionadas a CARRO
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': DefaultColors.darkGrey,
  },
  {
    'id': 22,
    'name': 'Uber',
    'icon': 'assets/icon-category/uber.png',
    'color': DefaultColors.darkGrey,
  },
  {
    'id': 28,
    'name': 'Combustivel',
    'icon': 'assets/icon-category/combustivel.png',
    'color': DefaultColors.brown,
  },

  {
    'id': 32,
    'name': 'Seguro do Carro',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.darkBlue,
  },
  {
    'id': 33,
    'name': 'Multas',
    'icon': 'assets/icon-category/multas.png',
    'color': DefaultColors.brightRed,
  },

  // Outras categorias
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': DefaultColors.orange,
  },
  {
    'id': 31,
    'name': 'Lanches',
    'icon': 'assets/icon-category/lanches.png',
    'color': DefaultColors.darkGrey,
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': DefaultColors.navy,
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': DefaultColors.purple,
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': DefaultColors.orange,
  },
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': DefaultColors.teal,
  },
  {
    'id': 34,
    'name': 'Roupas de acessórios',
    'icon': 'assets/icon-category/roupas-e-calcados.png',
    'color': DefaultColors.emerald,
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': DefaultColors.pink,
  },
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': DefaultColors.purple,
  },
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': DefaultColors.green,
  },
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': DefaultColors.teal,
  },
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': DefaultColors.orange,
  },
  {
    'id': 14,
    'name': 'Presentes e doações',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.red,
  },
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': DefaultColors.brightRed,
  },
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': DefaultColors.darkBlue,
  },
  {
    'id': 18,
    'name': 'Viagem',
    'icon': 'assets/icon-category/aviao.png',
    'color': DefaultColors.blue,
  },
  {
    'id': 20,
    'name': 'Vestuario',
    'icon': 'assets/icon-category/roupas.png',
    'color': DefaultColors.pink,
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/delivery-bike.png',
    'color': DefaultColors.orange,
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': DefaultColors.brightRed,
  },
  {
    'id': 24,
    'name': 'Farmacia',
    'icon': 'assets/icon-category/farmacia.png',
    'color': DefaultColors.orangeDark,
  },
  {
    'id': 25,
    'name': 'Academia',
    'icon': 'assets/icon-category/academia.png',
    'color': DefaultColors.cyan,
  },

  {
    'id': 35,
    'name': 'Impostos',
    'icon': 'assets/icon-category/impostos.png',
    'color': DefaultColors.navy,
  },
  {
    'id': 36,
    'name': 'Plano de Saúde/Seguro de vida',
    'icon': 'assets/icon-category/planodesaude.png',
    'color': DefaultColors.lavender,
  },
  {
    'id': 37,
    'name': 'Financiamento',
    'icon': 'assets/icon-category/financiamentos.png',
    'color': DefaultColors.turquoise,
  },
  {
    'id': 38,
    'name': 'Empréstimos',
    'icon': 'assets/icon-category/emprestimos.png',
    'color': DefaultColors.indigo,
  },

  // {
  //   'id': 40,
  //   'name': 'Consultoria',
  //   'icon': 'assets/icon-category/consulting.png',
  //   'color': DefaultColors.darkBlue,
  // },
  {
    'id': 61,
    'name': 'Passagens',
    'icon': 'assets/icon-category/passagens.png',
    'color': DefaultColors.darkBlue,
  },
  {
    'id': 62,
    'name': 'Hoteis',
    'icon': 'assets/icon-category/hoteis.png',
    'color': DefaultColors.darkBlue,
  },
  {
    'id': 63,
    'name': 'Alimentação em Viagens',
    'icon': 'assets/icon-category/travel-food.png',
    'color': DefaultColors.blue,
  },
  {
    'id': 64,
    'name': 'Passeios',
    'icon': 'assets/icon-category/tour.png',
    'color': DefaultColors.orange,
  },
  {
    'id': 65,
    'name': 'Coisas para Casa',
    'icon': 'assets/icon-category/home-stuff.png',
    'color': DefaultColors.brown,
  },
  {
    'id': 66,
    'name': 'Emergência',
    'icon': 'assets/icon-category/emergency.png',
    'color': DefaultColors.brightRed,
  },
  {
    'id': 67,
    'name': 'Aplicativos',
    'icon': 'assets/icon-category/apps.png',
    'color': DefaultColors.purple,
  },
  {
    'id': 68,
    'name': 'Jogos Online',
    'icon': 'assets/icon-category/gaming.png',
    'color': DefaultColors.yellow,
  },
  {
    'id': 69,
    'name': 'Consultas e Tratamentos',
    'icon': 'assets/icon-category/medical.png',
    'color': DefaultColors.green,
  },
  {
    'id': 70,
    'name': 'Bem-estar (Spa, Terapia)',
    'icon': 'assets/icon-category/spa.png',
    'color': DefaultColors.lavender,
  },
  {
    'id': 71,
    'name': 'Estacionamento e Pedágios',
    'icon': 'assets/icon-category/toll.png',
    'color': DefaultColors.darkGrey,
  },
  {
    'id': 30,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.grey,
  },
];

final List<Map<String, dynamic>> categories_income = [
  // Outras categorias de receitas
  {
    'id': 50,
    'name': 'Salário',
    'icon': 'assets/icon-category/mooney.png',
    'color': Colors.green,
  },
  {
    'id': 51,
    'name': 'Poupança',
    'icon': 'assets/icon-category/renda.png',
    'color': Colors.blue,
  },
  {
    'id': 52,
    'name': 'Bonificação',
    'icon': 'assets/icon-category/bonus.png',
    'color': Colors.blue,
  },
  {
    'id': 53,
    'name': 'Renda extra',
    'icon': 'assets/icon-category/income.png',
    'color': Colors.blue,
  },
  {
    'id': 54,
    'name': 'Transfrencia bancária',
    'icon': 'assets/icon-category/transfer.png',
    'color': Colors.blue,
  },

  {
    'id': 58,
    'name': 'Freelance',
    'icon': 'assets/icon-category/freelancer.png',
    'color': DefaultColors.teal,
  },
  {
    'id': 59,
    'name': 'Indenização',
    'icon': 'assets/icon-category/indenização.png',
    'color': DefaultColors.lavender,
  },
  {
    'id': 60,
    'name': 'Prêmios',
    'icon': 'assets/icon-category/premios.png',
    'color': DefaultColors.peach,
  },
  {
    'id': 55,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.grey,
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
                  .1,
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
