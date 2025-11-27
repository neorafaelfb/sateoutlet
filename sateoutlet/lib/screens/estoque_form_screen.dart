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
    'Baixado por Avaria',
    'Em Manutenção'
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
        // Para novo estoque, mostrar apenas móveis sem estoque
        _moveisDisponiveis = HiveService.getMoveisParaEstoque();
      } else {
        // Para edição, mostrar todos os móveis (incluindo o já selecionado)
        _moveisDisponiveis = HiveService.getAllMoveis();
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

      // Verificar se já existe estoque para este móvel (apenas para novo estoque)
      if (widget.estoque == null) {
        final estoqueExistente = HiveService.getEstoquePorMovel(_movelSelecionado!.idMovel);
        if (estoqueExistente.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Já existe estoque cadastrado para o móvel "${_movelSelecionado!.nome}"'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item de estoque adicionado com sucesso')),
        );
      } else {
        HiveService.updateEstoque(estoque);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item de estoque atualizado com sucesso')),
        );
      }
      
      Navigator.pop(context);
    }
  }

  Widget _buildMovelInfo() {
    if (_movelSelecionado == null) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Nenhum móvel selecionado',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final quantidadeTotal = HiveService.getQuantidadeTotalMovel(_movelSelecionado!.idMovel);
    final notasVinculadas = HiveService.getNotasFiscaisPorMovel(_movelSelecionado!.idMovel);

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
            if (_movelSelecionado!.material != null) 
              Text('Material: ${_movelSelecionado!.material}'),
            if (_movelSelecionado!.cor != null) 
              Text('Cor: ${_movelSelecionado!.cor}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações de Compra:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text('Quantidade Total Comprada: $quantidadeTotal'),
                  Text('Notas Fiscais Vinculadas: ${notasVinculadas.length}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovelDropdown() {
    if (_moveisDisponiveis.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecionar Móvel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[50],
            ),
            child: const Column(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 40),
                SizedBox(height: 8),
                Text(
                  'Nenhum móvel disponível para estoque',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Todos os móveis cadastrados já possuem estoque ou não há móveis cadastrados',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return DropdownButtonFormField<Movel>(
      value: _movelSelecionado,
      decoration: const InputDecoration(
        labelText: 'Selecionar Móvel',
        border: OutlineInputBorder(),
        hintText: 'Selecione um móvel para adicionar ao estoque',
      ),
      items: _moveisDisponiveis.map((Movel movel) {
        return DropdownMenuItem<Movel>(
          value: movel,
          child: Text(
            movel.nome,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: widget.estoque != null && _movelSelecionado != null
          ? null // Não permitir alterar o móvel na edição
          : (Movel? newValue) {
              setState(() {
                _movelSelecionado = newValue;
              });
            },
      validator: (value) {
        if (value == null) return 'Selecione um móvel';
        return null;
      },
      isExpanded: true,
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
              // ID do Estoque
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID do Estoque',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Dropdown para selecionar móvel
              _buildMovelDropdown(),

              const SizedBox(height: 16),
              _buildMovelInfo(),
              const SizedBox(height: 20),

              // Localização Física
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(
                  labelText: 'Localização Física',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Prateleira A-15, Setor B-20, Armazém 3...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Status
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(status),
                      ],
                    ),
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

              const SizedBox(height: 30),
              
              // Botão Salvar
              ElevatedButton(
                onPressed: _salvarEstoque,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor(_statusSelecionado),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  widget.estoque == null ? 'Adicionar ao Estoque' : 'Atualizar Estoque',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botão Cancelar
              if (widget.estoque != null)
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              
              const SizedBox(height: 20), // Espaço extra no final
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
      case 'em manutenção':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disponível':
        return Icons.check_circle;
      case 'reservado':
        return Icons.bookmark;
      case 'em trânsito':
        return Icons.local_shipping;
      case 'vendido':
        return Icons.attach_money;
      case 'baixado por avaria':
        return Icons.warning;
      case 'em manutenção':
        return Icons.build;
      default:
        return Icons.help;
    }
  }
}