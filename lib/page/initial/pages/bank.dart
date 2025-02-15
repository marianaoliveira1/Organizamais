// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

final List<Map<String, dynamic>> banks = [
  {
    'id': 1,
    'name': 'ABC Brasil',
    'icon': 'assets/icon-bank/abc-brasil.png'
  },
  {
    'id': 2,
    'name': 'Agi',
    'icon': 'assets/icon-bank/agi.png'
  },
  {
    'id': 3,
    'name': 'Amazon Pay',
    'icon': 'assets/icon-bank/amazon-pay.png'
  },
  {
    'id': 4,
    'name': 'American Express',
    'icon': 'assets/icon-bank/american-express.png'
  },
  {
    'id': 5,
    'name': 'Avenue',
    'icon': 'assets/icon-bank/avenue.png'
  },
  {
    'id': 6,
    'name': 'Banco Agora',
    'icon': 'assets/icon-bank/banco-agora.png'
  },
  {
    'id': 7,
    'name': 'Banco Alfa',
    'icon': 'assets/icon-bank/banco-alfa.png'
  },
  {
    'id': 8,
    'name': 'Banco da Amazônia',
    'icon': 'assets/icon-bank/banco-da-amazonia.png'
  },
  {
    'id': 9,
    'name': 'Banco Daycoval',
    'icon': 'assets/icon-bank/banco-daycoval.png'
  },
  {
    'id': 10,
    'name': 'Banco do Brasil',
    'icon': 'assets/icon-bank/banco-do-brasil.png'
  },
  {
    'id': 11,
    'name': 'Banco do Nordeste',
    'icon': 'assets/icon-bank/banco-do-nordeste.png'
  },
  {
    'id': 12,
    'name': 'Banco Mercantil',
    'icon': 'assets/icon-bank/banco-mercantil.png'
  },
  {
    'id': 13,
    'name': 'Banco Modalmais',
    'icon': 'assets/icon-bank/banco-modalmais.png'
  },
  {
    'id': 14,
    'name': 'Banco Pan',
    'icon': 'assets/icon-bank/banco-pan.png'
  },
  {
    'id': 15,
    'name': 'Banese',
    'icon': 'assets/icon-bank/banese.png'
  },
  {
    'id': 16,
    'name': 'Banestes',
    'icon': 'assets/icon-bank/banestes.png'
  },
  {
    'id': 17,
    'name': 'Banpará',
    'icon': 'assets/icon-bank/banpara.png'
  },
  {
    'id': 18,
    'name': 'Banrisul',
    'icon': 'assets/icon-bank/banrisul.png'
  },
  {
    'id': 19,
    'name': 'Bari',
    'icon': 'assets/icon-bank/bari.png'
  },
  {
    'id': 20,
    'name': 'BDMG',
    'icon': 'assets/icon-bank/bdmg.png'
  },
  {
    'id': 21,
    'name': 'BIB',
    'icon': 'assets/icon-bank/bib.png'
  },
  {
    'id': 22,
    'name': 'BMG',
    'icon': 'assets/icon-bank/bmg.png'
  },
  {
    'id': 23,
    'name': 'BNDES',
    'icon': 'assets/icon-bank/bndes.png'
  },
  {
    'id': 24,
    'name': 'Bradesco',
    'icon': 'assets/icon-bank/bradesco.png'
  },
  {
    'id': 25,
    'name': 'BRB',
    'icon': 'assets/icon-bank/brb.png'
  },
  {
    'id': 26,
    'name': 'BRDE',
    'icon': 'assets/icon-bank/brde.png'
  },
  {
    'id': 27,
    'name': 'BS2',
    'icon': 'assets/icon-bank/bs2.png'
  },
  {
    'id': 28,
    'name': 'BTG',
    'icon': 'assets/icon-bank/btg.png'
  },
  {
    'id': 29,
    'name': 'BV',
    'icon': 'assets/icon-bank/bv.png'
  },
  {
    'id': 30,
    'name': 'C6 Bank',
    'icon': 'assets/icon-bank/c6.png'
  },
  {
    'id': 31,
    'name': 'Caixa',
    'icon': 'assets/icon-bank/caixa.png'
  },
  {
    'id': 32,
    'name': 'Citi',
    'icon': 'assets/icon-bank/citi.png'
  },
  {
    'id': 33,
    'name': 'Clear Corretora',
    'icon': 'assets/icon-bank/clear-corretora.png'
  },
  {
    'id': 34,
    'name': 'Cresol',
    'icon': 'assets/icon-bank/cresol.png'
  },
  {
    'id': 35,
    'name': 'Digi+',
    'icon': 'assets/icon-bank/digi+.png'
  },
  {
    'id': 36,
    'name': 'Digio',
    'icon': 'assets/icon-bank/digio.png'
  },
  {
    'id': 37,
    'name': 'HSBC',
    'icon': 'assets/icon-bank/hsbc.png'
  },
  {
    'id': 38,
    'name': 'Inter',
    'icon': 'assets/icon-bank/inter.png'
  },
  {
    'id': 39,
    'name': 'Itaú',
    'icon': 'assets/icon-bank/itau.png'
  },
  {
    'id': 40,
    'name': 'Nubank',
    'icon': 'assets/icon-bank/nubank.png'
  },
  {
    'id': 41,
    'name': 'Santander',
    'icon': 'assets/icon-bank/santander.png'
  },
  {
    'id': 42,
    'name': 'Sicoob',
    'icon': 'assets/icon-bank/sicoob.png'
  },
  {
    'id': 43,
    'name': 'Sicredi',
    'icon': 'assets/icon-bank/sicredi.png'
  },
  {
    'id': 44,
    'name': 'Stone',
    'icon': 'assets/icon-bank/stone.png'
  },
  {
    'id': 45,
    'name': 'XP Investimentos',
    'icon': 'assets/icon-bank/xp.png'
  }
];

class BankSearchWidget extends StatelessWidget {
  BankSearchWidget({super.key});

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 20.w,
        ),
        itemCount: banks.length,
        itemBuilder: (context, index) {
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
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(
                  20.r,
                ),
                child: Image.asset(
                  banks[index]['icon'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                banks[index]['name']!,
              ),
              onTap: () {
                Navigator.pop(context, banks[index]['id']);
              },
            ),
          );
        },
      ),
    );
  }
}
