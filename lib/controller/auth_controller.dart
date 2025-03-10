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

    String _handleAuthError(dynamic error) {
      String errorMessage = error.toString();

      if (errorMessage.contains('user-not-found')) {
        return 'Usuário não encontrado. Verifique seu e-mail.';
      } else if (errorMessage.contains('wrong-password')) {
        return 'Senha incorreta. Tente novamente.';
      } else if (errorMessage.contains('email-already-in-use')) {
        return 'E-mail já está em uso. Tente outro.';
      } else if (errorMessage.contains('invalid-email')) {
        return 'E-mail inválido. Por favor, verifique.';
      } else if (errorMessage.contains('weak-password')) {
        return 'Senha muito fraca. Use uma senha mais forte.';
      } else if (errorMessage.contains('network-request-failed')) {
        return 'Erro de conexão. Verifique sua internet.';
      } else {
        return 'Erro inesperado: $errorMessage';
      }
    }
  }

  // Função para tratar os erros do Firebase Auth e retornar mensagens amigáveis
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

      // Verificar se o e-mail já está em uso antes de tentar registrar
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw FirebaseAuthException(code: 'email-already-in-use', message: 'Este e-mail já está em uso por outra conta.');
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "uid": userCredential.user!.uid,
      });

      Get.snackbar(
        "Sucesso",
        "Conta criada com sucesso!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Erro ao cadastrar",
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

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      _showLoadingDialog();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.snackbar(
        "Sucesso",
        "Login realizado com sucesso!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Falha no login",
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

  Future<void> loginWithGoogle() async {
    try {
      isLoading(true);
      _showLoadingDialog();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Login cancelado pelo usuário");
      }

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

      Get.snackbar("Sucesso", "Login com Google realizado com sucesso!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Erro no login com Google", _getAuthErrorMessage(e), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Erro no login com Google", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
      _hideLoadingDialog();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      loadedOtherControllers = false; // Reiniciar para o próximo login
      Get.snackbar("Logout", "Você saiu da sua conta", backgroundColor: Colors.blue, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Erro ao sair", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Método para recuperação de senha
  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      _showLoadingDialog();

      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar("E-mail enviado", "Verifique sua caixa de entrada para redefinir sua senha", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Erro ao redefinir senha", _getAuthErrorMessage(e), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Erro inesperado", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
      _hideLoadingDialog();
    }
  }
}
