// ignore_for_file: unused_element

import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/pages/graphics/graphics_page.dart';
import 'package:organizamais/pages/initial/initial_page.dart';
import 'package:organizamais/pages/profile/profile_page.dart';

import 'package:organizamais/pages/resume/resume_page.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

import '../goals/goals_page.dart';

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
    ProfilePage(),
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      final result = await Get.to(() => TransactionPage());

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
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              IconsaxBold.home,
            ),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconsaxBold.graph,
            ),
            label: "Graficos",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Iconsax.add,
              size: 0,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconsaxBold.arrow_swap_horizontal,
            ),
            label: "Transações",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconsaxBold.user,
            ),
            label: "Perfil",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.primaryColor,
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
