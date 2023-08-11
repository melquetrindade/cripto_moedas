import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto/services/auth_services.dart';
import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:provider/provider.dart';
//import '../adapter/moeda_hive_adapter.dart';
import '../database/db_firestore.dart';
//import '../models/moeda.dart';
import 'moeda_repository2.dart';

class FavoritasRepository extends ChangeNotifier {
  List<Moeda> _lista = [];
  late FirebaseFirestore db;
  late AuthServices auth;
  MoedaRepository moedas;
  bool isCheck = false;

  FavoritasRepository({required this.auth, required this.moedas}) {
    _startRepository();
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  _startRepository() async {
    await _startFirestore();
    await readFavoritas();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  setLista() {
    _lista = [];
  }

  refreshFavoritas() {
    _lista = [];
    readFavoritas();
  }

  readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      if (moedas.tabela2.isEmpty) {
        await moedas.readMoedasTable();
      }

      snapshot.docs.forEach((doc) {
        Moeda moeda =
            moedas.tabela2.firstWhere((m) => m.sigla == doc.get('sigla'));
        _lista.add(moeda);
      });
      isCheck = false;
      notifyListeners();
    }
  }

  saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco
        });
      }
    });
    notifyListeners();
  }

  remove(Moeda moeda) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();
    _lista.remove(moeda);
    notifyListeners();
  }
}
