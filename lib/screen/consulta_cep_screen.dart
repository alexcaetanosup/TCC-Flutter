import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../model/endereco_model.dart';
import '../service/cep_service.dart';
import '../service/firebase_service.dart';
import 'historico_screen.dart';

class ConsultaCepScreen extends StatefulWidget {
  const ConsultaCepScreen({super.key});

  @override
  State<ConsultaCepScreen> createState() => _ConsultaCepScreenState();
}

class _ConsultaCepScreenState extends State<ConsultaCepScreen> {
  final TextEditingController _cepController = TextEditingController();
  final CepService _cepService = CepService();
  // Nome da classe de serviço do Firebase corrigido
  final FirebaseService _firebaseService = FirebaseService();
  EnderecoModel? _endereco;
  bool _isLoading = false;
  String? _errorMessage;

  // Formatter para o campo de CEP (formato 99999-999)
  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // CORREÇÃO 3: Lógica de carregamento refatorada com 'finally'
  Future<void> _consultarCep() async {
    final cep = _cepController.text.replaceAll('-', '');

    if (cep.length < 8) {
      setState(() {
        _errorMessage = 'Por favor, insira um CEP válido com 8 dígitos.';
        _endereco = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _endereco = null;
    });

    try {
      final endereco = await _cepService.buscarCep(cep);

      setState(() {
        _endereco = endereco;
      });

      // Salva a consulta no Firebase
      await _firebaseService.salvarEndereco(endereco);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('CEP não encontrado')
            ? 'CEP não encontrado.'
            : 'Erro na consulta: Verifique sua conexão ou tente novamente.';
      });
    } finally {
      // Garante que _isLoading seja false, mesmo em caso de erro
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _limpar() {
    setState(() {
      _cepController.clear();
      _endereco = null;
      _errorMessage = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de CEP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoricoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Campo de Texto do CEP ---
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite o CEP (apenas números)',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              inputFormatters: [_cepMaskFormatter],
              onSubmitted: (_) => _consultarCep(),
            ),

            const SizedBox(height: 16),

            // --- Botões ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _consultarCep,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Consultar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limpar,
                    child: const Text('Limpar'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- Resultado da Consulta ---
            if (_endereco != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultado da Consulta:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('CEP', _endereco!.cep),
                      _buildInfoRow('Logradouro', _endereco!.logradouro),
                      _buildInfoRow('Complemento', _endereco!.complemento),
                      _buildInfoRow('Bairro', _endereco!.bairro),
                      _buildInfoRow(
                        'Localidade',
                        '${_endereco!.localidade}/${_endereco!.uf}',
                      ),
                      _buildInfoRow('DDD', _endereco!.ddd),
                    ],
                  ),
                ),
              ),

            if (_endereco == null && !_isLoading && _errorMessage == null)
              const Center(
                child: Text(
                  'Aguardando a consulta do CEP.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }
}
