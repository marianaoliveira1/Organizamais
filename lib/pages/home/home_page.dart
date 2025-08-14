// ignore_for_file: unused_element

import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/pages/graphics/graphics_page.dart';
import 'package:organizamais/pages/initial/initial_page.dart';
import 'package:organizamais/pages/monthy_analsis/monthy_analsis.dart';

import 'package:organizamais/pages/resume/resume_page.dart';
import 'package:organizamais/pages/transaction/transaction_page.dart';
import 'package:organizamais/utils/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InitialPage(),
    const GraphicsPage(),
    Container(),
    const ResumePage(),
    const MonthlyAnalysisPage(),
  ];

  @override
  bool get wantKeepAlive => true;

  void _onItemTapped(int index) {
    // Evitar rebuilds desnecessários
    if (_selectedIndex == index) return;

    if (index == 2) {
      Get.to(() => TransactionPage())?.then((result) {
        if (result != null && result is int && mounted) {
          setState(() {
            _selectedIndex = result;
          });
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, ThemeData theme) {
    final isSelected = _selectedIndex == index;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? theme.primaryColor : DefaultColors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? theme.primaryColor : DefaultColors.grey,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      String text, Color color, IconData icon, VoidCallback onTap) {
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
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, IconsaxBold.home, "Inicio", theme),
                  _buildNavItem(1, IconsaxBold.graph, "Graficos", theme),
                  const SizedBox(width: 40), // Espaço para o FAB
                  _buildNavItem(3, IconsaxBold.arrow_swap_horizontal,
                      "Transações", theme),
                  _buildNavItem(4, IconsaxBold.status_up, "Analise", theme),
                ],
              ),
            ),
          ),
        ),
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
