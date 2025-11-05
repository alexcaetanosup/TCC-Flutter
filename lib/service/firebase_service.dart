import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/endereco_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'historico_ceps';

  // MÉTODO CORRIGIDO: SALVAR ENDEREÇO
  // Recebe o modelo do CEP consultado e salva uma nova instância com timestamp.
  Future<void> salvarEndereco(EnderecoModel endereco) async {
    // Cria uma nova instância, transferindo todos os dados do modelo recebido
    // e adicionando o timestamp.
    final enderecoComTimestamp = EnderecoModel(
      cep: endereco.cep,
      logradouro: endereco.logradouro,
      bairro: endereco.bairro,
      localidade: endereco.localidade,
      uf: endereco.uf,

      // --- INCLUSÃO DOS CAMPOS OBRIGATÓRIOS ---
      complemento: endereco.complemento,
      ddd: endereco.ddd,

      // ----------------------------------------
      timestamp: DateTime.now(), // Novo timestamp
    );

    await _db.collection(_collectionName).add(enderecoComTimestamp.toMap());
  }

  // MÉTODO: LISTAR HISTÓRICO
  Stream<List<EnderecoModel>> listarHistorico() {
    return _db
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EnderecoModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // MÉTODO: EXCLUIR ITEM ÚNICO
  Future<void> excluirEndereco(String enderecoId) async {
    await _db.collection(_collectionName).doc(enderecoId).delete();
  }

  // MÉTODO: EXCLUIR MÚLTIPLOS ITENS (BATCH DELETE)
  Future<void> excluirMultiplosEnderecos(List<String> ids) async {
    final batch = _db.batch();
    final collectionRef = _db.collection(_collectionName);

    for (final id in ids) {
      batch.delete(collectionRef.doc(id));
    }

    await batch.commit();
  }

  // MÉTODO: LIMPAR HISTÓRICO TOTAL (usa o método de múltiplos)
  Future<void> limparHistorico() async {
    final snapshot = await _db.collection(_collectionName).get();

    if (snapshot.docs.isNotEmpty) {
      final ids = snapshot.docs.map((doc) => doc.id).toList();
      await excluirMultiplosEnderecos(ids);
    }
  }
}
