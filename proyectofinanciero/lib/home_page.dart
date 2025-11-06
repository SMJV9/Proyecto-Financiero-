import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'transactions_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Registrar un evento simple al abrir la pantalla
    FirebaseAnalytics.instance.logEvent(
      name: 'home_page_open',
      parameters: {'description': 'Usuario abrió HomePage'},
    );

    return const TransactionsPage();
  }
}
