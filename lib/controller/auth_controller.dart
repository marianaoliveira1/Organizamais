// auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> registerWithEmail(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      Get.snackbar('Sucesso', 'Cadastro realizado com sucesso!');
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro no cadastro';
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este email já está em uso';
      }
      Get.snackbar('Erro', message);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar('Sucesso', 'Login realizado com sucesso!');
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro no login';
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta';
      }
      Get.snackbar('Erro', message);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save Google user data to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': googleUser.displayName,
          'email': googleUser.email,
          'createdAt': DateTime.now(),
        });
      }

      Get.snackbar('Sucesso', 'Login com Google realizado com sucesso!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao fazer login com Google');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed('/login');
  }
}
