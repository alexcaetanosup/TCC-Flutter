// lib/main_scaffold.dart

import 'package:flutter/material.dart';
import 'screen/historico_screen.dart';
import 'screen/busca_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Novo método para mudar o índice da aba
  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inicializa a lista de telas, passando o callback para BuscaScreen
    _widgetOptions = <Widget>[
      // O callback onCepFound() chama _goToTab(1), que é a tela Histórico
      BuscaScreen(onCepFound: () => _goToTab(1)),
      const HistoricoScreen(),
    ];
  }

  void _onItemTapped(int index) {
    _goToTab(index); // Usa o novo método para mudar o estado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar CEP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
