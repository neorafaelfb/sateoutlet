import 'package:flutter/material.dart';
import '../models/movel.dart';
import '../services/hive_service.dart';
import 'movel_form_screen.dart';

class MovelScreen extends StatefulWidget {
  const MovelScreen({super.key});

  @override
  State<MovelScreen> createState() => _MovelScreenState();
}

class _MovelScreenState extends State<MovelScreen> {
  List<Movel> _moveis = [];

  @override
  void initState() {
    super.initState();
    _carregarMoveis();
  }

  void _carregarMoveis() {
    setState(() {
      _moveis = HiveService.getAllMoveis();
    });
  }

  void _adicionarMovel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MovelFormScreen()),
    );
    _carregarMoveis();
  }

  void _editarMovel(Movel movel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovelFormScreen(movel: movel)),
    );
    _carregarMoveis();
  }

  void _excluirMovel(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este móvel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final estoquesVinculados = HiveService.getEstoquePorMovel(id);
                
                if (estoquesVinculados.isNotEmpty) {
                  Navigator.pop(context);
                  _confirmarExclusaoCascataMovel(id, estoquesVinculados.length);
                } else {
                  await HiveService.deleteMovelSafe(id);
                  _carregarMoveis();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Móvel excluído com sucesso')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir: ${e.toString()}')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusaoCascataMovel(int id, int quantidadeEstoques) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exclusão em Cascata Necessária'),
        content: Text(
          'Este móvel possui $quantidadeEstoques item(ns) em estoque vinculado(s).\n\n'
          'Deseja excluir o móvel e todos os itens de estoque associados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HiveService.deleteMovelCascade(id);
                _carregarMoveis();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Móvel e estoques excluídos com sucesso')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir: ${e.toString()}')),
                );
              }
            },
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );
  }

  bool _movelPossuiEstoque(int idMovel) {
    final estoques = HiveService.getEstoquePorMovel(idMovel);
    return estoques.isNotEmpty;
  }

  String _getInfoEstoque(int idMovel) {
    final estoques = HiveService.getEstoquePorMovel(idMovel);
    if (estoques.isEmpty) {
      return 'Sem estoque';
    }
    
    final primeiroEstoque = estoques.first;
    return 'Estoque: ${primeiroEstoque.localizacaoFisica} - ${primeiroEstoque.status}';
  }

  Widget _buildNotaFiscalInfo(int idNotaFiscal) {
    final notaFiscal = HiveService.getNotaFiscal(idNotaFiscal);
    if (notaFiscal == null) {
      return const Text(
        '⚠️ Nota fiscal não encontrada',
        style: TextStyle(color: Colors.red, fontSize: 12),
      );
    }
    
    return Text(
      'Nota: ${notaFiscal.idNotaFiscal} - ${notaFiscal.detalhesFornecedor}',
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Móveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarMovel,
          ),
        ],
      ),
      body: _moveis.isEmpty
          ? const Center(
              child: Text(
                'Nenhum móvel cadastrado\nClique no + para adicionar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _moveis.length,
              itemBuilder: (context, index) {
                final movel = _moveis[index];
                final possuiEstoque = _movelPossuiEstoque(movel.idMovel);
                final infoEstoque = _getInfoEstoque(movel.idMovel);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: _buildLeadingIcon(possuiEstoque),
                    title: Text(movel.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${movel.tipoMovel}'),
                        Text('Preço: R\$ ${movel.precoVenda.toStringAsFixed(2)}'),
                        Text('Dimensões: ${movel.dimensoes}'),
                        const SizedBox(height: 4),
                        _buildNotaFiscalInfo(movel.idNotaFiscal),
                        const SizedBox(height: 4),
                        _buildEstoqueInfo(infoEstoque, possuiEstoque),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarMovel(movel),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirMovel(movel.idMovel),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLeadingIcon(bool possuiEstoque) {
    return Stack(
      children: [
        const Icon(Icons.chair, size: 40),
        if (possuiEstoque)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEstoqueInfo(String info, bool possuiEstoque) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: possuiEstoque ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: possuiEstoque ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            possuiEstoque ? Icons.inventory : Icons.inventory_2,
            size: 14,
            color: possuiEstoque ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            info,
            style: TextStyle(
              fontSize: 12,
              color: possuiEstoque ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}