import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/moeda.dart';

class MoedaDetalhes extends StatefulWidget {
  Moeda moeda;

  MoedaDetalhes({super.key, required this.moeda});

  @override
  State<MoedaDetalhes> createState() => _MoedaDetalhesState();
}

class _MoedaDetalhesState extends State<MoedaDetalhes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moeda.nome),
      ),
    );
  }
}
