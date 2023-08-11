import 'package:cripto/pages/home_page.dart';
import 'package:cripto/repositories/conta_repository.dart';
import 'package:cripto/repositories/favorita_repository.dart';
import 'package:cripto/repositories/language_repository.dart';
import 'package:cripto/services/auth_services.dart';
import 'package:flutter/material.dart';
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

    if (auth.usuario != null && auth.isConfLogout == true) {
      context.read<ContaRepository>().initRepository();
      context.read<LanguageRepository>().readLocale();
      context.read<FavoritasRepository>().readFavoritas();
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
