class EnderecoModel {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;
  // NOVOS CAMPOS:
  final String complemento;
  final String ddd;

  final String? id;
  final DateTime? timestamp;

  EnderecoModel({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    // INCLUIR NOS REQUERIDOS
    required this.complemento,
    required this.ddd,
    this.id,
    this.timestamp,
  });

  // Construtor para leitura da API (ViaCEP)
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      cep: json['cep']?.replaceAll('-', '') ?? '',
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      // Mapeamento dos novos campos da API
      complemento: json['complemento'] ?? '',
      ddd: json['ddd'] ?? '',
    );
  }

  // Construtor para leitura do Firestore
  factory EnderecoModel.fromFirestore(Map<String, dynamic> map, String id) {
    return EnderecoModel(
      id: id,
      cep: map['cep'] ?? '',
      logradouro: map['logradouro'] ?? '',
      bairro: map['bairro'] ?? '',
      localidade: map['localidade'] ?? '',
      uf: map['uf'] ?? '',
      // Mapeamento dos campos do Firestore (garanta que o FirebaseService também salve esses campos, se necessário)
      complemento: map['complemento'] ?? '',
      ddd: map['ddd'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? ''),
    );
  }

  // toMap para salvar no Firestore (inclua os novos campos)
  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'complemento': complemento, // Incluído
      'ddd': ddd, // Incluído
      'timestamp':
          timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
