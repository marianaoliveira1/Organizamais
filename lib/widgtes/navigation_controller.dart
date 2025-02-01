import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

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
                  // Add your logic for receita
                  Get.back();
                },
              ),
              ListTile(
                leading: Icon(Icons.remove, color: Colors.red),
                title: Text('despesa'),
                onTap: () {
                  // Add your logic for despesa
                  Get.back();
                },
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('transferência'),
                onTap: () {
                  // Add your logic for transferência
                  Get.back();
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
