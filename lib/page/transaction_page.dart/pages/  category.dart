import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class Category extends StatelessWidget {
  Category({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Alimentação',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Assinaturas e serviços',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Bares e restaurantes',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Casa',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Compras',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Cuidados pessoais',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Dívidas e empréstimos',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Educação',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Família e filhos',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Impostos e Taxas',
      'icon': 'assets/icon-category/digital.png'
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
      'name': 'Mercado',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Outros',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Pets',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Presentes e doações',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Roupas',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Saúde',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Trabalho',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Transporte',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Viagem',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Tecnologia e Comunicação',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Manutenção e reparos',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Moradia',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Poupança',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Renda',
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
      'name': 'Serviços financeiros e bancários',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Streaming',
      'icon': 'assets/icon-category/digital.png'
    },
    {
      'name': 'Transferências e pagamentos',
      'icon': 'assets/icon-category/digital.png'
    },
  ];

  // final List<Map<String, dynamic>> categories = [
  //   {
  //     'name': 'Alimentação',
  //     'color': DefaultColors.green,
  //     'icon': 'assets/icon-category/food.png',
  //     'subcategories': [
  //       'Supermercado',
  //       'Restaurantes',
  //       'Delivery',
  //       'Cafés e lanchonetes',
  //     ],
  //   },
  //   {
  //     'name': 'Moradia e Contas Fixas',
  //     'color': DefaultColors.blue,
  //     'icon': 'assets/icon-category/home.png',
  //     'subcategories': [
  //       'Aluguel / Financiamento',
  //       'IPTU',
  //       'Água',
  //       'Energia elétrica',
  //       'Gás',
  //       'Internet',
  //       'Telefone',
  //       'TV a cabo / Streaming',
  //     ],
  //   },
  //   {
  //     'name': 'Transporte',
  //     'color': DefaultColors.orange,
  //     'icon': 'assets/icon-category/car.png',
  //     'subcategories': [
  //       'Combustível',
  //       'Transporte público',
  //       'Táxi / Uber',
  //       'Manutenção do carro',
  //       'Seguro do carro',
  //       'Pedágios e estacionamento',
  //     ],
  //   },
  //   {
  //     'name': 'Educação',
  //     'color': DefaultColors.purple,
  //     'icon': 'assets/icon-category/education.png',
  //     'subcategories': [
  //       'Mensalidade escolar',
  //       'Cursos online',
  //       'Livros e materiais',
  //       'Uniformes escolares',
  //     ],
  //   },
  //   {
  //     'name': 'Compras e Lazer',
  //     'color': DefaultColors.pink,
  //     'icon': 'assets/icon-category/shopping.png',
  //     'subcategories': [
  //       'Roupas e acessórios',
  //       'Eletrônicos',
  //       'Salão de beleza / Barbearia',
  //       'Manicure',
  //       'Cosméticos',
  //       'Academia',
  //       'Cinema e teatro',
  //       'Passeios e viagens',
  //     ],
  //   },
  //   {
  //     'name': 'Saúde',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Plano de saúde',
  //       'Consultas médicas',
  //       'Exames',
  //       'Medicamentos',
  //       'Terapia / Psicólogo',
  //       'Odontologia',
  //     ],
  //   },
  //   {
  //     'name': 'Beleza e Cuidados Pessoais',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/shopping.png',
  //     'subcategories': [
  //       'Salão de beleza',
  //       'Produtos de beleza',
  //       'Perfumes',
  //       'Academia',
  //       'Suplementos',
  //     ],
  //   },
  //   {
  //     'name': 'Tecnologia e Comunicação',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/digital.png',
  //     'subcategories': [
  //       'Celular (plano)',
  //       'Internet',
  //       'Assinaturas de software',
  //       'Hardware e acessórios',
  //     ],
  //   },
  //   {
  //     'name': 'Investimentos',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/mooney.png',
  //     'subcategories': [
  //       'Ações e Bolsa de Valores',
  //       'Fundos Imobiliários',
  //       'CDB, LCI, LCA',
  //       'Previdência privada',
  //       'Criptomoedas',
  //     ],
  //   },
  //   {
  //     'name': 'Dívidas e Empréstimos',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Parcelas de empréstimos',
  //       'Cartão de crédito',
  //       'Financiamentos',
  //       'Cheque especial',
  //     ],
  //   },
  //   {
  //     'name': 'Impostos e Taxas',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'IRPF',
  //       'Multas e taxas bancárias',
  //       'IPVA',
  //       'INSS',
  //     ],
  //   },
  //   {
  //     'name': 'Pets',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Ração e petiscos',
  //       'Veterinário',
  //       'Banho e tosa',
  //       'Acessórios',
  //     ],
  //   },
  //   {
  //     'name': 'Presentes e Doações',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Aniversários',
  //       'Casamentos',
  //       'Doações para ONGs',
  //       'Presentes para amigos e familiares',
  //     ],
  //   },
  //   {
  //     'name': 'Casa e Decoração',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Móveis',
  //       'Eletrodomésticos',
  //       'Decoração',
  //       'Ferramentas',
  //     ],
  //   },
  //   {
  //     'name': 'Serviços e Assinaturas',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Netflix, Spotify, Amazon',
  //       'Serviços de streaming',
  //       'Softwares (Adobe, Office, etc.)',
  //     ],
  //   },
  //   {
  //     'name': 'Trabalho e Negócios',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Cursos profissionais',
  //       'Material de trabalho',
  //       'Hospedagem de sites',
  //     ],
  //   },
  //   {
  //     'name': 'Seguros',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Seguro de vida',
  //       'Seguro do carro',
  //       'Seguro da casa',
  //       'Seguro saúde',
  //     ],
  //   },
  //   {
  //     'name': 'Viagens',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Passagens',
  //       'Hospedagem',
  //       'Passeios',
  //       'Alimentação',
  //     ],
  //   },
  //   {
  //     'name': 'Filhos e Família',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Escolas e creches',
  //       'Brinquedos',
  //       'Mesada',
  //       'Cuidados infantis',
  //     ],
  //   },
  //   {
  //     'name': 'Outros',
  //     'color': DefaultColors.red,
  //     'icon': 'assets/icon-category/emergency.png',
  //     'subcategories': [
  //       'Gastos inesperados',
  //       'Outras compras',
  //       'Taxas diversas',
  //     ],
  //   },
  // ];

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
                  height: 16.h,
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
