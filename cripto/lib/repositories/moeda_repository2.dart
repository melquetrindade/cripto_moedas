import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto/pages/favoritas_page.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../database/db.dart';
import '../database/db_firestore.dart';
import '../services/auth_services.dart';

class Moeda {
  String baseId;
  String icone;
  String nome;
  String sigla;
  double preco;
  DateTime timestamp;
  double mudancaHora;
  double mudancaDia;
  double mudancaSemana;
  double mudancaMes;
  double mudancaAno;
  double mudancaPeriodoTotal;

  Moeda(
      {required this.baseId,
      required this.icone,
      required this.nome,
      required this.sigla,
      required this.preco,
      required this.timestamp,
      required this.mudancaHora,
      required this.mudancaDia,
      required this.mudancaSemana,
      required this.mudancaMes,
      required this.mudancaAno,
      required this.mudancaPeriodoTotal});
}

class MoedaRepository extends ChangeNotifier {
  List<Moeda> _tabela2 = [];
  late FirebaseFirestore db2;
  late AuthServices auth;
  late Timer intervalo;

  List<Moeda> get tabela2 => _tabela2;

  MoedaRepository({required this.auth}) {
    _initRepository();
    _refreshPrecos();
  }

  _initRepository() async {
    await _startFirestore();
    await iniciarState();
    await readMoedasTable();
  }

  _refreshPrecos() async {
    intervalo = Timer.periodic(Duration(minutes: 5), (_) => checkPrecos());
  }

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/prices?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];
      final snapshotFav =
          await db2.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      _tabela2.forEach((atual) async {
        moedas.forEach((novo) async {
          if (atual.baseId == novo['base_id']) {
            final moeda = novo['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            await db2
                .collection('usuarios/${auth.usuario!.uid}/moedasRep')
                .doc(atual.sigla)
                .update({
              'preco': moeda['latest'],
              'timestamp': timestamp.millisecondsSinceEpoch,
              'mudancaHora': preco['percent_change']['hour'].toString(),
              'mudancaDia': preco['percent_change']['day'].toString(),
              'mudancaSemana': preco['percent_change']['week'].toString(),
              'mudancaMes': preco['percent_change']['month'].toString(),
              'mudancaAno': preco['percent_change']['year'].toString(),
              'mudancaPeriodoTotal': preco['percent_change']['all'].toString(),
            });
          }
        });
      });

      snapshotFav.docs.forEach((atual) async {
        moedas.forEach((novo) async {
          if (atual['sigla'] == novo['base']) {
            final moeda = novo['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            await db2
                .collection('usuarios/${auth.usuario!.uid}/favoritas')
                .doc(atual['sigla'])
                .update({
              'preco': moeda['latest'],
            });
          }
        });
      });
      readMoedasTable();
    }
  }

  getHistoricoMoeda(Moeda moeda) async {
    final response = await http.get(Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${moeda.baseId}?base=BRL'));

    List<Map<String, dynamic>> precos = [];
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> moeda = json['data']['prices'];

      precos.add(moeda['hour']);
      precos.add(moeda['day']);
      precos.add(moeda['week']);
      precos.add(moeda['month']);
      precos.add(moeda['year']);
      precos.add(moeda['all']);
    }

    return precos;
  }

  readMoedasTable() async {
    final snapshot =
        await db2.collection('usuarios/${auth.usuario!.uid}/moedasRep').get();
    _tabela2 = [];
    snapshot.docs.forEach((doc) {
      _tabela2.add(Moeda(
        baseId: doc['baseId'],
        sigla: doc['sigla'],
        nome: doc['nome'],
        icone: doc['icone'],
        preco: double.parse(doc['preco']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(doc['timestamp']),
        mudancaHora: double.parse(doc['mudancaHora']),
        mudancaDia: double.parse(doc['mudancaDia']),
        mudancaSemana: double.parse(doc['mudancaSemana']),
        mudancaMes: double.parse(doc['mudancaMes']),
        mudancaAno: double.parse(doc['mudancaAno']),
        mudancaPeriodoTotal: double.parse(doc['mudancaPeriodoTotal']),
      ));
    });
    notifyListeners();
  }

  _startFirestore() {
    db2 = DBFirestore.get();
  }

  iniciarState() async {
    final qtd =
        await db2.collection('usuarios/${auth.usuario!.uid}/moedasRep').get();

    if (qtd.docs.isEmpty) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> moedas = json['data'];

        moedas.forEach((moeda) async {
          final preco = moeda['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          await db2
              .collection('usuarios/${auth.usuario!.uid}/moedasRep')
              .doc(moeda['symbol'])
              .set({
            'baseId': moeda['id'],
            'sigla': moeda['symbol'],
            'nome': moeda['name'],
            'icone': moeda['image_url'],
            'preco': moeda['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'mudancaHora': preco['percent_change']['hour'].toString(),
            'mudancaDia': preco['percent_change']['day'].toString(),
            'mudancaSemana': preco['percent_change']['week'].toString(),
            'mudancaMes': preco['percent_change']['month'].toString(),
            'mudancaAno': preco['percent_change']['year'].toString(),
            'mudancaPeriodoTotal': preco['percent_change']['all'].toString(),
          });
        });
      }
    }
  }
}
