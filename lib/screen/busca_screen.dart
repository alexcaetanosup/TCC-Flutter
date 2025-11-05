import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../service/cep_api_service.dart';
import '../model/endereco_model.dart';

class BuscaScreen extends StatelessWidget {
  // NOVO: Adiciona um campo de callback (função)
  final VoidCallback onCepFound;

  // NOVO: Construtor que requer o callback
  const BuscaScreen({required this.onCepFound, super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    final CepApiService cepService = CepApiService();

    final TextEditingController cepController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Via CEP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // O INPUT DE CEP
              TextField(
                controller: cepController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'Digite o CEP (apenas números)',
                  hintText: 'Ex: 01001000',
                  counterText: '',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 20),
              // BOTÃO DE BUSCA
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Buscar CEP'),
                onPressed: () async {
                  final cep = cepController.text.trim();

                  if (cep.length == 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Buscando CEP $cep...')),
                    );

                    try {
                      final EnderecoModel endereco = await cepService.fetchCep(
                        cep,
                      );

                      await firebaseService.salvarEndereco(endereco);

                      cepController.clear();

                      // CHAMA O CALLBACK PARA MUDAR DE TELA
                      onCepFound();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'CEP salvo no histórico e tela atualizada!',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro na busca: ${e.toString().split(':').last.trim()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CEP deve ter 8 dígitos.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
