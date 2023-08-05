import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../database/db_firestore.dart';
import '../services/auth_services.dart';

class LanguageRepository extends ChangeNotifier {
  Map<String, String> locale = {'locale': 'pt_BR', 'name': 'R\$'};
  late FirebaseFirestore db;
  late AuthServices auth;

  LanguageRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readLocale();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  _readLocale() async {

    final language = await db
        .collection('usuarios/${auth.usuario!.uid}/preferencia')
        .doc('language')
        .get();

    if(!language.exists){
      await db
        .collection('usuarios/${auth.usuario!.uid}/preferencia')
        .doc('language')
        .set({
        'local': 'pt_BR',
        'name': 'R\$',
      });
    }

    locale = {
      'locale': language['local'] ?? 'pt_BR',
      'name': language['name'] ?? 'R\$',
    };
    notifyListeners();
  }

  setLocale(String local, String name) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/preferencia')
        .doc('language')
        .update({'local': local, 'name': name});
    await _readLocale();
  }
}
