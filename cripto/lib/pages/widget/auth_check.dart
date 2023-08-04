import 'package:cripto/pages/home_page.dart';
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
    AuthServices auth = Provider.of<AuthServices>(context);

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
