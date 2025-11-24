import 'package:flutter/material.dart';
import '../models/estoque.dart';
import '../services/hive_service.dart';
import 'estoque_form_screen.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  List<Estoque> _estoques = [];

  @override
  void initState() {
    super.initState();
    _carregarEstoques();
  }

  void _carregarEstoques() {
    setState(() {
      _estoques = HiveService.getAllEstoque();
    });
  }

  void _adicionarEstoque() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EstoqueFormScreen()),
    );
    _carregarEstoques();
  }

  void _editarEstoque(Estoque estoque) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstoqueFormScreen(estoque: estoque)),
    );
    _carregarEstoques();
  }

  void _excluirEstoque(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este item do estoque?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              HiveService.deleteEstoque(id);
              _carregarEstoques();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item do estoque excluído com sucesso')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disponível':
        return Colors.green;
      case 'reservado':
        return Colors.orange;
      case 'em trânsito':
        return Colors.blue;
      case 'vendido':
        return Colors.red;
      case 'baixado por avaria':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget _buildMovelInfo(int idMovel) {
    final movel = HiveService.getMovel(idMovel);
    if (movel == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Móvel #$idMovel',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const Text(
            '⚠️ Móvel não encontrado (foi excluído)',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      );
    }
    
    final notaFiscal = HiveService.getNotaFiscal(movel.idNotaFiscal);
    final notaInfo = notaFiscal != null 
        ? 'Nota: ${notaFiscal.idNotaFiscal}'
        : '⚠️ Nota fiscal não encontrada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Móvel: ${movel.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Tipo: ${movel.tipoMovel}'),
        Text('Preço: R\$ ${movel.precoVenda.toStringAsFixed(2)}'),
        Text(
          notaInfo,
          style: TextStyle(
            color: notaFiscal != null ? Colors.grey : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Estoque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarEstoque,
          ),
        ],
      ),
      body: _estoques.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum item no estoque',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clique no + para adicionar um item ao estoque',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _estoques.length,
              itemBuilder: (context, index) {
                final estoque = _estoques[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.inventory, size: 40),
                    title: _buildMovelInfo(estoque.idMovel),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Localização: ${estoque.localizacaoFisica}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Status: '),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(estoque.status).withOpacity(0.1),
                                border: Border.all(color: _getStatusColor(estoque.status)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                estoque.status,
                                style: TextStyle(
                                  color: _getStatusColor(estoque.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('Atualizado: ${_formatarData(estoque.dataAtualizacao)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarEstoque(estoque),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirEstoque(estoque.idEstoque),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}';
  }
}