import 'package:cripto/repositories/favorita_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart';

class AuthException implements Exception {
  String message;

  AuthException({required this.message});
}

class AuthServices extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthServices() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;;
    notifyListeners();
  }

  registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException(message: 'A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException(message: 'Este email já está cadastrado');
      }
    }
  }

  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException(message: 'E-mail não encontrado. Cadastre-se!');
      } else if (e.code == 'wrong-password') {
        throw AuthException(message: 'Senha incorreta. Tente novamente!');
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
