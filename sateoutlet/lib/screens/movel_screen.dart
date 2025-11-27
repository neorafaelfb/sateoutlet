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
                final itensVinculados = HiveService.getAllItensNotaFiscal()
                    .where((item) => item.idMovel == id)
                    .toList();
                
                if (estoquesVinculados.isNotEmpty || itensVinculados.isNotEmpty) {
                  Navigator.pop(context);
                  _confirmarExclusaoCascataMovel(id, estoquesVinculados.length, itensVinculados.length);
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

  void _confirmarExclusaoCascataMovel(int id, int quantidadeEstoques, int quantidadeItens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exclusão em Cascata Necessária'),
        content: Text(
          'Este móvel possui:\n'
          '- $quantidadeEstoques item(ns) em estoque\n'
          '- $quantidadeItens item(ns) em notas fiscais\n\n'
          'Deseja excluir o móvel e todas as vinculações associadas?',
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
                  const SnackBar(content: Text('Móvel e vinculações excluídos com sucesso')),
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

  bool _movelPossuiNotasFiscais(int idMovel) {
    final itens = HiveService.getAllItensNotaFiscal()
        .where((item) => item.idMovel == idMovel)
        .toList();
    return itens.isNotEmpty;
  }

  String _getInfoEstoque(int idMovel) {
    final estoques = HiveService.getEstoquePorMovel(idMovel);
    if (estoques.isEmpty) {
      return 'Sem estoque';
    }
    
    final primeiroEstoque = estoques.first;
    return 'Estoque: ${primeiroEstoque.localizacaoFisica}';
  }

  String _getInfoNotasFiscais(int idMovel) {
    final itens = HiveService.getAllItensNotaFiscal()
        .where((item) => item.idMovel == idMovel)
        .toList();
    
    if (itens.isEmpty) {
      return 'Sem notas fiscais';
    }
    
    final quantidadeTotal = itens.fold(0, (sum, item) => sum + item.quantidade);
    return 'Em $quantidadeTotal nota(s) fiscal(is)';
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
                final possuiNotas = _movelPossuiNotasFiscais(movel.idMovel);
                final infoEstoque = _getInfoEstoque(movel.idMovel);
                final infoNotas = _getInfoNotasFiscais(movel.idMovel);
                final quantidadeTotal = HiveService.getQuantidadeTotalMovel(movel.idMovel);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: _buildLeadingIcon(possuiEstoque, possuiNotas),
                    title: Text(movel.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${movel.tipoMovel}'),
                        Text('Preço Sugerido: R\$ ${movel.precoVendaSugerido.toStringAsFixed(2)}'),
                        Text('Dimensões: ${movel.dimensoes}'),
                        if (movel.material != null) Text('Material: ${movel.material}'),
                        if (movel.cor != null) Text('Cor: ${movel.cor}'),
                        if (movel.fabricante != null) Text('Fabricante: ${movel.fabricante}'),
                        const SizedBox(height: 4),
                        Text(
                          'Quantidade Total Comprada: $quantidadeTotal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        _buildInfoChip(infoEstoque, possuiEstoque, Colors.green),
                        const SizedBox(height: 2),
                        _buildInfoChip(infoNotas, possuiNotas, Colors.blue),
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

  Widget _buildLeadingIcon(bool possuiEstoque, bool possuiNotas) {
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
        if (possuiNotas)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(String info, bool possui, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: possui ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: possui ? color : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getInfoIcon(info),
            size: 12,
            color: possui ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            info,
            style: TextStyle(
              fontSize: 10,
              color: possui ? color : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInfoIcon(String info) {
    if (info.contains('estoque')) return Icons.inventory;
    if (info.contains('nota')) return Icons.receipt;
    return Icons.info;
  }
}