import 'package:cripto/pages/home_page.dart';
import 'package:cripto/repositories/conta_repository.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:cripto/repositories/language_repository.dart';
import 'package:cripto/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import '../login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    //AuthServices auth = Provider.of<AuthServices>(context);
    AuthServices auth = context.watch<AuthServices>();

    //context.read<FavoritasRepository>().setLista();
    //context.read<LanguageRepository>().readLocale();
    //context.read<ContaRepository>().limpaConta();

    if (auth.usuario != null && auth.isConfLogout == true) {
      context.read<FavoritasRepository>().readFavoritas();
      context.read<LanguageRepository>().readLocale();
      context.read<ContaRepository>().initRepository();
      auth.isConfLogout = false;
    }

    if (auth.isLoading) {
      return loading();
    } else if (auth.usuario == null) {
      return LoginPage();
    } else {
      return HomePage();
    }
  }

  loading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
