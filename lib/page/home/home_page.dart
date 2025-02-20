// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/page/cards/cards_page.dart';
import 'package:organizamais/page/graphics/graphics_page.dart';
import 'package:organizamais/page/initial/initial_page.dart';

import 'package:organizamais/page/resume/resume_page.dart';
import 'package:organizamais/page/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

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
    ResumePage(),
    CardsPage(),
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      // Abre TransactionPage e aguarda o retorno
      final result = await Get.to(() => TransactionPage());

      // Se a TransactionPage retornar um índice válido, atualiza a BottomNavigationBar
      if (result != null && result is int) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
            icon: FaIcon(FontAwesomeIcons.house),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartPie),
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
            icon: FaIcon(FontAwesomeIcons.arrowsLeftRight),
            label: "Resumo",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.receipt),
            label: "Cartões",
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
