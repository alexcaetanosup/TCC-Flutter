// lib/screen/historico_screen.dart

import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../model/endereco_model.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final FirebaseService firebaseService = FirebaseService();
  // Mapa para armazenar os IDs dos itens selecionados (id: true/false)
  final Map<String, bool> _selectedItems = {};
  bool get _isSelectionMode => _selectedItems.containsValue(true);
  int get _selectedCount => _selectedItems.values.where((v) => v).length;

  // Função para lidar com a seleção/desseleção
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.containsKey(id) && _selectedItems[id] == true) {
        _selectedItems.remove(id);
      } else {
        _selectedItems[id] = true;
      }
    });
  }

  // Função para excluir os itens selecionados
  Future<void> _deleteSelected() async {
    final idsToDelete = _selectedItems.keys
        .where((id) => _selectedItems[id] == true)
        .toList();

    if (idsToDelete.isEmpty) return;

    // Confirmação (opcional, mas recomendado)
    final confirmed = await _showConfirmDeleteDialog(
      context,
      idsToDelete.length,
    );
    if (!confirmed) return;

    try {
      await firebaseService.excluirMultiplosEnderecos(idsToDelete);

      // Limpa o estado de seleção após a exclusão bem-sucedida
      setState(() {
        _selectedItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${idsToDelete.length} item(s) excluído(s) com sucesso!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao excluir itens: $e')));
    }
  }

  // =================================================================
  // MÉTODO AUXILIAR: Diálogo para confirmar a LIMPEZA GERAL
  // =================================================================
  Future<bool> _showConfirmClearDialog(BuildContext context) async {
    // ... (Mantenha o diálogo de limpeza geral) ...
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Confirmar Limpeza Total'),
              content: const Text(
                'Tem certeza que deseja apagar todo o histórico de consultas de CEP?',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Limpar'),
                  onPressed: () {
                    firebaseService.limparHistorico();
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // =================================================================
  // MÉTODO AUXILIAR: Diálogo para confirmar a EXCLUSÃO DE SELECIONADOS
  // =================================================================
  Future<bool> _showConfirmDeleteDialog(BuildContext context, int count) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: Text(
                'Tem certeza que deseja apagar $count item(s) selecionado(s)?',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Excluir'),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // =================================================================
  // MÉTODO build
  // =================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '$_selectedCount Selecionado(s)'
              : 'Histórico de Consultas',
        ),
        actions: [
          // 1. Botão de Excluir Itens Selecionados
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir Selecionado(s)',
              onPressed: _selectedCount > 0 ? _deleteSelected : null,
            )
          else
            // 2. Botão de Limpar Tudo (só aparece se não estiver em modo de seleção)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Limpar Histórico',
              onPressed: () async {
                final cleared = await _showConfirmClearDialog(context);
                if (cleared) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Histórico limpo com sucesso!'),
                    ),
                  );
                }
              },
            ),
        ],
      ),

      body: StreamBuilder<List<EnderecoModel>>(
        stream: firebaseService.listarHistorico(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final historico = snapshot.data;

          if (historico == null || historico.isEmpty) {
            return const Center(
              child: Text('Nenhuma consulta salva no histórico.'),
            );
          }

          // Atualiza a lista de IDs conhecidos para o mapa de seleção
          // Se um item não existe mais, remove ele da seleção
          _selectedItems.keys.toList().forEach((id) {
            if (!historico.any((e) => e.id == id)) {
              _selectedItems.remove(id);
            }
          });

          return ListView.builder(
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final endereco = historico[index];
              final isSelected =
                  _selectedItems.containsKey(endereco.id) &&
                  _selectedItems[endereco.id] == true;

              return Card(
                elevation: isSelected ? 4 : 2,
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  // 1. Checkbox para seleção individual
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      // O ID do EnderecoModel é crucial aqui!
                      if (endereco.id != null) {
                        _toggleSelection(endereco.id!);
                      }
                    },
                  ),
                  // 2. Título e Subtítulo
                  title: Text(
                    endereco.logradouro.isNotEmpty
                        ? '${endereco.logradouro}, ${endereco.localidade} - ${endereco.uf}'
                        : '${endereco.localidade} - ${endereco.uf}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'CEP: ${endereco.cep}\nBairro: ${endereco.bairro}',
                  ),
                  isThreeLine: true,
                  // 3. Permite selecionar ou desselecionar ao tocar na linha inteira
                  onTap: () {
                    if (endereco.id != null) {
                      _toggleSelection(endereco.id!);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
