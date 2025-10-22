import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Registrar un evento simple al abrir la pantalla
    FirebaseAnalytics.instance.logEvent(
      name: 'home_page_open',
      parameters: {'description': 'Usuario abrió HomePage'},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de mi App'),
      ),
      body: const Center(
        child: Text(
          'Firebase conectado correctamente',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}