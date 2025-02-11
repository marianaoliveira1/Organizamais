import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/page/cards/cards_page.dart';
import 'package:organizamais/page/graphics/graphics_page.dart';
import 'package:organizamais/page/initial/initial_page.dart';

import 'package:organizamais/page/resume/resume_pegae.dart';
import 'package:organizamais/page/transaction_page.dart/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../model/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    InitialPage(),
    GraphicsPage(),
    Container(),
    CardsPage(),
    ResumePegae(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showTransactionBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showTransactionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: DefaultColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "O que você quer adicionar?",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionButton("Receita", DefaultColors.green, Icons.add, () {
              Get.to(() => TransactionPage(transactionType: TransactionType.receita));
            }),
            const SizedBox(height: 10),
            _buildOptionButton("Despesa", DefaultColors.red, Icons.remove, () {
              Get.to(() => TransactionPage(transactionType: TransactionType.despesa));
            }),
            const SizedBox(height: 10),
            _buildOptionButton("Transferência", DefaultColors.grey, Icons.swap_horiz, () {
              Get.to(() => TransactionPage(transactionType: TransactionType.transferencia));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: DefaultColors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.chart_1),
            label: "Gráficos",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Iconsax.add,
              size: 0,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Cartões",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.receipt),
            label: "Resumo",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: DefaultColors.black,
        unselectedItemColor: DefaultColors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: DefaultColors.green,
        onPressed: () {
          _onItemTapped(2);
        },
        child: const Icon(
          Iconsax.add,
          color: DefaultColors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
