// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:organizamais/controller/card_controller.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/services/analytics_service.dart';
import 'package:firebase_performance/firebase_performance.dart';
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
  void onInit() {
    super.onInit();
    // Verificar usuário atual imediatamente
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      firebaseUser.value = currentUser;
      // Carregar componentes imediatamente se os controllers estiverem prontos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadOtherComponents(currentUser);
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Vincular ao stream para mudanças futuras
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
    ever(firebaseUser, _loadOtherComponents);
    ever<User?>(firebaseUser, (u) async {
      try {
        await FirebaseCrashlytics.instance.setUserIdentifier(u?.uid ?? 'guest');
        await FirebaseCrashlytics.instance
            .setCustomKey('user_email', u?.email ?? '');
        await FirebaseCrashlytics.instance.setCustomKey(
            'user_is_anonymous', (u?.isAnonymous ?? true).toString());
      } catch (_) {}
    });

    // Tentar carregar componentes novamente no onReady caso não tenham sido carregados no onInit
    if (firebaseUser.value != null && !loadedOtherControllers) {
      Future.microtask(() {
        _loadOtherComponents(firebaseUser.value);
      });
    }
  }

  updateDisplayName(String displayName) async {
    await firebaseUser.value?.updateProfile(displayName: displayName);
    Get.snackbar("Sucesso", "Nome atualizado com sucesso: $displayName");
    await firebaseUser.value?.reload();
  }

  _loadOtherComponents(User? user) {
    if (user == null) return;
    if (loadedOtherControllers) return;

    // Verificar se todos os controllers estão disponíveis antes de usar
    final bool allControllersReady = Get.isRegistered<CardController>() &&
        Get.isRegistered<FixedAccountsController>() &&
        Get.isRegistered<TransactionController>() &&
        Get.isRegistered<GoalController>();

    if (!allControllersReady) {
      // Se não estão todos prontos, tentar novamente depois
      return;
    }

    try {
      Get.find<CardController>().startCardStream();
      Get.find<FixedAccountsController>().startFixedAccountsStream();
      Get.find<TransactionController>().startTransactionStream();
      Get.find<GoalController>().startGoalStream();
      loadedOtherControllers = true;
    } catch (e) {
      // Se algum controller não estiver disponível, não marca como carregado
      // para tentar novamente depois
      debugPrint('Erro ao carregar componentes: $e');
    }
  }

  _setInitialScreen(User? user) {
    // Evitar navegação desnecessária se já estiver na rota correta
    if (user == null) {
      if (Get.currentRoute != Routes.LOGIN && !isOnboarding) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      // Skip auto-redirect while onboarding
      if (isOnboarding) return;
      if (Get.currentRoute != Routes.HOME &&
          Get.currentRoute != Routes.ONBOARD_WELCOME &&
          Get.currentRoute != Routes.CARD_INTRO &&
          Get.currentRoute != Routes.CARD_SUCCESS &&
          Get.currentRoute != Routes.FIXED_SUCCESS) {
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

      FirebaseCrashlytics.instance.log('Auth.register start');
      FirebaseCrashlytics.instance.setCustomKey('auth_flow', 'email_register');
      FirebaseCrashlytics.instance.setCustomKey('register_email', trimmedEmail);

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
    } on FirebaseAuthException catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'register FirebaseAuthException',
        information: ['email=${email.trim()}'],
      );
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao cadastrar",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'register unexpected error',
        information: ['email=${email.trim()}'],
      );
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
      FirebaseCrashlytics.instance.log('Auth.login start');
      FirebaseCrashlytics.instance.setCustomKey('auth_flow', 'email_login');
      FirebaseCrashlytics.instance.setCustomKey('login_email', email.trim());
      isLoading(true);
      _showLoadingDialog();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Log analytics event
      await _analyticsService.logLogin('email');

      _hideLoadingDialog();
    } on FirebaseAuthException catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'login FirebaseAuthException',
        information: ['email=${email.trim()}'],
      );
      _hideLoadingDialog();
      Get.snackbar(
        "Erro ao entrar",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'login unexpected error',
        information: ['email=${email.trim()}'],
      );
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
    Trace? perfTrace;
    try {
      perfTrace = FirebasePerformance.instance.newTrace('auth_google_login');
      await perfTrace.start();
      FirebaseCrashlytics.instance.log('Auth.loginWithGoogle start');
      FirebaseCrashlytics.instance.setCustomKey('auth_flow', 'google_login');
      isLoading(true);
      _showLoadingDialog();

      // Sign out from Google Sign In first to ensure a fresh sign in
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Ignore if there's no previous session
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _hideLoadingDialog();
        await perfTrace.stop();
        return; // User cancelled, just return without error
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _hideLoadingDialog();
        await perfTrace.stop();
        Get.snackbar(
          "Erro ao entrar com Google",
          "Não foi possível obter as credenciais de autenticação",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      FirebaseCrashlytics.instance
          .setCustomKey('google_email', googleUser.email);
      FirebaseCrashlytics.instance.setCustomKey('google_has_access_token',
          (googleAuth.accessToken != null).toString());
      FirebaseCrashlytics.instance.setCustomKey(
          'google_has_id_token', (googleAuth.idToken != null).toString());

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await FirebaseCrashlytics.instance
          .setUserIdentifier(userCredential.user?.uid ?? '');

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

        // Ensure Firebase Auth displayName is set
        await userCredential.user
            ?.updateProfile(displayName: googleUser.displayName ?? "Usuário");
        await userCredential.user?.reload();
        firebaseUser.value = _auth.currentUser;

        // Log analytics event for new user
        await _analyticsService.logSignUp('google');

        _hideLoadingDialog();
        await perfTrace.stop();
        isOnboarding = true;
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
      await perfTrace.stop();
      if (Get.currentRoute != Routes.HOME) {
        Get.offAllNamed(Routes.HOME);
      }
    } on FirebaseAuthException catch (e, st) {
      try {
        final Trace t =
            FirebasePerformance.instance.newTrace('auth_google_login_error');
        await t.start();
        await t.stop();
      } catch (_) {}
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'google login FirebaseAuthException',
        information: ['stage=signInWithCredential'],
      );
      _hideLoadingDialog();
      if (perfTrace != null) {
        try {
          await perfTrace.stop();
        } catch (_) {}
      }
      Get.snackbar(
        "Erro ao entrar com Google",
        _getAuthErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      try {
        final Trace t = FirebasePerformance.instance
            .newTrace('auth_google_login_unexpected');
        await t.start();
        await t.stop();
      } catch (_) {}
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'google login unexpected error',
        information: ['stage=unknown'],
      );
      _hideLoadingDialog();
      if (perfTrace != null) {
        try {
          await perfTrace.stop();
        } catch (_) {}
      }
      // Don't show error message if user cancelled
      if (e.toString().contains('cancelado') ||
          e.toString().contains('cancelled')) {
        return;
      }
      Get.snackbar(
        "Erro ao entrar com Google",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      FirebaseCrashlytics.instance.log('Auth.logout start');
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
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'logout error');
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
      FirebaseCrashlytics.instance.log('Auth.resetPassword start');
      FirebaseCrashlytics.instance.setCustomKey('reset_email', email.trim());
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
    } on FirebaseAuthException catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'resetPassword FirebaseAuthException',
        information: ['email=${email.trim()}'],
      );
      Get.snackbar(
        "Erro ao redefinir senha",
        _getAuthErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'resetPassword unexpected error',
        information: ['email=${email.trim()}'],
      );
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
      FirebaseCrashlytics.instance.log('Auth.deleteAccount start');
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
    } catch (e, st) {
      print('Error deleting account: $e');
      FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'deleteAccount error');
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
