// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import 'package:get/get.dart';

import '../../../ads_banner/ads_banner.dart';

class SelectIconPage extends StatefulWidget {
  final Function(String, String) onIconSelected;

  const SelectIconPage({super.key, required this.onIconSelected});

  @override
  _SelectIconPageState createState() => _SelectIconPageState();
}

class _SelectIconPageState extends State<SelectIconPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> bankIcons = [
    {'path': 'assets/icon-bank/abc-brasil.png', 'name': 'ABC Brasil'},
    {'path': 'assets/icon-bank/agi.png', 'name': 'AGI'},
    {'path': 'assets/icon-bank/amazon-pay.png', 'name': 'Amazon Pay'},
    {
      'path': 'assets/icon-bank/american-express.png',
      'name': 'American Express'
    },
    {'path': 'assets/icon-bank/avenue.png', 'name': 'Avenue'},
    {'path': 'assets/icon-bank/banco-agora.png', 'name': 'Banco Ágora'},
    {'path': 'assets/icon-bank/banco-alfa.png', 'name': 'Banco Alfa'},
    {
      'path': 'assets/icon-bank/banco-da-amazonia.png',
      'name': 'Banco da Amazônia'
    },
    {'path': 'assets/icon-bank/banco-daycoval.png', 'name': 'Banco Daycoval'},
    {'path': 'assets/icon-bank/banco-do-brasil.png', 'name': 'Banco do Brasil'},
    {
      'path': 'assets/icon-bank/banco-do-nordeste.png',
      'name': 'Banco do Nordeste'
    },
    {'path': 'assets/icon-bank/banco-mercantil.png', 'name': 'Banco Mercantil'},
    {'path': 'assets/icon-bank/banco-modalmais.png', 'name': 'Banco ModalMais'},
    {'path': 'assets/icon-bank/banco-pan.png', 'name': 'Banco Pan'},
    {'path': 'assets/icon-bank/banese.png', 'name': 'Banese'},
    {'path': 'assets/icon-bank/banestes.png', 'name': 'Banestes'},
    {'path': 'assets/icon-bank/banpara.png', 'name': 'Banpará'},
    {'path': 'assets/icon-bank/banrisul.png', 'name': 'Banrisul'},
    {'path': 'assets/icon-bank/bari.png', 'name': 'Bari'},
    {'path': 'assets/icon-bank/bdmg.png', 'name': 'BDMG'},
    {'path': 'assets/icon-bank/bib.png', 'name': 'BIB'},
    {'path': 'assets/icon-bank/bmg.png', 'name': 'BMG'},
    {'path': 'assets/icon-bank/bndes.png', 'name': 'BNDES'},
    {'path': 'assets/icon-bank/bradesco.png', 'name': 'Bradesco'},
    {'path': 'assets/icon-bank/brb.png', 'name': 'BRB'},
    {'path': 'assets/icon-bank/brde.png', 'name': 'BRDE'},
    {'path': 'assets/icon-bank/bs2.png', 'name': 'BS2'},
    {'path': 'assets/icon-bank/btg.png', 'name': 'BTG'},
    {'path': 'assets/icon-bank/bv.png', 'name': 'BV'},
    {'path': 'assets/icon-bank/c6.png', 'name': 'C6 Bank'},
    {'path': 'assets/icon-bank/caixa.png', 'name': 'Caixa'},
    {'path': 'assets/icon-bank/citi.png', 'name': 'Citi'},
    {'path': 'assets/icon-bank/clear-corretora.png', 'name': 'Clear Corretora'},
    {'path': 'assets/icon-bank/credisis.png', 'name': 'Credisis'},
    {'path': 'assets/icon-bank/cresol.png', 'name': 'Cresol'},
    {'path': 'assets/icon-bank/digi+.png', 'name': 'Digi+'},
    {'path': 'assets/icon-bank/digio.png', 'name': 'Digio'},
    {'path': 'assets/icon-bank/efi-bank.png', 'name': 'EFI Bank'},
    {'path': 'assets/icon-bank/genial.png', 'name': 'Genial'},
    {'path': 'assets/icon-bank/hsbc.png', 'name': 'HSBC'},
    {'path': 'assets/icon-bank/icone-generico.png', 'name': 'Genérico'},
    {'path': 'assets/icon-bank/inter.png', 'name': 'Inter'},
    {'path': 'assets/icon-bank/ion.png', 'name': 'Ion'},
    {'path': 'assets/icon-bank/itau.png', 'name': 'Itaú'},
    {'path': 'assets/icon-bank/iti.png', 'name': 'Iti'},
    {'path': 'assets/icon-bank/lar.png', 'name': 'Lar'},
    {'path': 'assets/icon-bank/latam-pass.png', 'name': 'Latam Pass'},
    {'path': 'assets/icon-bank/mercado-pago.png', 'name': 'Mercado Pago'},
    {'path': 'assets/icon-bank/modal.png', 'name': 'Modal'},
    {'path': 'assets/icon-bank/neon.png', 'name': 'Neon'},
    {'path': 'assets/icon-bank/next.png', 'name': 'Next'},
    {'path': 'assets/icon-bank/nomad.png', 'name': 'Nomad'},
    {'path': 'assets/icon-bank/nubank.png', 'name': 'Nubank'},
    {'path': 'assets/icon-bank/original.png', 'name': 'Original'},
    {'path': 'assets/icon-bank/pagbank.png', 'name': 'PagBank'},
    {'path': 'assets/icon-bank/paranabanco.png', 'name': 'Paranabanco'},
    {'path': 'assets/icon-bank/pay-pal.png', 'name': 'PayPal'},
    {'path': 'assets/icon-bank/pic-pay.png', 'name': 'PicPay'},
    {'path': 'assets/icon-bank/rico.png', 'name': 'Rico'},
    {'path': 'assets/icon-bank/safra.png', 'name': 'Safra'},
    {'path': 'assets/icon-bank/santander.png', 'name': 'Santander'},
    {'path': 'assets/icon-bank/shopee-pay.png', 'name': 'Shopee Pay'},
    {'path': 'assets/icon-bank/sicoob.png', 'name': 'Sicoob'},
    {'path': 'assets/icon-bank/sicredi.png', 'name': 'Sicredi'},
    {'path': 'assets/icon-bank/sisprime.png', 'name': 'SisPrime'},
    {'path': 'assets/icon-bank/sofisa.png', 'name': 'Sofisa'},
    {'path': 'assets/icon-bank/stone.png', 'name': 'Stone'},
    {'path': 'assets/icon-bank/stonex.png', 'name': 'StoneX'},
    {'path': 'assets/icon-bank/topazio.png', 'name': 'Topázio'},
    {'path': 'assets/icon-bank/toro.png', 'name': 'Toro'},
    {'path': 'assets/icon-bank/tudo-azul.png', 'name': 'TudoAzul'},
    {'path': 'assets/icon-bank/unicred.png', 'name': 'Unicred'},
    {'path': 'assets/icon-bank/vivacredi.png', 'name': 'Vivacredi'},
    {'path': 'assets/icon-bank/western-union.png', 'name': 'Western Union'},
    {'path': 'assets/icon-bank/will-bank.png', 'name': 'Will Bank'},
    {'path': 'assets/icon-bank/wise.png', 'name': 'Wise'},
    {'path': 'assets/icon-bank/xp.png', 'name': 'XP'},
  ];

  List<Map<String, String>> get filteredBankIcons {
    if (searchQuery.isEmpty) {
      return bankIcons;
    }
    return bankIcons
        .where((bank) =>
            bank['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalResults = filteredBankIcons.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        titleSpacing: 16.w,
        title: Text(
          'Selecionar ícone',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              AdsBanner(),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _buildSearchField(theme),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: totalResults == 0
                      ? _buildEmptyState(theme)
                      : GridView.builder(
                          key: ValueKey(searchQuery),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 500 ? 4 : 3,
                            mainAxisSpacing: 14.h,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: totalResults,
                          itemBuilder: (context, index) {
                            final bank = filteredBankIcons[index];
                            return _BankIconTile(
                              bank: bank,
                              onTap: () {
                                widget.onIconSelected(
                                    bank['path']!, bank['name']!);
                                Get.back();
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Iconsax.search_normal, color: theme.primaryColor, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: const InputDecoration(
                hintText: 'Buscar banco, carteira ou cartão',
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                setState(() => searchQuery = '');
              },
              icon: Icon(Icons.close, color: theme.primaryColor, size: 18.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, int totalResults) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: theme.primaryColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Iconsax.card, color: theme.primaryColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ícones disponíveis',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$totalResults opções encontradas',
                  style: TextStyle(
                    color: theme.primaryColor.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.search_favorite,
                color: theme.primaryColor, size: 32.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            'Nada encontrado',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tente outro termo para localizar o banco desejado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankIconTile extends StatelessWidget {
  final Map<String, String> bank;
  final VoidCallback onTap;

  const _BankIconTile({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: theme.primaryColor.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Image.asset(
                    bank['path']!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                bank['name']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
