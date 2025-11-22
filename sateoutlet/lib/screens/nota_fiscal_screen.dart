import 'package:flutter/material.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'nota_fiscal_form_screen.dart';

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
            onPressed: () {
              HiveService.deleteNotaFiscal(id);
              _carregarNotasFiscais();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota fiscal excluída com sucesso')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, size: 40),
                    title: Text('Nota: ${notaFiscal.idNotaFiscal}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fornecedor: ${notaFiscal.detalhesFornecedor}'),
                        Text('Data: ${_formatarData(notaFiscal.dataEmissao)}'),
                        Text('Valor Total: R\$ ${notaFiscal.valorTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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