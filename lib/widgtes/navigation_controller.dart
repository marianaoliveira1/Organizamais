import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/graphics/graphics_page.dart';

import '../page/cards/cards_page.dart';
import '../page/initial/initial_page.dart';
import '../page/profile/profile_page.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final pages = [
    InitialPage(),
    GraphicsPage(),
    Container(), // Empty container for add button
    CardsPage(),
    ProfilePage(),
  ];

  void changeIndex(int index) {
    if (index == 2) {
      Get.bottomSheet(
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.add, color: Colors.green),
                title: Text('receita'),
                onTap: () {
                  Get.back();
                  // Navigate to receita page
                  // Get.to(() => ReceitaPage());
                },
              ),
              ListTile(
                leading: Icon(Icons.remove, color: Colors.red),
                title: Text('despesa'),
                onTap: () {
                  Get.back();
                  // Navigate to despesa page
                },
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('transferência'),
                onTap: () {
                  Get.back();
                  // Navigate to transferência page
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );
    } else {
      selectedIndex.value = index;
    }
  }
}
