import 'package:cripto/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MoedasPage extends StatelessWidget {
  const MoedasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabela = MoedaRepository().tabela;

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Cripto Moedas'))),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Image.asset(tabela[index].icone),
              title: Text(tabela[index].nome),
              trailing: Text(tabela[index].preco.toString()),
            );
          },
          padding: EdgeInsets.all(16),
          separatorBuilder: (_, __) => Divider(),
          itemCount: tabela.length),
    );
  }
}
