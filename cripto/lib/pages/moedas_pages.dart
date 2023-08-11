//import 'package:cripto/configs/app_settings.dart';
import 'package:cripto/repositories/language_repository.dart';
import 'package:cripto/repositories/moeda_repository2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import '../models/moeda.dart';
import '../repositories/favorita_repository.dart';
//import '../repositories/moeda_repository.dart';
import 'moeda_detalhes.dart';

class MoedasPage extends StatefulWidget {
  MoedasPage({Key? key}) : super(key: key);

  @override
  _MoedasPageState createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  //final tabela = MoedaRepository.tabela;
  late List<Moeda> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;

  readNumberFormat() {
    //loc = context.watch<AppSettings>().locale;
    loc = context.watch<LanguageRepository>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButtom() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['name'] == 'R\$' ? '\$' : 'R\$';

    return PopupMenuButton(
        icon: Icon(Icons.language),
        itemBuilder: (context) => [
              PopupMenuItem(
                  child: ListTile(
                leading: Icon(Icons.swap_vert),
                title: Text('Usar $locale'),
                onTap: () {
                  //context.read<AppSettings>().setLocale(locale, name);
                  context.read<LanguageRepository>().setLocale(locale, name);
                  Navigator.pop(context);
                },
              )),
            ]);
  }

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: Center(child: Text('Cripto Moedas')),
        actions: [
          changeLanguageButtom(),
        ],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            limparSelecionadas();
          },
        ),
        title: Center(
          child: Text(
            '${selecionadas.length} selecionadas',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedaDetalhes(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  funcRefresh() async {
    await moedas.checkPrecos();
    favoritas.isCheck = true;
  }

  @override
  Widget build(BuildContext context) {
    // favoritas = Provider.of<FavoritasRepository>(context);
    favoritas = context.watch<FavoritasRepository>();
    moedas = context.watch<MoedaRepository>();
    tabela = [];
    tabela = moedas.tabela2;
    readNumberFormat();

    return Scaffold(
      appBar: appBarDinamica(),
      body: RefreshIndicator(
        onRefresh: () => funcRefresh(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int moeda) {
            return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                leading: (selecionadas.contains(tabela[moeda]))
                    ? CircleAvatar(
                        child: Icon(Icons.check),
                      )
                    : SizedBox(
                        child: Image.network(tabela[moeda].icone),
                        width: 40,
                      ),
                title: Row(
                  children: [
                    Text(
                      tabela[moeda].nome,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (favoritas.lista
                        .any((fav) => fav.sigla == tabela[moeda].sigla))
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(Icons.star, color: Colors.amber, size: 8),
                      ),
                  ],
                ),
                trailing: Text(
                  real.format(tabela[moeda].preco),
                  style: TextStyle(fontSize: 15),
                ),
                selected: selecionadas.contains(tabela[moeda]),
                selectedTileColor: Colors.indigo[50],
                onLongPress: () {
                  (selecionadas.isEmpty)
                      ? setState(() {
                          (selecionadas.contains(tabela[moeda]))
                              ? selecionadas.remove(tabela[moeda])
                              : selecionadas.add(tabela[moeda]);
                        })
                      : null;
                },
                onTap: () {
                  (selecionadas.isEmpty)
                      ? mostrarDetalhes(tabela[moeda] as Moeda)
                      : setState(
                          () {
                            (selecionadas.contains(tabela[moeda]))
                                ? selecionadas.remove(tabela[moeda])
                                : selecionadas.add(tabela[moeda]);
                          },
                        );
                });
          },
          padding: EdgeInsets.all(16),
          separatorBuilder: (_, ___) => Divider(),
          itemCount: tabela.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritas.saveAll(selecionadas);
                limparSelecionadas();
              },
              icon: Icon(Icons.star),
              label: Text(
                'FAVORITAR',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
