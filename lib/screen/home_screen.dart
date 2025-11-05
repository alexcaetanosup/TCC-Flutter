import 'package:cep_facil/service/firebase_service.dart';
import 'package:flutter/material.dart';
import '../model/endereco_model.dart';
// Se você tiver um serviço de busca de CEP (ex: ViaCEP), importe-o aqui
// import 'package:cep_facil/service/cep_api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // =================================================================
  // MÉTODO AUXILIAR 1: Diálogo para confirmar a limpeza do histórico
  // =================================================================
  Future<void> _showConfirmClearDialog(
    BuildContext context,
    FirebaseService service,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Limpeza'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Tem certeza que deseja apagar todo o histórico de consultas de CEP?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Limpar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await service.limparHistorico();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Histórico limpo com sucesso!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Falha ao limpar histórico: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // =================================================================
  // MÉTODO AUXILIAR 2: Diálogo para abrir o input de pesquisa de CEP
  // =================================================================
  Future<void> _showSearchDialog(
    BuildContext context,
    FirebaseService firebaseService,
    // Se for usar outro serviço, adicione-o aqui, ex:
    // CepApiService cepService,
  ) async {
    final TextEditingController cepController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Buscar Novo CEP'),
          content: TextField(
            controller: cepController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(
              labelText: 'Digite o CEP (apenas números)',
              hintText: 'Ex: 01001000',
              counterText: '',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Buscar'),
              onPressed: () async {
                final cep = cepController.text.trim();
                Navigator.of(dialogContext).pop();

                if (cep.length == 8) {
                  // TODO: Lógica REAL DE BUSCA E SALVAMENTO DE CEP AQUI

                  // Mensagem de feedback temporária
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Buscando CEP: $cep...')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CEP deve ter 8 dígitos.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // =================================================================
  // MÉTODO build: Constrói a UI principal da tela
  // =================================================================
  @override
  Widget build(BuildContext context) {
    // Instância do serviço Firebase (para histórico)
    final FirebaseService firebaseService = FirebaseService();
    // Instância do serviço de busca de CEP (Se for o caso)
    // final CepApiService cepService = CepApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEP Fácil (Histórico)'),
        // Botão para Limpar Histórico
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar Histórico',
            // Chama o diálogo, passando a instância do serviço
            onPressed: () => _showConfirmClearDialog(context, firebaseService),
          ),
        ],
      ),

      // Corpo da tela: StreamBuilder para exibir o histórico em tempo real
      body: StreamBuilder<List<EnderecoModel>>(
        stream: firebaseService.listarHistorico(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar histórico: ${snapshot.error}'),
            );
          }

          final historico = snapshot.data;

          if (historico == null || historico.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma consulta salva no histórico. Use a lupa para pesquisar!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Lista de histórico
          return ListView.builder(
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final endereco = historico[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(
                    endereco.logradouro.isNotEmpty
                        ? '${endereco.logradouro}, ${endereco.localidade} - ${endereco.uf}'
                        : '${endereco.localidade} - ${endereco.uf}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'CEP: ${endereco.cep}\nBairro: ${endereco.bairro}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),

      // Botão Flutuante (FAB) para abrir o input de pesquisa
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchDialog(
          context,
          firebaseService,
          // Se for o caso, passe o cepService aqui também
          // cepService,
        ),
        tooltip: 'Buscar novo CEP',
        child: const Icon(Icons.search),
      ),
    );
  }
}
