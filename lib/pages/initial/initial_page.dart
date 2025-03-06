import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/pages/initial/widget/finance_summary.dart';

import '../../controller/auth_controller.dart';
import '../../controller/fixed_accounts_controller.dart';

import 'widget/credit_card_selection.dart';
import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.h,
                ),
                child: Column(
                  spacing: 20.h,
                  children: [
                    FinanceSummaryWidget(),
                    DefaultWidgetFixedAccounts(),
                    CreditCardSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text("Perfil"),
            onTap: () {
              Get.toNamed("/profile");
            },
          ),
          ListTile(
            title: Text("Mues cartões"),
            onTap: () {
              Get.toNamed("/profile");
            },
          ),
          ListTile(
            title: Text("Minhas contas fixas"),
            onTap: () {
              Get.toNamed("/profile");
            },
          ),
          Spacer(),
          ListTile(
            title: Text("Sair"),
            onTap: () {
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}
