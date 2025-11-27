import 'package:flutter/material.dart';
import '../models/movel.dart';
import '../models/item_nota_fiscal.dart';
import '../services/hive_service.dart';

class AdicionarItemNotaScreen extends StatefulWidget {
  final int idNotaFiscal;
  final ItemNotaFiscal? itemExistente;

  const AdicionarItemNotaScreen({
    super.key,
    required this.idNotaFiscal,
    this.itemExistente,
  });

  @override
  State<AdicionarItemNotaScreen> createState() => _AdicionarItemNotaScreenState();
}

class _AdicionarItemNotaScreenState extends State<AdicionarItemNotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _precoUnitarioController = TextEditingController();
  
  Movel? _movelSelecionado;
  List<Movel> _moveisDisponiveis = [];
  double _valorTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarMoveis();
    
    if (widget.itemExistente != null) {
      _preencherFormularioExistente();
    } else {
      _gerarNovoId();
    }
  }

  void _carregarMoveis() {
    setState(() {
      _moveisDisponiveis = HiveService.getAllMoveis();
    });
  }

  void _preencherFormularioExistente() {
    final item = widget.itemExistente!;
    _idController.text = item.idItem.toString();
    _quantidadeController.text = item.quantidade.toString();
    _precoUnitarioController.text = item.precoUnitario.toString();
    
    final movel = HiveService.getMovel(item.idMovel);
    if (movel != null) {
      _movelSelecionado = movel;
    }
    
    _calcularValorTotal();
  }

  void _gerarNovoId() {
    final itens = HiveService.getAllItensNotaFiscal();
    final novoId = itens.isEmpty ? 1 : (itens.last.idItem + 1);
    _idController.text = novoId.toString();
  }

  void _calcularValorTotal() {
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final precoUnitario = double.tryParse(_precoUnitarioController.text) ?? 0;
    
    setState(() {
      _valorTotal = quantidade * precoUnitario;
    });
  }

  void _usarPrecoSugerido() {
    if (_movelSelecionado != null) {
      _precoUnitarioController.text = _movelSelecionado!.precoVendaSugerido.toStringAsFixed(2);
      _calcularValorTotal();
    }
  }

  void _salvarItem() {
    if (_formKey.currentState!.validate()) {
      if (_movelSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um móvel')),
        );
        return;
      }

      final item = ItemNotaFiscal(
        idItem: int.parse(_idController.text),
        idNotaFiscal: widget.idNotaFiscal,
        idMovel: _movelSelecionado!.idMovel,
        quantidade: int.parse(_quantidadeController.text),
        precoUnitario: double.parse(_precoUnitarioController.text),
        valorTotalItem: _valorTotal,
      );

      if (widget.itemExistente == null) {
        HiveService.addItemNotaFiscal(item);
      } else {
        HiveService.updateItemNotaFiscal(item);
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
            Text('Preço Sugerido: R\$ ${_movelSelecionado!.precoVendaSugerido.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _usarPrecoSugerido,
              child: const Text('Usar Preço Sugerido'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemExistente == null ? 'Adicionar Item' : 'Editar Item'),
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
                  labelText: 'ID do Item',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
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
                      '${movel.nome} (R\$ ${movel.precoVendaSugerido.toStringAsFixed(2)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (Movel? newValue) {
                  setState(() {
                    _movelSelecionado = newValue;
                    if (newValue != null) {
                      _usarPrecoSugerido();
                    }
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

              // Quantidade e Preço Unitário
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calcularValorTotal(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        final qtd = int.tryParse(value);
                        if (qtd == null || qtd <= 0) return 'Quantidade inválida';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _precoUnitarioController,
                      decoration: const InputDecoration(
                        labelText: 'Preço Unitário',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calcularValorTotal(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        if (double.tryParse(value) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Valor Total
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Valor Total do Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${_valorTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _salvarItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Item'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}