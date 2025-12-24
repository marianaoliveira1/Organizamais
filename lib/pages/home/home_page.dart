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
import 'package:organizamais/services/analytics_service.dart';
import 'package:organizamais/utils/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final AnalyticsService _analyticsService = AnalyticsService();

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
    if (_selectedIndex == index) return;

    if (index == 2) {
      _analyticsService.logScreenView('transaction_page');
      Get.to(() => TransactionPage())?.then((result) {
        if (result != null && result is int && mounted) {
          setState(() {
            _selectedIndex = result;
          });
        }
      });
    } else {
      switch (index) {
        case 0:
          _analyticsService.logScreenView('initial_page');
          break;
        case 1:
          _analyticsService.logScreenView('graphics_page');
          break;
        case 3:
          _analyticsService.logScreenView('resume_page');
          break;
        case 4:
          _analyticsService.logScreenView('monthly_analysis_page');
          break;
      }

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    ThemeData theme,
  ) {
    final isSelected = _selectedIndex == index;
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 10 : 8,
            horizontal: isTablet ? 16 : 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? theme.primaryColor : DefaultColors.grey,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? theme.primaryColor : DefaultColors.grey,
                  fontSize: isTablet ? 12.sp : 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralActionButton(double size, bool isTablet) {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: DefaultColors.green,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          Iconsax.add,
          color: DefaultColors.white,
          size: isTablet ? 24.sp : 22.sp,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBarMobile(
      BuildContext context, ThemeData theme) {
    return RepaintBoundary(
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
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                          context, 0, IconsaxBold.home, "Inicio", theme),
                      _buildNavItem(
                          context, 1, IconsaxBold.graph, "Graficos", theme),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildCentralActionButton(44.w, false),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                          context,
                          3,
                          IconsaxBold.arrow_swap_horizontal,
                          "Transações",
                          theme),
                      _buildNavItem(
                          context, 4, IconsaxBold.status_up, "Analise", theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBarTablet(
      BuildContext context, ThemeData theme) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border:
              const Border(top: BorderSide(color: Colors.black12, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                          context, 0, IconsaxBold.home, "Início", theme),
                      _buildNavItem(
                          context, 1, IconsaxBold.graph, "Gráficos", theme),
                    ],
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildCentralActionButton(48.w, true),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                          context,
                          3,
                          IconsaxBold.arrow_swap_horizontal,
                          "Transações",
                          theme),
                      _buildNavItem(
                          context, 4, IconsaxBold.status_up, "Análise", theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: isTablet
          ? _buildBottomNavigationBarTablet(context, theme)
          : _buildBottomNavigationBarMobile(context, theme),
    );
  }
}
