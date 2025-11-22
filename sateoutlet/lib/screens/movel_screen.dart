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
      MaterialPageRoute(builder: (context) => MovelFormScreen()),
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
            onPressed: () {
              HiveService.deleteMovel(id);
              _carregarMoveis();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Móvel excluído com sucesso')),
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.chair, size: 40),
                    title: Text(movel.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${movel.tipoMovel}'),
                        Text('Preço: R\$ ${movel.precoVenda.toStringAsFixed(2)}'),
                        Text('Dimensões: ${movel.dimensoes}'),
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
}