import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/cards/cards_page.dart';
import 'package:organizamais/page/graphics/graphics_page.dart';
import 'package:organizamais/page/initial/initial_page.dart';
import 'package:organizamais/page/profile/profile_page.dart';
import 'package:organizamais/page/transaction_page.dart/transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RxInt _selectedIndex = 0.obs;

  final List<Widget> _screens = [
    InitialPage(),
    GraphicsPage(),
    Container(), // Placeholder para o botão +
    CardsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showTransactionOptions();
    } else {
      _selectedIndex.value = index;
    }
  }

  void _showTransactionOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Adicionar Transação',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTransactionButton(
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                      label: 'Receita',
                      onTap: () {
                        Get.back();
                        Get.to(() => TransactionPage(type: 'receita'));
                      },
                    ),
                    _buildTransactionButton(
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                      label: 'Despesa',
                      onTap: () {
                        Get.back();
                        Get.to(() => TransactionPage(type: 'despesa'));
                      },
                    ),
                    _buildTransactionButton(
                      icon: Icons.swap_horiz,
                      color: Colors.blue,
                      label: 'Transferência',
                      onTap: () {
                        Get.back();
                        Get.to(() => TransactionPage(type: 'transferencia'));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[_selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _selectedIndex.value,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Gráficos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 40),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Cartões',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
