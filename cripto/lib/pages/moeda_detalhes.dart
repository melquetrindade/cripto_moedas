import 'package:cripto/pages/widget/grafico_historico.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import '../configs/app_settings.dart';
//import '../models/moeda.dart';
import '../repositories/conta_repository.dart';
import '../repositories/language_repository.dart';
import '../repositories/moeda_repository2.dart';

class MoedaDetalhes extends StatefulWidget {
  Moeda moeda;

  MoedaDetalhes({Key? key, required this.moeda}) : super(key: key);

  @override
  _MoedasDetalhesPageState createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedaDetalhes> {
  late NumberFormat real;
  final _form = GlobalKey<FormState>();
  final _valor = TextEditingController();
  double quantidade = 0;
  late ContaRepository conta;
  bool isLoading = false;
  Widget grafico = Container();
  bool graficoLoaded = false;

  getGrafico() {
    if (!graficoLoaded) {
      grafico = GraficoHistorico(moeda: widget.moeda);
      graficoLoaded = true;
    }
    return grafico;
  }

  comprar() async {
    if (_form.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // Salvar a compra
      await conta.comprar(widget.moeda, double.parse(_valor.text));
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra realizada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //conta = context.watch<ContaRepository>();
    conta = Provider.of<ContaRepository>(context, listen: false);
    final loc = context.read<LanguageRepository>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moeda.nome),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        child: Image.network(
                      widget.moeda.icone,
                      scale: 2.5,
                    )),
                    Container(width: 10),
                    Text(
                      real.format(widget.moeda.preco),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              getGrafico(),
              (quantidade > 0)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        child: Text(
                          '$quantidade ${widget.moeda.sigla}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.teal,
                          ),
                        ),
                        margin: EdgeInsets.only(bottom: 24),
                        alignment: Alignment.center,
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(bottom: 24),
                    ),
              Form(
                key: _form,
                child: TextFormField(
                  controller: _valor,
                  style: TextStyle(fontSize: 22),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Valor',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                    suffix: Text(
                      'reais',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Informe o valor da compra';
                    } else if (double.parse(value) < 50) {
                      return 'Compra mínima é R\$ 50,00';
                    } else if (double.parse(value) > conta.saldo) {
                      return 'Saldo insuficiente';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      quantidade = (value.isEmpty)
                          ? 0
                          : double.parse(value) / widget.moeda.preco;
                    });
                  },
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: comprar,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (isLoading)
                        ? [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ]
                        : [
                            Icon(Icons.check),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Comprar',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
