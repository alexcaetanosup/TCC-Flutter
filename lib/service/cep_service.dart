// lib/services/cep_service.dart
import 'package:dio/dio.dart';
import '../model/endereco_model.dart';

class CepService {
  final Dio _dio = Dio();
  // URL base da ViaCEP. O {cep} será substituído.
  static const String _baseUrl = 'https://viacep.com.br/ws/';

  // Função assíncrona para consultar o CEP
  Future<EnderecoModel> buscarCep(String cep) async {
    // 1. Limpeza do CEP: Remove caracteres não numéricos
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Monta a URL da API
    final url = '$_baseUrl$cepLimpo/json/';

    try {
      // 3. Comunicação com Backend (Requisição HTTP GET)
      final response = await _dio.get(url);

      // Verifica se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // 4. Tratamento de Erro: A ViaCEP retorna um campo 'erro' se o CEP não for encontrado
        if (data.containsKey('erro') && data['erro'] == true) {
          throw Exception('CEP não encontrado ou inválido.');
        }

        // 5. Uso dos Dados: Converte o JSON em um objeto EnderecoModel
        return EnderecoModel.fromJson(data);
      } else {
        // Erros de servidor HTTP (4xx, 5xx)
        throw Exception(
          'Falha ao carregar endereço. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Erro de rede ou timeout
      throw Exception('Erro de comunicação com a API: ${e.message}');
    } catch (e) {
      // Outros erros
      rethrow;
    }
  }
}
