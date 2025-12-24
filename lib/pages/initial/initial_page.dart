import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/goal_controller.dart';

import 'widget/credit_card_selection.dart';
import 'widget/custom_drawer.dart';
import 'widget/finance_summary.dart';
import 'widget/goals_card.dart';
import 'widget/parcelamentos_card.dart';
import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FixedAccountsController>()) {
      Get.put(FixedAccountsController());
    }

    final GoalController goalController = Get.put(GoalController());
    if (goalController.goalStream == null) {
      goalController.startGoalStream();
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: _buildUserName(theme),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
        ),
      ),
    );
  }

  Widget _buildUserName(ThemeData theme) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      final user = auth.firebaseUser.value;
      if (user == null) return const SizedBox.shrink();

      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final firestoreName = snapshot.data?.data()?['name'] as String?;
          final effectiveName =
              (firestoreName != null && firestoreName.trim().isNotEmpty)
                  ? firestoreName
                  : (user.displayName ?? 'Usuário');

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oi,',
                style: TextStyle(
                  color: theme.primaryColor.withOpacity(0.7),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$effectiveName 👋",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardSections = [
      const FinanceSummaryWidget(),
      const DefaultWidgetFixedAccounts(),
      ParcelamentosCard(),
      CreditCardSection(),
      const GoalsCard(),
    ];

    return Column(
      children: [
        SizedBox(height: 10.h),
        AdsBanner(),
        SizedBox(height: 20.h),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  ...dashboardSections.map((section) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: section,
                      )),
                  SizedBox(height: 16.h),
                  AdsBanner(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > 1024 ? 48.0 : 32.0;
    final double rowSpacing = 24.0;
    final double maxCardWidth = 520.0;

    return Column(
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w / 2),
          child: AdsBanner(),
        ),
        SizedBox(height: 24.h),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding.w / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: const FinanceSummaryWidget(),
                  ),
                  SizedBox(height: rowSpacing.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final cardWidth = ((availableWidth - rowSpacing) / 2)
                          .clamp(320.0, maxCardWidth);

                      return Column(
                        children: [
                          _TabletRow(
                            spacing: rowSpacing,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: cardWidth),
                                child: const DefaultWidgetFixedAccounts(),
                              ),
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: cardWidth),
                                child: ParcelamentosCard(),
                              ),
                            ],
                          ),
                          SizedBox(height: rowSpacing.h),
                          _TabletRow(
                            spacing: rowSpacing,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: cardWidth),
                                child: CreditCardSection(),
                              ),
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: cardWidth),
                                child: const GoalsCard(),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding.w / 2),
                    child: AdsBanner(),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabletRow extends StatelessWidget {
  const _TabletRow({
    required this.children,
    required this.spacing,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}

// Widget auxiliar para responsividade
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return mobile;
    } else {
      return tablet;
    }
  }
}

// Widget responsivo para padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double mobilePadding;
  final double tabletPadding;
  final double desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = 20.0,
    this.tabletPadding = 32.0,
    this.desktopPadding = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.isMobile(context)
            ? mobilePadding.w
            : tabletPadding.w,
      ),
      child: child,
    );
  }
}

// Widget responsivo para espaçamento
class ResponsiveSpacing extends StatelessWidget {
  final bool vertical;
  final double mobileSize;
  final double tabletSize;
  final double desktopSize;

  const ResponsiveSpacing({
    super.key,
    this.vertical = true,
    this.mobileSize = 16.0,
    this.tabletSize = 24.0,
    this.desktopSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: vertical
          ? (ResponsiveLayout.isMobile(context) ? mobileSize.h : tabletSize.h)
          : null,
      width: !vertical
          ? (ResponsiveLayout.isMobile(context) ? mobileSize.w : tabletSize.w)
          : null,
    );
  }
}
