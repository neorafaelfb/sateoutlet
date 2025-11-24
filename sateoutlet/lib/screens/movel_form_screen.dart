import 'package:flutter/material.dart';
import '../models/movel.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';

class MovelFormScreen extends StatefulWidget {
  final Movel? movel;

  const MovelFormScreen({super.key, this.movel});

  @override
  State<MovelFormScreen> createState() => _MovelFormScreenState();
}

class _MovelFormScreenState extends State<MovelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _tipoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _dimensoesController = TextEditingController();
  final _precoController = TextEditingController();
  
  NotaFiscal? _notaFiscalSelecionada;
  List<NotaFiscal> _notasFiscaisDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _carregarNotasFiscais();
    
    if (widget.movel != null) {
      _idController.text = widget.movel!.idMovel.toString();
      _tipoController.text = widget.movel!.tipoMovel;
      _nomeController.text = widget.movel!.nome;
      _dimensoesController.text = widget.movel!.dimensoes;
      _precoController.text = widget.movel!.precoVenda.toString();
      
      final notaFiscal = HiveService.getNotaFiscal(widget.movel!.idNotaFiscal);
      if (notaFiscal != null) {
        _notaFiscalSelecionada = notaFiscal;
      }
    } else {
      final moveis = HiveService.getAllMoveis();
      final novoId = moveis.isEmpty ? 1 : (moveis.last.idMovel + 1);
      _idController.text = novoId.toString();
    }
  }

  void _carregarNotasFiscais() {
    setState(() {
      _notasFiscaisDisponiveis = HiveService.getAllNotasFiscais();
    });
  }

  void _salvarMovel() {
    if (_formKey.currentState!.validate()) {
      if (_notaFiscalSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma nota fiscal')),
        );
        return;
      }

      final movel = Movel(
        idMovel: int.parse(_idController.text),
        tipoMovel: _tipoController.text,
        nome: _nomeController.text,
        dimensoes: _dimensoesController.text,
        precoVenda: double.parse(_precoController.text),
        idNotaFiscal: _notaFiscalSelecionada!.idNotaFiscal,
      );

      if (widget.movel == null) {
        HiveService.addMovel(movel);
      } else {
        HiveService.updateMovel(movel);
      }
      
      Navigator.pop(context);
    }
  }

  Widget _buildNotaFiscalInfo() {
    if (_notaFiscalSelecionada == null) {
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
              'Nota Fiscal Selecionada:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Número: ${_notaFiscalSelecionada!.idNotaFiscal}'),
            Text('Fornecedor: ${_notaFiscalSelecionada!.detalhesFornecedor}'),
            Text('Data: ${_formatarData(_notaFiscalSelecionada!.dataEmissao)}'),
            Text('Valor Total: R\$ ${_notaFiscalSelecionada!.valorTotal.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movel == null ? 'Novo Móvel' : 'Editar Móvel'),
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
                  labelText: 'ID do Móvel',
                  border: OutlineInputBorder(),
                ),
                readOnly: widget.movel != null,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Móvel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome/Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _dimensoesController,
                decoration: const InputDecoration(
                  labelText: 'Dimensões (LxAxP)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dropdown para selecionar nota fiscal
              DropdownButtonFormField<NotaFiscal>(
                value: _notaFiscalSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Selecionar Nota Fiscal',
                  border: OutlineInputBorder(),
                ),
                items: _notasFiscaisDisponiveis.map((NotaFiscal notaFiscal) {
                  return DropdownMenuItem<NotaFiscal>(
                    value: notaFiscal,
                    child: Text(
                      'Nota ${notaFiscal.idNotaFiscal} - ${notaFiscal.detalhesFornecedor}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (NotaFiscal? newValue) {
                  setState(() {
                    _notaFiscalSelecionada = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Selecione uma nota fiscal';
                  return null;
                },
                isExpanded: true,
              ),

              const SizedBox(height: 16),
              _buildNotaFiscalInfo(),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _salvarMovel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Móvel'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}