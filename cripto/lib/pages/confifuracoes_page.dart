import 'package:cripto/repositories/conta_repository.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:cripto/repositories/language_repository.dart';
import 'package:cripto/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'documentos_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    final conta = context.watch<ContaRepository>();
    final loc = context.read<LanguageRepository>().locale;
    final test = context.read<FavoritasRepository>();

    NumberFormat real =
        NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Configurações'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: Text('Saldo'),
              subtitle: Text(
                real.format(conta.saldo),
                style: TextStyle(fontSize: 25, color: Colors.indigo),
              ),
              trailing:
                  IconButton(onPressed: udpateSaldo, icon: Icon(Icons.edit)),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Escanear CNH ou RG'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentosPage(), fullscreenDialog: true)),
            ),
            Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: OutlinedButton(
                      onPressed: () {
                        test.setLista();
                        conta.limpaConta();
                        context.read<AuthServices>().logout();
                      },
                      style: OutlinedButton.styleFrom(primary: Colors.red),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Sair do App',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  udpateSaldo() async {
    final form = GlobalKey<FormState>();
    final valor = TextEditingController();
    final conta = context.read<ContaRepository>();

    valor.text = conta.saldo.toString();

    AlertDialog dialog = AlertDialog(
      title: Text('Atualizar o Saldo'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: valor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
          ],
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe o valor do Saldo';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('CANCELAR')),
        TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                conta.setSaldo(double.parse(valor.text));
                Navigator.pop(context);
              }
            },
            child: Text('SALVAR')),
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }
}
