// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../../ads_banner/ads_banner.dart';
import '../../controller/auth_controller.dart';
import '../initial/widget/edit_name_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    void _showDeleteConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Deletar Conta"),
            content: const Text(
                "Tem certeza que deseja deletar sua conta? Esta ação não pode ser desfeita."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  authController.deleteAccount();
                },
                child:
                    const Text("Deletar", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    void _showEditNameDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditNameDialog(authController: authController);
        },
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nome",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.grey20,
                  ),
                ),
                GestureDetector(
                  onTap: _showEditNameDialog,
                  child: Icon(
                    Icons.edit,
                    size: 16.sp,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            Obx(() {
              final user = authController.firebaseUser.value;
              if (user == null) {
                return const SizedBox.shrink();
              }
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final firestoreName =
                      snapshot.data?.data()?['name'] as String?;
                  final effectiveName =
                      (firestoreName != null && firestoreName.trim().isNotEmpty)
                          ? firestoreName
                          : (user.displayName ?? '');

                  return Text(
                    effectiveName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  );
                },
              );
            }),
            SizedBox(
              height: 20.h,
            ),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey20,
              ),
            ),
            Obx(
              () {
                final user = authController.firebaseUser.value;
                return Text(
                  user?.email ?? "Email não disponível",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showDeleteConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Deletar Conta",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
