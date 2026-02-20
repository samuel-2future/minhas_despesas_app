import 'package:flutter/material.dart';
import 'package:minhas_despesas_app/presentation/cadastro/view/cadastro_view.dart';
import 'package:minhas_despesas_app/presentation/dashboard/view/dashboard_view.dart';
import 'package:minhas_despesas_app/presentation/home/view/home_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String cadastro = '/cadastro';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroView());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página não encontrada')),
            body: const Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}
