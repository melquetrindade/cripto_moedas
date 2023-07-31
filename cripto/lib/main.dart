import 'package:cripto/configs/app_settings.dart';
import 'package:cripto/pages/home_page.dart';
import 'package:cripto/pages/moedas_pages.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AppSettings()),
      ChangeNotifierProvider(create: (context) => FavoritasRepository()),
    ],
    child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CriptoMoedas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(),
    );
  }
}
