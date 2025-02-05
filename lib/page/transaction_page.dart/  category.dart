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
      'color': Colors.blue,
      'icon': Icons.home,
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
      'color': Colors.orange,
      'icon': Icons.directions_car,
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
      'color': Colors.green,
      'icon': Icons.restaurant,
      'subcategories': [
        'Supermercado',
        'Restaurantes',
        'Delivery',
        'Cafés e lanchonetes',
      ],
    },
    {
      'name': 'Educação',
      'color': Colors.purple,
      'icon': Icons.school,
      'subcategories': [
        'Mensalidade escolar',
        'Cursos online',
        'Livros e materiais',
        'Uniformes escolares',
      ],
    },
    {
      'name': 'Beleza e Cuidados Pessoais',
      'color': Colors.pink,
      'icon': Icons.brush,
      'subcategories': [
        'Cabeleireiro',
        'Manicure',
        'Cosméticos',
        'Academia',
      ],
    },
    {
      'name': 'Saúde',
      'color': Colors.red,
      'icon': Icons.local_hospital,
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
      appBar: AppBar(title: Text('Categorias')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            leading: Icon(category['icon'], color: category['color']),
            title: Text(category['name']),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Get.to(
                () => SubcategoriesPage(
                  categoryName: category['name'],
                  subcategories: category['subcategories'],
                ),
              );
            },
          );
        },
      ),
    );
    // return Scaffold(
    //   backgroundColor: DefaultColors.background,
    //   appBar: AppBar(
    //     backgroundColor: DefaultColors.background,
    //     title: Text('Categorias'),
    //   ),
    //   body: Padding(
    //     padding: EdgeInsets.symmetric(
    //       vertical: 20.w,
    //       horizontal: 20.h,
    //     ),
    //     child: Column(
    //       children: [
    //         Container(
    //           padding: EdgeInsets.symmetric(
    //             vertical: 20.h,
    //             horizontal: 16.w,
    //           ),
    //           decoration: BoxDecoration(
    //             color: DefaultColors.white,
    //             borderRadius: BorderRadius.circular(24.r),
    //           ),
    //           child: Row(
    //             children: [
    //               CircleAvatar(
    //                 radius: 26,
    //                 backgroundColor: DefaultColors.background,
    //                 child: Icon(
    //                   Icons.home,
    //                   color: DefaultColors.black,
    //                 ),
    //               ),
    //               SizedBox(width: 10.w),
    //               Text(
    //                 "Casa",
    //                 style: TextStyle(
    //                   fontWeight: FontWeight.bold,
    //                   fontSize: 16.sp,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
