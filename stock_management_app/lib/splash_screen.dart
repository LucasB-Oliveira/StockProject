import 'package:flutter/material.dart';
import 'package:stock_management_app/main.dart'; // Importa a HomePage para navegar após a tela de abertura

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navega para a tela principal após 5 segundos
    Future.delayed(const Duration(seconds: 3), () {
      // Verifica se o widget ainda está montado antes de navegar
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // Fundo preto
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'), // Caminho da imagem
          width: 1100, // Ajuste o tamanho conforme necessário
          height: 1100, // Ajuste o tamanho conforme necessário
          fit: BoxFit.contain, // Para manter a proporção
        ),
      ),
    );
  }
}