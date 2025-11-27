import 'package:flutter/material.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'nota_fiscal_form_screen.dart';
import 'itens_nota_fiscal_screen.dart';

class NotaFiscalScreen extends StatefulWidget {
  const NotaFiscalScreen({super.key});

  @override
  State<NotaFiscalScreen> createState() => _NotaFiscalScreenState();
}

class _NotaFiscalScreenState extends State<NotaFiscalScreen> {
  List<NotaFiscal> _notasFiscais = [];

  @override
  void initState() {
    super.initState();
    _carregarNotasFiscais();
  }

  void _carregarNotasFiscais() {
    setState(() {
      _notasFiscais = HiveService.getAllNotasFiscais();
    });
  }

  void _adicionarNotaFiscal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotaFiscalFormScreen()),
    );
    _carregarNotasFiscais();
  }

  void _editarNotaFiscal(NotaFiscal notaFiscal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotaFiscalFormScreen(notaFiscal: notaFiscal)),
    );
    _carregarNotasFiscais();
  }

  void _verItensNotaFiscal(NotaFiscal notaFiscal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItensNotaFiscalScreen(notaFiscal: notaFiscal),
      ),
    );
    _carregarNotasFiscais();
  }

  void _excluirNotaFiscal(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta nota fiscal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final itensVinculados = HiveService.getItensPorNotaFiscal(id);
                
                if (itensVinculados.isNotEmpty) {
                  Navigator.pop(context);
                  _confirmarExclusaoCascataNotaFiscal(id, itensVinculados.length);
                } else {
                  await HiveService.deleteNotaFiscalSafe(id);
                  _carregarNotasFiscais();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nota fiscal excluída com sucesso')),
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

  void _confirmarExclusaoCascataNotaFiscal(int id, int quantidadeItens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exclusão em Cascata Necessária'),
        content: Text(
          'Esta nota fiscal possui $quantidadeItens item(ns) vinculado(s).\n\n'
          'Deseja excluir a nota fiscal e todos os itens associados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HiveService.deleteNotaFiscalCascade(id);
                _carregarNotasFiscais();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota fiscal e itens excluídos com sucesso')),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'finalizada':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Notas Fiscais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarNotaFiscal,
          ),
        ],
      ),
      body: _notasFiscais.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma nota fiscal cadastrada\nClique no + para adicionar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _notasFiscais.length,
              itemBuilder: (context, index) {
                final notaFiscal = _notasFiscais[index];
                final itensVinculados = HiveService.getItensPorNotaFiscal(notaFiscal.idNotaFiscal);
                final valorTotalItens = HiveService.calcularValorTotalNota(notaFiscal.idNotaFiscal);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, size: 40),
                    title: Text('Nota: ${notaFiscal.numeroNota}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fornecedor: ${notaFiscal.razaoSocialFornecedor}'),
                        Text('Data: ${_formatarData(notaFiscal.dataEmissao)}'),
                        Text('Valor Total: R\$ ${notaFiscal.valorTotalNota.toStringAsFixed(2)}'),
                        Text(
                          'Itens: ${itensVinculados.length} (R\$ ${valorTotalItens.toStringAsFixed(2)})',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Status: '),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(notaFiscal.status).withOpacity(0.1),
                                border: Border.all(color: _getStatusColor(notaFiscal.status)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notaFiscal.status,
                                style: TextStyle(
                                  color: _getStatusColor(notaFiscal.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão de Itens - APENAS para notas com status "Pendente"
                        if (notaFiscal.status.toLowerCase() == 'pendente')
                          IconButton(
                            icon: const Icon(Icons.list, color: Colors.purple),
                            onPressed: () => _verItensNotaFiscal(notaFiscal),
                            tooltip: 'Gerenciar Itens',
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarNotaFiscal(notaFiscal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirNotaFiscal(notaFiscal.idNotaFiscal),
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
    return '${data.day}/${data.month}/${data.year}';
  }
}