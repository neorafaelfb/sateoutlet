import 'package:flutter/material.dart';
import '../models/movel.dart';
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
  final _codigoBarrasController = TextEditingController();
  final _materialController = TextEditingController();
  final _corController = TextEditingController();
  final _fabricanteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.movel != null) {
      _preencherFormularioExistente();
    } else {
      _gerarNovoId();
    }
  }

  void _preencherFormularioExistente() {
    final movel = widget.movel!;
    _idController.text = movel.idMovel.toString();
    _tipoController.text = movel.tipoMovel;
    _nomeController.text = movel.nome;
    _dimensoesController.text = movel.dimensoes;
    _precoController.text = movel.precoVendaSugerido.toString();
    _codigoBarrasController.text = movel.codigoBarras ?? '';
    _materialController.text = movel.material ?? '';
    _corController.text = movel.cor ?? '';
    _fabricanteController.text = movel.fabricante ?? '';
  }

  void _gerarNovoId() {
    final moveis = HiveService.getAllMoveis();
    final novoId = moveis.isEmpty ? 1 : (moveis.last.idMovel + 1);
    _idController.text = novoId.toString();
  }

  void _salvarMovel() {
    if (_formKey.currentState!.validate()) {
      final movel = Movel(
        idMovel: int.parse(_idController.text),
        tipoMovel: _tipoController.text,
        nome: _nomeController.text,
        dimensoes: _dimensoesController.text,
        precoVendaSugerido: double.parse(_precoController.text),
        codigoBarras: _codigoBarrasController.text.isNotEmpty ? _codigoBarrasController.text : null,
        material: _materialController.text.isNotEmpty ? _materialController.text : null,
        cor: _corController.text.isNotEmpty ? _corController.text : null,
        fabricante: _fabricanteController.text.isNotEmpty ? _fabricanteController.text : null,
      );

      if (widget.movel == null) {
        HiveService.addMovel(movel);
      } else {
        HiveService.updateMovel(movel);
      }
      
      Navigator.pop(context);
    }
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
                  labelText: 'Preço de Venda Sugerido',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campos opcionais
              TextFormField(
                controller: _codigoBarrasController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Material (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _corController,
                decoration: const InputDecoration(
                  labelText: 'Cor (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _fabricanteController,
                decoration: const InputDecoration(
                  labelText: 'Fabricante (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

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