import 'package:flutter/material.dart';
import '../models/movel.dart';
import '../models/estoque.dart';
import '../services/hive_service.dart';

class EstoqueFormScreen extends StatefulWidget {
  final Estoque? estoque;

  const EstoqueFormScreen({super.key, this.estoque});

  @override
  State<EstoqueFormScreen> createState() => _EstoqueFormScreenState();
}

class _EstoqueFormScreenState extends State<EstoqueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _localizacaoController = TextEditingController();
  
  String _statusSelecionado = 'Disponível';
  Movel? _movelSelecionado;
  
  final List<String> _statusOptions = [
    'Disponível',
    'Reservado',
    'Em Trânsito',
    'Vendido',
    'Baixado por Avaria'
  ];

  List<Movel> _moveisDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _carregarMoveis();
    
    if (widget.estoque != null) {
      _idController.text = widget.estoque!.idEstoque.toString();
      _localizacaoController.text = widget.estoque!.localizacaoFisica;
      _statusSelecionado = widget.estoque!.status;
      
      final movel = HiveService.getMovel(widget.estoque!.idMovel);
      if (movel != null) {
        _movelSelecionado = movel;
      }
    } else {
      final estoques = HiveService.getAllEstoque();
      final novoId = estoques.isEmpty ? 1 : (estoques.last.idEstoque + 1);
      _idController.text = novoId.toString();
    }
  }

  void _carregarMoveis() {
    setState(() {
      if (widget.estoque == null) {
        _moveisDisponiveis = HiveService.getMoveisParaEstoque();
      } else {
        _moveisDisponiveis = HiveService.getMoveisDisponiveis();
      }
    });
  }

  void _salvarEstoque() {
    if (_formKey.currentState!.validate()) {
      if (_movelSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um móvel')),
        );
        return;
      }

      final estoque = Estoque(
        idEstoque: int.parse(_idController.text),
        idMovel: _movelSelecionado!.idMovel,
        localizacaoFisica: _localizacaoController.text,
        status: _statusSelecionado,
        dataAtualizacao: DateTime.now(),
      );

      if (widget.estoque == null) {
        HiveService.addEstoque(estoque);
      } else {
        HiveService.updateEstoque(estoque);
      }
      
      Navigator.pop(context);
    }
  }

  Widget _buildMovelInfo() {
    if (_movelSelecionado == null) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Móvel Selecionado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nome: ${_movelSelecionado!.nome}'),
            Text('Tipo: ${_movelSelecionado!.tipoMovel}'),
            Text('Dimensões: ${_movelSelecionado!.dimensoes}'),
            Text('Preço: R\$ ${_movelSelecionado!.precoVenda.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estoque == null ? 'Novo Item no Estoque' : 'Editar Item no Estoque'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID do Estoque',
                  border: OutlineInputBorder(),
                ),
                readOnly: widget.estoque != null,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Dropdown para selecionar móvel
              DropdownButtonFormField<Movel>(
                value: _movelSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Selecionar Móvel',
                  border: OutlineInputBorder(),
                ),
                items: _moveisDisponiveis.map((Movel movel) {
                  return DropdownMenuItem<Movel>(
                    value: movel,
                    child: Text(
                      movel.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (Movel? newValue) {
                  setState(() {
                    _movelSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Selecione um móvel';
                  return null;
                },
                isExpanded: true,
              ),

              const SizedBox(height: 16),
              _buildMovelInfo(),
              const SizedBox(height: 16),

              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(
                  labelText: 'Localização Física',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _statusSelecionado = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Selecione um status';
                  return null;
                },
              ),

              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _salvarEstoque,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor(_statusSelecionado),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Estoque'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
        return Colors.blue;
    }
  }
}