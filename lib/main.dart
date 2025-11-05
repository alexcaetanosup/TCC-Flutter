import 'package:flutter/material.dart';
// 1. IMPORTAR O PACOTE FIREBASE CORE
import 'package:firebase_core/firebase_core.dart';
import 'main_scaffold.dart';

// Adicione 'async' para que possamos esperar pela inicialização do Firebase
void main() async {
  // 2. GARANTIR QUE OS WIDGETS ESTEJAM PRONTOS
  WidgetsFlutterBinding.ensureInitialized();

  // 3. INICIALIZAR O FIREBASE DE FORMA ASSÍNCRONA
  // Se você usa o FlutterFire CLI (firebase_options.dart), use-o aqui.
  // Caso contrário, use a versão simples: await Firebase.initializeApp();
  await Firebase.initializeApp();

  runApp(const CepFacilApp());
}

class CepFacilApp extends StatelessWidget {
  const CepFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEP Fácil',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScaffold(),
    );
  }
}
