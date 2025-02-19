import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:organizamais/controller/card_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/controller/transaction_controller.dart';

import '../routes/route.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  var isLoading = false.obs;
  var loadedOtherControllers = false;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    ever(firebaseUser, _loadOtherComponents);
  }

  _loadOtherComponents(User? user) {
    if (user == null) return;
    if (loadedOtherControllers) return;

    loadedOtherControllers = true;
    Get.find<CardController>().startCardStream();
    Get.find<FixedAccountsController>().startFixedAccountsStream();
    Get.find<TransactionController>().startTransactionStream();
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoadingDialog() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading(true);
      _showLoadingDialog();

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "uid": userCredential.user!.uid,
      });
    } catch (e) {
      Get.snackbar("Erro ao cadastrar", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
      _hideLoadingDialog();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // isLoading(true);
      _showLoadingDialog();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Erro ao entrar", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      // isLoading(false);
      _hideLoadingDialog();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading(true);
      _showLoadingDialog();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw "Login cancelado";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "name": googleUser.displayName ?? "Usuário",
          "email": googleUser.email,
          "uid": userCredential.user!.uid,
        });
      }
    } catch (e) {
      Get.snackbar("Erro ao entrar com Google", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
      _hideLoadingDialog();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
