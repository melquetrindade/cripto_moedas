import 'package:cripto/pages/widget/auth_check.dart';
import 'package:cripto/repositories/conta_repository.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:cripto/repositories/language_repository.dart';
import 'package:cripto/repositories/moeda_repository2.dart';
import 'package:cripto/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'configs/hive_config.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();
   
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthServices()),
      ChangeNotifierProvider(create: (context) => MoedaRepository(auth: context.read<AuthServices>())),
      ChangeNotifierProvider(create: (context) => ContaRepository(auth: context.read<AuthServices>(), moedas: context.read<MoedaRepository>())),
      //ChangeNotifierProvider(create: (context) => AppSettings()),
      ChangeNotifierProvider(create: (context) => LanguageRepository(auth: context.read<AuthServices>())),
      ChangeNotifierProvider(create: (context) => FavoritasRepository(
        auth: context.read<AuthServices>(),
        moedas: context.read<MoedaRepository>()
      )),
    ],
    child: MyApp(),
    
  ));
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
      home: AuthCheck(),
    );
  }
}
