// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'routes/app_pages.dart';
// import 'bindings/initial_binding.dart';

// void main() {
//   runApp(GetMaterialApp(
//     title: 'Finanças App',
//     initialRoute: AppPages.INITIAL,
//     getPages: AppPages.routes,
//     initialBinding: InitialBinding(),
//     theme: ThemeData(
//       primarySwatch: Colors.blue,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//     ),
//   ));
// }

// // lib/routes/app_pages.dart
// import 'package:get/get.dart';
// import '../pages/main/main_screen.dart';
// import '../pages/transaction/transaction_page.dart';
// import '../bindings/main_binding.dart';
// import '../bindings/transaction_binding.dart';

// class AppPages {
//   static const INITIAL = Routes.MAIN;

//   static final routes = [
//     GetPage(
//       name: Routes.MAIN,
//       page: () => MainScreen(),
//       binding: MainBinding(),
//     ),
//     GetPage(
//       name: Routes.TRANSACTION,
//       page: () => TransactionPage(),
//       binding: TransactionBinding(),
//     ),
//   ];
// }

// abstract class Routes {
//   static const MAIN = '/';
//   static const TRANSACTION = '/transaction';
// }

// // lib/bindings/initial_binding.dart
// import 'package:get/get.dart';
// import '../controllers/navigation_controller.dart';

// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.put(NavigationController());
//   }
// }

// // lib/bindings/main_binding.dart
// import 'package:get/get.dart';
// import '../controllers/navigation_controller.dart';

// class MainBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<NavigationController>(() => NavigationController());
//   }
// }

// // lib/bindings/transaction_binding.dart
// import 'package:get/get.dart';
// import '../controllers/transaction_controller.dart';

// class TransactionBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<TransactionController>(() => TransactionController());
//   }
// }

// // lib/controllers/navigation_controller.dart
// import 'package:get/get.dart';
// import '../routes/app_pages.dart';

// class NavigationController extends GetxController {
//   var selectedIndex = 0.obs;

//   void changeIndex(int index) {
//     if (index == 2) {
//       Get.bottomSheet(
//         Container(
//           height: 300,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.add, color: Colors.green),
//                 title: Text('receita'),
//                 onTap: () {
//                   Get.back();
//                   Get.toNamed(Routes.TRANSACTION, arguments: 'receita');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.remove, color: Colors.red),
//                 title: Text('despesa'),
//                 onTap: () {
//                   Get.back();
//                   Get.toNamed(Routes.TRANSACTION, arguments: 'despesa');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.swap_horiz),
//                 title: Text('transferência'),
//                 onTap: () {
//                   Get.back();
//                   Get.toNamed(Routes.TRANSACTION, arguments: 'transferência');
//                 },
//               ),
//             ],
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//       );
//     } else {
//       selectedIndex.value = index;
//     }
//   }
// }

// // lib/controllers/transaction_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TransactionController extends GetxController {
//   var transactionType = 'receita'.obs;
//   var value = 0.0.obs;
//   var title = ''.obs;
//   var description = ''.obs;
//   var selectedDate = DateTime.now().obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Get the transaction type from arguments
//     if (Get.arguments != null) {
//       transactionType.value = Get.arguments;
//     }
//   }

//   Color get primaryColor {
//     switch (transactionType.value) {
//       case 'receita':
//         return Colors.green;
//       case 'despesa':
//         return Colors.red;
//       case 'transferência':
//         return Colors.grey;
//       default:
//         return Colors.green;
//     }
//   }

//   void saveTransaction() {
//     // Implement your save logic here
//     print('Saving transaction:');
//     print('Type: ${transactionType.value}');
//     print('Value: ${value.value}');
//     print('Title: ${title.value}');
//     print('Description: ${description.value}');
//     print('Date: ${selectedDate.value}');
//     Get.back();
//   }
// }

// // lib/pages/main/main_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/navigation_controller.dart';
// import 'home_page.dart';
// import 'charts_page.dart';
// import 'card_page.dart';
// import 'profile_page.dart';

// class MainScreen extends GetView<NavigationController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() => IndexedStack(
//         index: controller.selectedIndex.value,
//         children: [
//           HomePage(),
//           ChartsPage(),
//           Container(),
//           CardPage(),
//           ProfilePage(),
//         ],
//       )),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 5,
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         child: Obx(() => BottomNavigationBar(
//           currentIndex: controller.selectedIndex.value,
//           onTap: controller.changeIndex,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           selectedItemColor: Colors.blue,
//           unselectedItemColor: Colors.grey,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Início',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.bar_chart),
//               label: 'Gráficos',
//             ),
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                 ),
//                 padding: EdgeInsets.all(12),
//                 child: Icon(Icons.add, color: Colors.white),
//               ),
//               label: 'Adicionar',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.credit_card),
//               label: 'Cartão',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'Perfil',
//             ),
//           ],
//         )),
//       ),
//     );
//   }
// }

// // lib/pages/transaction/transaction_page.dart
// // (Use the TransactionPage code from the previous response here)
