import 'package:cripto/pages/moeda_detalhes.dart';
import 'package:cripto/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../models/moeda.dart';

class MoedasPage extends StatefulWidget {
  MoedasPage({super.key});

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  final tabela = MoedaRepository().tabela;

  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');

  List<Moeda> selecionadas = [];

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(title: Center(child: Text('Cripto Moedas')));
    }
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            selecionadas = [];
          });
        },
      ),
      title: Center(
          child: Text(
        '${selecionadas.length} selecionadas',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      )),
      backgroundColor: Colors.blueGrey[50],
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black87),
    );
  }

  moedaDetalhes(Moeda moeda) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => MoedaDetalhes(moeda: moeda)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarDinamica(),
        body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                leading: (selecionadas.contains(tabela[index]))
                    ? CircleAvatar(child: Icon(Icons.check))
                    : SizedBox(
                        child: Image.asset(tabela[index].icone),
                        width: 40,
                      ),
                title: Text(
                  tabela[index].nome,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(real.format(tabela[index].preco)),
                selected: selecionadas.contains(tabela[index]),
                selectedTileColor: Colors.indigo[50],
                onLongPress: () {
                  (selecionadas.isEmpty)
                      ? setState(() {
                          (selecionadas.contains(tabela[index]))
                              ? selecionadas.remove(tabela[index])
                              : selecionadas.add(tabela[index]);
                        })
                      : null;
                },
                onTap: () {
                  (selecionadas.isEmpty)
                      ? moedaDetalhes(tabela[index])
                      : setState(
                          () {
                            (selecionadas.contains(tabela[index]))
                                ? selecionadas.remove(tabela[index])
                                : selecionadas.add(tabela[index]);
                          },
                        );
                });
          },
          padding: EdgeInsets.all(16),
          separatorBuilder: (_, __) => Divider(),
          itemCount: tabela.length,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (selecionadas.isNotEmpty)
            ? FloatingActionButton.extended(
                icon: Icon(Icons.star),
                onPressed: () {},
                label: Text('FAVORITAR'))
            : null);
  }
}
