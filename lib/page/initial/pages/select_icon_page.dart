// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../utils/color.dart';

class SelectIconPage extends StatefulWidget {
  final Function(String, String) onIconSelected;

  const SelectIconPage({super.key, required this.onIconSelected});

  @override
  _SelectIconPageState createState() => _SelectIconPageState();
}

class _SelectIconPageState extends State<SelectIconPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, String>> bankIcons = [
    {
      'path': 'assets/icon-bank/abc-brasil.png',
      'name': 'ABC Brasil'
    },
    {
      'path': 'assets/icon-bank/agi.png',
      'name': 'AGI'
    },
    {
      'path': 'assets/icon-bank/amazon-pay.png',
      'name': 'Amazon Pay'
    },
    {
      'path': 'assets/icon-bank/american-express.png',
      'name': 'American Express'
    },
    {
      'path': 'assets/icon-bank/avenue.png',
      'name': 'Avenue'
    },
    {
      'path': 'assets/icon-bank/banco-agora.png',
      'name': 'Banco Ágora'
    },
    {
      'path': 'assets/icon-bank/banco-alfa.png',
      'name': 'Banco Alfa'
    },
    {
      'path': 'assets/icon-bank/banco-da-amazonia.png',
      'name': 'Banco da Amazônia'
    },
    {
      'path': 'assets/icon-bank/banco-daycoval.png',
      'name': 'Banco Daycoval'
    },
    {
      'path': 'assets/icon-bank/banco-do-brasil.png',
      'name': 'Banco do Brasil'
    },
    {
      'path': 'assets/icon-bank/banco-do-nordeste.png',
      'name': 'Banco do Nordeste'
    },
    {
      'path': 'assets/icon-bank/banco-mercantil.png',
      'name': 'Banco Mercantil'
    },
    {
      'path': 'assets/icon-bank/banco-modalmais.png',
      'name': 'Banco ModalMais'
    },
    {
      'path': 'assets/icon-bank/banco-pan.png',
      'name': 'Banco Pan'
    },
    {
      'path': 'assets/icon-bank/banese.png',
      'name': 'Banese'
    },
    {
      'path': 'assets/icon-bank/banestes.png',
      'name': 'Banestes'
    },
    {
      'path': 'assets/icon-bank/banpara.png',
      'name': 'Banpará'
    },
    {
      'path': 'assets/icon-bank/banrisul.png',
      'name': 'Banrisul'
    },
    {
      'path': 'assets/icon-bank/bari.png',
      'name': 'Bari'
    },
    {
      'path': 'assets/icon-bank/bdmg.png',
      'name': 'BDMG'
    },
    {
      'path': 'assets/icon-bank/bib.png',
      'name': 'BIB'
    },
    {
      'path': 'assets/icon-bank/bmg.png',
      'name': 'BMG'
    },
    {
      'path': 'assets/icon-bank/bndes.png',
      'name': 'BNDES'
    },
    {
      'path': 'assets/icon-bank/bradesco.png',
      'name': 'Bradesco'
    },
    {
      'path': 'assets/icon-bank/brb.png',
      'name': 'BRB'
    },
    {
      'path': 'assets/icon-bank/brde.png',
      'name': 'BRDE'
    },
    {
      'path': 'assets/icon-bank/bs2.png',
      'name': 'BS2'
    },
    {
      'path': 'assets/icon-bank/btg.png',
      'name': 'BTG'
    },
    {
      'path': 'assets/icon-bank/bv.png',
      'name': 'BV'
    },
    {
      'path': 'assets/icon-bank/c6.png',
      'name': 'C6 Bank'
    },
    {
      'path': 'assets/icon-bank/caixa.png',
      'name': 'Caixa'
    },
    {
      'path': 'assets/icon-bank/citi.png',
      'name': 'Citi'
    },
    {
      'path': 'assets/icon-bank/clear-corretora.png',
      'name': 'Clear Corretora'
    },
    {
      'path': 'assets/icon-bank/credisis.png',
      'name': 'Credisis'
    },
    {
      'path': 'assets/icon-bank/cresol.png',
      'name': 'Cresol'
    },
    {
      'path': 'assets/icon-bank/digi+.png',
      'name': 'Digi+'
    },
    {
      'path': 'assets/icon-bank/digio.png',
      'name': 'Digio'
    },
    {
      'path': 'assets/icon-bank/efi-bank.png',
      'name': 'EFI Bank'
    },
    {
      'path': 'assets/icon-bank/genial.png',
      'name': 'Genial'
    },
    {
      'path': 'assets/icon-bank/hsbc.png',
      'name': 'HSBC'
    },
    {
      'path': 'assets/icon-bank/icone-generico.png',
      'name': 'Genérico'
    },
    {
      'path': 'assets/icon-bank/inter.png',
      'name': 'Inter'
    },
    {
      'path': 'assets/icon-bank/ion.png',
      'name': 'Ion'
    },
    {
      'path': 'assets/icon-bank/itau.png',
      'name': 'Itaú'
    },
    {
      'path': 'assets/icon-bank/iti.png',
      'name': 'Iti'
    },
    {
      'path': 'assets/icon-bank/lar.png',
      'name': 'Lar'
    },
    {
      'path': 'assets/icon-bank/latam-pass.png',
      'name': 'Latam Pass'
    },
    {
      'path': 'assets/icon-bank/mercado-pago.png',
      'name': 'Mercado Pago'
    },
    {
      'path': 'assets/icon-bank/modal.png',
      'name': 'Modal'
    },
    {
      'path': 'assets/icon-bank/neon.png',
      'name': 'Neon'
    },
    {
      'path': 'assets/icon-bank/next.png',
      'name': 'Next'
    },
    {
      'path': 'assets/icon-bank/nomad.png',
      'name': 'Nomad'
    },
    {
      'path': 'assets/icon-bank/nubank.png',
      'name': 'Nubank'
    },
    {
      'path': 'assets/icon-bank/original.png',
      'name': 'Original'
    },
    {
      'path': 'assets/icon-bank/pagbank.png',
      'name': 'PagBank'
    },
    {
      'path': 'assets/icon-bank/paranabanco.png',
      'name': 'Paranabanco'
    },
    {
      'path': 'assets/icon-bank/pay-pal.png',
      'name': 'PayPal'
    },
    {
      'path': 'assets/icon-bank/pic-pay.png',
      'name': 'PicPay'
    },
    {
      'path': 'assets/icon-bank/rico.png',
      'name': 'Rico'
    },
    {
      'path': 'assets/icon-bank/safra.png',
      'name': 'Safra'
    },
    {
      'path': 'assets/icon-bank/santander.png',
      'name': 'Santander'
    },
    {
      'path': 'assets/icon-bank/shopee-pay.png',
      'name': 'Shopee Pay'
    },
    {
      'path': 'assets/icon-bank/sicoob.png',
      'name': 'Sicoob'
    },
    {
      'path': 'assets/icon-bank/sicredi.png',
      'name': 'Sicredi'
    },
    {
      'path': 'assets/icon-bank/sisprime.png',
      'name': 'SisPrime'
    },
    {
      'path': 'assets/icon-bank/sofisa.png',
      'name': 'Sofisa'
    },
    {
      'path': 'assets/icon-bank/stone.png',
      'name': 'Stone'
    },
    {
      'path': 'assets/icon-bank/stonex.png',
      'name': 'StoneX'
    },
    {
      'path': 'assets/icon-bank/topazio.png',
      'name': 'Topázio'
    },
    {
      'path': 'assets/icon-bank/toro.png',
      'name': 'Toro'
    },
    {
      'path': 'assets/icon-bank/tudo-azul.png',
      'name': 'TudoAzul'
    },
    {
      'path': 'assets/icon-bank/unicred.png',
      'name': 'Unicred'
    },
    {
      'path': 'assets/icon-bank/vivacredi.png',
      'name': 'Vivacredi'
    },
    {
      'path': 'assets/icon-bank/western-union.png',
      'name': 'Western Union'
    },
    {
      'path': 'assets/icon-bank/will-bank.png',
      'name': 'Will Bank'
    },
    {
      'path': 'assets/icon-bank/wise.png',
      'name': 'Wise'
    },
    {
      'path': 'assets/icon-bank/xp.png',
      'name': 'XP'
    },
  ];

  List<Map<String, String>> get filteredBankIcons {
    if (searchQuery.isEmpty) {
      return bankIcons;
    }
    return bankIcons.where((bank) => bank['name']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: DefaultColors.backgroundLight,
        title: Text('Selecionar Ícone'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar um ícone',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredBankIcons.isEmpty
                ? Center(
                    child: Text('Nenhum banco encontrado'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    itemCount: filteredBankIcons.length,
                    itemBuilder: (context, index) {
                      final bank = filteredBankIcons[index];
                      return ListTile(
                        onTap: () {
                          widget.onIconSelected(bank['path']!, bank['name']!);
                          Get.back();
                        },
                        leading: Image.asset(
                          bank['path']!,
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          bank['name']!,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
