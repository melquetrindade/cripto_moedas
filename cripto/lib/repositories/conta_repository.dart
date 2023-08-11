import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
//import '../database/db.dart';
import '../database/db_firestore.dart';
import '../models/historico.dart';
//import '../models/moeda.dart';
import '../models/posicao.dart';
import '../services/auth_services.dart';
import 'moeda_repository2.dart';

class ContaRepository extends ChangeNotifier {
  //late Database db;
  late FirebaseFirestore db;
  late AuthServices auth;
  List<Posicao> _carteira = [];
  List<Historico> _historico = [];
  double _saldo = 0;
  MoedaRepository moedas;

  get saldo => _saldo;
  List<Posicao> get carteira => _carteira;
  List<Historico> get historico => _historico;

  ContaRepository({required this.auth, required this.moedas}) {
    initRepository2();
  }

  initRepository2() async {
    await _startFirestore();
    await initRepository();
  }

  initRepository() async {
    await _getSaldo();
    await _getCarteira();
    await _getHistorico();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  limpaConta() {
    _carteira = [];
    _historico = [];
    _saldo = 0;
  }

  _getSaldo() async {
    //db = await DB.instance.database;
    //List conta = await db.query('conta', limit: 1);

    final hasSaldo = await db
        .collection('usuarios/${auth.usuario!.uid}/contaDoc')
        .doc('conta')
        .get();

    if (!hasSaldo.exists) {
      _saldo = 0;
    } else {
      _saldo = hasSaldo['saldo'];
    }
    notifyListeners();
  }

  setSaldo(double valor) async {

    //db = await DB.instance.database;
    //db.update('conta', {
    //  'saldo': valor,
    //});
    //_saldo = valor;
    //notifyListeners();

    final hasSaldo = await db
        .collection('usuarios/${auth.usuario!.uid}/contaDoc')
        .doc('conta')
        .get();

    if (!hasSaldo.exists) {
      await db
          .collection('usuarios/${auth.usuario!.uid}/contaDoc')
          .doc('conta')
          .set({'saldo': valor});
    } else {
      await db
          .collection('usuarios/${auth.usuario!.uid}/contaDoc')
          .doc('conta')
          .update({'saldo': valor});
    }
    _saldo = valor;
    notifyListeners();
  }

  comprar(Moeda moeda, double valor) async {

    //db = await DB.instance.database;
    //await db.transaction((txn) async {
    //  // verificar se a moeda já foi comprada
    //  final posicaoMoeda = await txn
    //      .query('carteira', where: 'sigla = ?', whereArgs: [moeda.sigla]);
    //  // se não tem moeda em carteira
    //  if (posicaoMoeda.isEmpty) {
    //    await txn.insert('carteira', {
    //      'sigla': moeda.sigla,
    //      'moeda': moeda.nome,
    //      'quantidade': (valor / moeda.preco).toString()
    //    });
    //  }
    //  // já tem a moeda em carteira
    //  else {
    //    final atual = double.parse(posicaoMoeda.first['quantidade'].toString());
    //    await txn.update(
    //        'carteira',
    //        {
    //          'quantidade': (atual + (valor / moeda.preco)).toString(),
    //        },
    //        where: 'saldo = ?',
    //        whereArgs: [moeda.sigla]);
    //  }

    // verificar se a moeda já foi comprada
    final posicao = await db
        .collection('usuarios/${auth.usuario!.uid}/carteira')
        .doc(moeda.sigla)
        .get();
    // se não tem a moeda em carteira
    if (!posicao.exists) {
      await db
          .collection('usuarios/${auth.usuario!.uid}/carteira')
          .doc(moeda.sigla)
          .set({
        'sigla': moeda.sigla,
        'moeda': moeda.nome,
        'quantidade': (valor / moeda.preco).toString()
      });
    }
    // já tem a moeda em carteira
    else {
      final atual = posicao['quantidade'];
      await db
          .collection('usuarios/${auth.usuario!.uid}/carteira')
          .doc(moeda.sigla)
          .update({
        'quantidade': (double.parse(atual) + (valor / moeda.preco)).toString(),
      });
    }

    // Inserir a compra no histórico
    final qtd =
        await db.collection('usuarios/${auth.usuario!.uid}/historico').get();

    await db
        .collection('usuarios/${auth.usuario!.uid}/historico')
        .doc((qtd.size + 1).toString())
        .set({
      'sigla': moeda.sigla,
      'moeda': moeda.nome,
      'quantidade': (valor / moeda.preco).toString(),
      'valor': valor,
      'tipo_operacao': 'compra',
      'data_operacao': DateTime.now().millisecondsSinceEpoch
    });

    // Atualizar o saldo
    await db
        .collection('usuarios/${auth.usuario!.uid}/contaDoc')
        .doc('conta')
        .update({
      'saldo': saldo - valor,
    });

    //  await txn.insert('historico', {
    //    'sigla': moeda.sigla,
    //    'moeda': moeda.nome,
    //    'quantidade': (valor / moeda.preco).toString(),
    //    'valor': valor,
    //    'tipo_operacao': 'compra',
    //    'data_operacao': DateTime.now().millisecondsSinceEpoch
    //  });

    //  await txn.update('conta', {'saldo': saldo - valor});
    //});

    await initRepository();
    notifyListeners();
  }

  _getCarteira() async {

    //_carteira = [];
    //List posicoes = await db.query('carteira');
    //posicoes.forEach((posicao) {
    //  Moeda moeda =
    //      MoedaRepository.tabela.firstWhere((m) => m.sigla == posicao['sigla']);
    //  _carteira.add(Posicao(
    //      moeda: moeda, quantidade: double.parse(posicao['quantidade'])));
    //});
    //notifyListeners();

    _carteira = [];
    final posicoes =
        await db.collection('usuarios/${auth.usuario!.uid}/carteira').get();
    posicoes.docs.forEach((doc) {
      Moeda moeda =
          moedas.tabela2.firstWhere((m) => m.sigla == doc.get('sigla'));
      _carteira.add(Posicao(
          moeda: moeda, quantidade: double.parse(doc.get('quantidade'))));
    });
    notifyListeners();
  }

  _getHistorico() async {
    
    //_historico = [];
    //List operacoes = await db.query('historico');
    //operacoes.forEach((operacao) {
    //  Moeda moeda = MoedaRepository.tabela
    //      .firstWhere((m) => m.sigla == operacao['sigla']);
    //  _historico.add(Historico(
    //      dataOperacao:
    //          DateTime.fromMillisecondsSinceEpoch(operacao['data_operacao']),
    //      tipoOperacao: operacao['tipo_operacao'],
    //      moeda: moeda,
    //      valor: operacao['valor'],
    //      quantidade: double.parse(operacao['quantidade'])));
    //});
    //notifyListeners();

    _historico = [];
    final operacoes =
        await db.collection('usuarios/${auth.usuario!.uid}/historico').get();

    operacoes.docs.forEach((doc) {
      Moeda moeda =
          moedas.tabela2.firstWhere((m) => m.sigla == doc.get('sigla'));
      _historico.add(Historico(
          dataOperacao:
              DateTime.fromMillisecondsSinceEpoch(doc.get('data_operacao')),
          tipoOperacao: doc.get('tipo_operacao'),
          moeda: moeda,
          valor: doc.get('valor'),
          quantidade: double.parse(doc.get('quantidade'))));
    });
    notifyListeners();
  }
}
