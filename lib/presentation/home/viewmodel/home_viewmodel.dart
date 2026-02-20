import 'package:flutter/material.dart';

class HomeViewModel {
  void navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushNamed('/dashboard');
  }

  void navigateToCadastro(BuildContext context) {
    Navigator.of(context).pushNamed('/cadastro');
  }
}
