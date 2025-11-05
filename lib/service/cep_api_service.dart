// lib/service/cep_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/endereco_model.dart'; // Ajuste o caminho se necessário

class CepApiService {
  // O método de busca de CEP na API do ViaCEP
  Future<EnderecoModel> fetchCep(String cep) async {
    final uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Verifica se a API retornou erro (CEP não existe)
      if (data.containsKey('erro') && data['erro'] == true) {
        throw Exception('CEP não encontrado ou inválido.');
      }

      // Converte o JSON para EnderecoModel
      return EnderecoModel.fromJson(data);
    } else {
      throw Exception('Falha ao carregar CEP. Status: ${response.statusCode}');
    }
  }
}
