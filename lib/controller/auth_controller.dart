// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:organizamais/controller/card_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/services/analytics_service.dart';
import '../routes/route.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analyticsService = AnalyticsService();
  Rx<User?> firebaseUser = Rx<User?>(null);
  var isLoading = false.obs;
  var loadedOtherControllers = false;
  var isOnboarding = false;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
    ever(firebaseUser, _loadOtherComponents);
  }

  updateDisplayName(String displayName) async {
    await firebaseUser.value?.updateProfile(displayName: displayName);
    Get.snackbar("Sucesso", "Nome atualizado com sucesso: $displayName");
    await firebaseUser.value?.reload();
  }

  _loadOtherComponents(User? user) {
    if (user == null) return;
    if (loadedOtherControllers) return;
    loadedOtherControllers = true;
    Get.find<CardController>().startCardStream();
    Get.find<FixedAccountsController>().startFixedAccountsStream();
    Get.find<TransactionController>().startTransactionStream();
    Get.find<GoalController>().startGoalStream();
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      // Skip auto-redirect while onboarding
      if (isOnboarding) return;
      if (Get.currentRoute != Routes.HOME) {
        Get.offAllNamed(Routes.HOME);
      }
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

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta para este e-mail.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'A senha é muito fraca. Use uma senha mais forte.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'invalid-credential':
        return 'Credenciais inválidas.';
      default:
        return 'Erro: ${e.message}';
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading(true);
      _showLoadingDialog();
      final String trimmedName = name.trim();
      final String trimmedEmail = email.trim();
      final String trimmedPassword = password.trim();

      if (trimmedName.isEmpty ||
          trimmedEmail.isEmpty ||
          trimmedPassword.isEmpty) {
        _hideLoadingDialog();
        Get.snackbar(
          "Campos obrigatórios",
          "Preencha nome, e-mail e senha",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (trimmedPassword.length < 6) {
        _hideLoadingDialog();
        Get.snackbar(
          "Senha fraca",
          "A senha deve conter pelo menos 6 caracteres",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      var methods = await _auth.fetchSignInMethodsForEmail(trimmedEmail);
      if (methods.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Este e-mail já está em uso por outra conta.',
        );
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": trimmedName,
        "email": trimmedEmail,
        "uid": userCredential.user!.uid,
      });

      // Ensure Firebase Auth displayName is set so UI (Profile) shows the name
      await userCredential.user?.updateProfile(displayName: trimmedName);
      await userCredential.user?.reload();
      // Update local observable to reflect the new displayName immediately
      firebaseUser.value = _auth.currentUser;

      // Log analytics event
      await _analyticsService.logSignUp('email');

      _hideLoadingDialog();
      isOnboarding = true;
      Get.offAllNamed(Routes.ONBOARD_WELCOME);
    } on FirebaseAuthException catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao cadastrar",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao cadastrar",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      _showLoadingDialog();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Log analytics event
      await _analyticsService.logLogin('email');

      _hideLoadingDialog();
    } on FirebaseAuthException catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao entrar",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao entrar",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _showLoadingDialog();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Login cancelado pelo usuário");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "name": googleUser.displayName ?? "Usuário",
          "email": googleUser.email,
          "uid": userCredential.user!.uid,
        });

        // Log analytics event for new user
        await _analyticsService.logSignUp('google');

        isOnboarding = true;
        _hideLoadingDialog();
        Get.offAllNamed(Routes.ONBOARD_WELCOME);
        return;
      }

      // Log analytics event for existing user
      await _analyticsService.logLogin('google');
      // Usuário já existente: garantir atualização do estado e navegar para HOME
      try {
        await userCredential.user?.reload();
        firebaseUser.value = _auth.currentUser;
      } catch (_) {}
      _hideLoadingDialog();
      if (Get.currentRoute != Routes.HOME) {
        Get.offAllNamed(Routes.HOME);
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao entrar com Google",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao entrar com Google",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      // Log analytics event
      await _analyticsService.logLogout();

      await _auth.signOut();
      loadedOtherControllers = false;
      Get.snackbar(
        "Logout",
        "Você saiu da sua conta",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erro ao sair",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      _showLoadingDialog();

      await _auth.sendPasswordResetEmail(email: email);

      // Log analytics event
      await _analyticsService.logPasswordReset();

      Get.snackbar(
        "E-mail enviado",
        "Verifique sua caixa de entrada para redefinir sua senha",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Erro ao redefinir senha",
        _getAuthErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erro inesperado",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      _hideLoadingDialog();
    }
  }

  // Add this method to your existing AuthController class

  void deleteAccount() async {
    try {
      // Get the current user
      final user = firebaseUser.value;
      if (user != null) {
        // Log analytics event before deletion
        await _analyticsService.logDeleteAccount();

        // Delete the user account
        await user.delete();

        // Clear any local storage/cache if needed
        // ...

        // Navigate to login or welcome screen
        Get.offAllNamed('/login'); // Or whatever your login route is

        Get.snackbar(
          'Conta Deletada',
          'Sua conta foi deletada com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível deletar sua conta. Tente fazer login novamente e repetir a operação.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
