// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:organizamais/utils/color.dart';

class BankSearchPage extends StatefulWidget {
  const BankSearchPage({super.key});

  @override
  _BankSearchPageState createState() => _BankSearchPageState();
}

class _BankSearchPageState extends State<BankSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> banks = [
    {
      'name': 'ABC Brasil',
      'icon': 'assets/icon-bank/abc-brasil.png'
    },
    {
      'name': 'Agi',
      'icon': 'assets/icon-bank/agi.png'
    },
    {
      'name': 'Amazon Pay',
      'icon': 'assets/icon-bank/amazon-pay.png'
    },
    {
      'name': 'American Express',
      'icon': 'assets/icon-bank/american-express.png'
    },
    {
      'name': 'Avenue',
      'icon': 'assets/icon-bank/avenue.png'
    },
    {
      'name': 'Banco Agora',
      'icon': 'assets/icon-bank/banco-agora.png'
    },
    {
      'name': 'Banco Alfa',
      'icon': 'assets/icon-bank/banco-alfa.png'
    },
    {
      'name': 'Banco da Amazônia',
      'icon': 'assets/icon-bank/banco-da-amazonia.png'
    },
    {
      'name': 'Banco Daycoval',
      'icon': 'assets/icon-bank/banco-daycoval.png'
    },
    {
      'name': 'Banco do Brasil',
      'icon': 'assets/icon-bank/banco-do-brasil.png'
    },
    {
      'name': 'Banco do Nordeste',
      'icon': 'assets/icon-bank/banco-do-nordeste.png'
    },
    {
      'name': 'Banco Mercantil',
      'icon': 'assets/icon-bank/banco-mercantil.png'
    },
    {
      'name': 'Banco Modalmais',
      'icon': 'assets/icon-bank/banco-modalmais.png'
    },
    {
      'name': 'Banco Pan',
      'icon': 'assets/icon-bank/banco-pan.png'
    },
    {
      'name': 'Banese',
      'icon': 'assets/icon-bank/banese.png'
    },
    {
      'name': 'Banestes',
      'icon': 'assets/icon-bank/banestes.png'
    },
    {
      'name': 'Banpará',
      'icon': 'assets/icon-bank/banpara.png'
    },
    {
      'name': 'Banrisul',
      'icon': 'assets/icon-bank/banrisul.png'
    },
    {
      'name': 'Bari',
      'icon': 'assets/icon-bank/bari.png'
    },
    {
      'name': 'BDMG',
      'icon': 'assets/icon-bank/bdmg.png'
    },
    {
      'name': 'BIB',
      'icon': 'assets/icon-bank/bib.png'
    },
    {
      'name': 'BMG',
      'icon': 'assets/icon-bank/bmg.png'
    },
    {
      'name': 'BNDES',
      'icon': 'assets/icon-bank/bndes.png'
    },
    {
      'name': 'Bradesco',
      'icon': 'assets/icon-bank/bradesco.png'
    },
    {
      'name': 'BRB',
      'icon': 'assets/icon-bank/brb.png'
    },
    {
      'name': 'BRDE',
      'icon': 'assets/icon-bank/brde.png'
    },
    {
      'name': 'BS2',
      'icon': 'assets/icon-bank/bs2.png'
    },
    {
      'name': 'BTG',
      'icon': 'assets/icon-bank/btg.png'
    },
    {
      'name': 'BV',
      'icon': 'assets/icon-bank/bv.png'
    },
    {
      'name': 'C6 Bank',
      'icon': 'assets/icon-bank/c6.png'
    },
    {
      'name': 'Caixa',
      'icon': 'assets/icon-bank/caixa.png'
    },
    {
      'name': 'Citi',
      'icon': 'assets/icon-bank/citi.png'
    },
    {
      'name': 'Clear Corretora',
      'icon': 'assets/icon-bank/clear-corretora.png'
    },
    {
      'name': 'Cresol',
      'icon': 'assets/icon-bank/cresol.png'
    },
    {
      'name': 'Digi+',
      'icon': 'assets/icon-bank/digi+.png'
    },
    {
      'name': 'Digio',
      'icon': 'assets/icon-bank/digio.png'
    },
    {
      'name': 'HSBC',
      'icon': 'assets/icon-bank/hsbc.png'
    },
    {
      'name': 'Inter',
      'icon': 'assets/icon-bank/inter.png'
    },
    {
      'name': 'Itaú',
      'icon': 'assets/icon-bank/itau.png'
    },
    {
      'name': 'Nubank',
      'icon': 'assets/icon-bank/nubank.png'
    },
    {
      'name': 'Santander',
      'icon': 'assets/icon-bank/santander.png'
    },
    {
      'name': 'Sicoob',
      'icon': 'assets/icon-bank/sicoob.png'
    },
    {
      'name': 'Sicredi',
      'icon': 'assets/icon-bank/sicredi.png'
    },
    {
      'name': 'Stone',
      'icon': 'assets/icon-bank/stone.png'
    },
    {
      'name': 'XP Investimentos',
      'icon': 'assets/icon-bank/xp.png'
    }
  ];
  List<Map<String, String>> filteredBanks = [];

  @override
  void initState() {
    super.initState();
    filteredBanks = List.from(banks);
  }

  void _filterBanks(String query) {
    setState(() {
      filteredBanks = banks.where((bank) {
        final nameLower = bank['name']!.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar banco',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterBanks,
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Icone generico'),
                Image.asset(
                  'assets/icon-bank/icone-generico.png',
                  width: 40,
                  height: 40,
                ),
              ],
            ),
            Text('Icones de instuições bancarias'),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBanks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(
                      filteredBanks[index]['icon']!,
                      width: 40,
                      height: 40,
                    ),
                    title: Text(filteredBanks[index]['name']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
