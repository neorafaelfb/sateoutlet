import 'package:flutter/material.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'itens_nota_fiscal_screen.dart';

class NotaFiscalFormScreen extends StatefulWidget {
  final NotaFiscal? notaFiscal;

  const NotaFiscalFormScreen({super.key, this.notaFiscal});

  @override
  State<NotaFiscalFormScreen> createState() => _NotaFiscalFormScreenState();
}

class _NotaFiscalFormScreenState extends State<NotaFiscalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _numeroNotaController = TextEditingController();
  final _serieController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _valorProdutosController = TextEditingController();
  final _valorNotaController = TextEditingController();
  final _valorFreteController = TextEditingController();
  final _valorSeguroController = TextEditingController();
  final _outrasDespesasController = TextEditingController();
  
  DateTime _dataEmissao = DateTime.now();
  DateTime _dataEntrada = DateTime.now();
  String _tipoFreteSelecionado = 'CIF';
  String _statusSelecionado = 'Pendente';
  
  final List<String> _tiposFrete = ['CIF', 'FOB', 'Redespacho', 'Redespacho Intermediário'];
  final List<String> _statusOptions = ['Pendente', 'Finalizada', 'Cancelada'];

  double _valorTotalItens = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.notaFiscal != null) {
      _preencherFormularioExistente();
    } else {
      _gerarNovoId();
    }
    _calcularValorTotalItens();
  }

  void _preencherFormularioExistente() {
    final nota = widget.notaFiscal!;
    _idController.text = nota.idNotaFiscal.toString();
    _numeroNotaController.text = nota.numeroNota;
    _serieController.text = nota.serie;
    _cnpjController.text = nota.cnpjFornecedor;
    _razaoSocialController.text = nota.razaoSocialFornecedor;
    _enderecoController.text = nota.enderecoFornecedor ?? '';
    _telefoneController.text = nota.telefoneFornecedor ?? '';
    _valorProdutosController.text = nota.valorTotalProdutos.toString();
    _valorNotaController.text = nota.valorTotalNota.toString();
    _valorFreteController.text = nota.valorFrete?.toString() ?? '';
    _valorSeguroController.text = nota.valorSeguro?.toString() ?? '';
    _outrasDespesasController.text = nota.outrasDespesas?.toString() ?? '';
    _dataEmissao = nota.dataEmissao;
    _dataEntrada = nota.dataEntrada;
    _tipoFreteSelecionado = nota.tipoFrete;
    _statusSelecionado = nota.status;
  }

  void _gerarNovoId() {
    final notas = HiveService.getAllNotasFiscais();
    final novoId = notas.isEmpty ? 1 : (notas.last.idNotaFiscal + 1);
    _idController.text = novoId.toString();
    _numeroNotaController.text = novoId.toString().padLeft(6, '0');
    _serieController.text = '1';
  }

  void _calcularValorTotalItens() {
    if (widget.notaFiscal != null) {
      final valor = HiveService.calcularValorTotalNota(widget.notaFiscal!.idNotaFiscal);
      setState(() {
        _valorTotalItens = valor;
      });
      
      // Se houver itens, atualizar o valor dos produtos
      if (valor > 0) {
        _valorProdutosController.text = valor.toStringAsFixed(2);
        _calcularValorTotal();
      }
    }
  }

  Future<void> _selecionarDataEmissao() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEmissao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dataEmissao) {
      setState(() {
        _dataEmissao = picked;
      });
    }
  }

  Future<void> _selecionarDataEntrada() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEntrada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dataEntrada) {
      setState(() {
        _dataEntrada = picked;
      });
    }
  }

  void _calcularValorTotal() {
    final valorProdutos = double.tryParse(_valorProdutosController.text) ?? 0;
    final valorFrete = double.tryParse(_valorFreteController.text) ?? 0;
    final valorSeguro = double.tryParse(_valorSeguroController.text) ?? 0;
    final outrasDespesas = double.tryParse(_outrasDespesasController.text) ?? 0;
    
    final valorTotal = valorProdutos + valorFrete + valorSeguro + outrasDespesas;
    _valorNotaController.text = valorTotal.toStringAsFixed(2);
  }

  void _abrirGerenciadorItens() async {
    if (widget.notaFiscal == null) {
      // Primeiro salvar a nota fiscal antes de adicionar itens
      if (_formKey.currentState!.validate()) {
        final notaFiscal = NotaFiscal(
          idNotaFiscal: int.parse(_idController.text),
          numeroNota: _numeroNotaController.text,
          serie: _serieController.text,
          dataEmissao: _dataEmissao,
          dataEntrada: _dataEntrada,
          cnpjFornecedor: _cnpjController.text,
          razaoSocialFornecedor: _razaoSocialController.text,
          enderecoFornecedor: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
          telefoneFornecedor: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
          valorTotalProdutos: double.parse(_valorProdutosController.text),
          valorTotalNota: double.parse(_valorNotaController.text),
          valorFrete: _valorFreteController.text.isNotEmpty ? double.parse(_valorFreteController.text) : null,
          valorSeguro: _valorSeguroController.text.isNotEmpty ? double.parse(_valorSeguroController.text) : null,
          outrasDespesas: _outrasDespesasController.text.isNotEmpty ? double.parse(_outrasDespesasController.text) : null,
          tipoFrete: _tipoFreteSelecionado,
          status: _statusSelecionado,
        );

        await HiveService.addNotaFiscal(notaFiscal);
        
        // Agora abrir o gerenciador de itens
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItensNotaFiscalScreen(notaFiscal: notaFiscal),
          ),
        );
        
        // Atualizar valor dos itens após retornar
        _calcularValorTotalItens();
        Navigator.pop(context); // Fechar a tela de formulário
      }
    } else {
      // Para edição, abrir diretamente o gerenciador de itens
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItensNotaFiscalScreen(notaFiscal: widget.notaFiscal!),
        ),
      );
      
      // Atualizar valor dos itens após retornar
      _calcularValorTotalItens();
    }
  }

  void _salvarNotaFiscal() {
    if (_formKey.currentState!.validate()) {
      final notaFiscal = NotaFiscal(
        idNotaFiscal: int.parse(_idController.text),
        numeroNota: _numeroNotaController.text,
        serie: _serieController.text,
        dataEmissao: _dataEmissao,
        dataEntrada: _dataEntrada,
        cnpjFornecedor: _cnpjController.text,
        razaoSocialFornecedor: _razaoSocialController.text,
        enderecoFornecedor: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
        telefoneFornecedor: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        valorTotalProdutos: double.parse(_valorProdutosController.text),
        valorTotalNota: double.parse(_valorNotaController.text),
        valorFrete: _valorFreteController.text.isNotEmpty ? double.parse(_valorFreteController.text) : null,
        valorSeguro: _valorSeguroController.text.isNotEmpty ? double.parse(_valorSeguroController.text) : null,
        outrasDespesas: _outrasDespesasController.text.isNotEmpty ? double.parse(_outrasDespesasController.text) : null,
        tipoFrete: _tipoFreteSelecionado,
        status: _statusSelecionado,
      );

      if (widget.notaFiscal == null) {
        HiveService.addNotaFiscal(notaFiscal);
      } else {
        HiveService.updateNotaFiscal(notaFiscal);
      }
      
      Navigator.pop(context);
    }
  }

  Widget _buildDataField(String label, DateTime data, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text(
                  '${data.day}/${data.month}/${data.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItens() {
    if (widget.notaFiscal == null || _valorTotalItens == 0) {
      return const SizedBox();
    }

    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações dos Itens:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 4),
            Text('Valor Total dos Itens: R\$ ${_valorTotalItens.toStringAsFixed(2)}'),
            Text(
              'Este valor foi automaticamente preenchido no campo "Valor dos Produtos"',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
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
        title: Text(widget.notaFiscal == null ? 'Nova Nota Fiscal' : 'Editar Nota Fiscal'),
        actions: [
          // Botão de Gerenciar Itens - APENAS para notas com status "Pendente"
          if (_statusSelecionado.toLowerCase() == 'pendente')
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _abrirGerenciadorItens,
              tooltip: 'Gerenciar Itens da Nota Fiscal',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ID e Número da Nota
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'ID',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numeroNotaController,
                      decoration: const InputDecoration(
                        labelText: 'Número da Nota',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _serieController,
                      decoration: const InputDecoration(
                        labelText: 'Série',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Datas
              Row(
                children: [
                  Expanded(
                    child: _buildDataField('Data de Emissão', _dataEmissao, _selecionarDataEmissao),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDataField('Data de Entrada', _dataEntrada, _selecionarDataEntrada),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Fornecedor
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ do Fornecedor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _razaoSocialController,
                decoration: const InputDecoration(
                  labelText: 'Razão Social do Fornecedor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço do Fornecedor (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone do Fornecedor (Opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 16),
              
              // Informações dos Itens (se houver)
              _buildInfoItens(),
              
              const SizedBox(height: 16),
              
              // Valores
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorProdutosController,
                      decoration: const InputDecoration(
                        labelText: 'Valor dos Produtos',
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valorNotaController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Total da Nota',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Custos adicionais
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorFreteController,
                      decoration: const InputDecoration(
                        labelText: 'Valor do Frete (Opcional)',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calcularValorTotal(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valorSeguroController,
                      decoration: const InputDecoration(
                        labelText: 'Valor do Seguro (Opcional)',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calcularValorTotal(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _outrasDespesasController,
                decoration: const InputDecoration(
                  labelText: 'Outras Despesas (Opcional)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calcularValorTotal(),
              ),
              
              const SizedBox(height: 16),
              
              // Tipo de Frete e Status
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tipoFreteSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Frete',
                        border: OutlineInputBorder(),
                      ),
                      items: _tiposFrete.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoFreteSelecionado = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Botão para Gerenciar Itens (APENAS para status Pendente)
              if (_statusSelecionado.toLowerCase() == 'pendente')
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _abrirGerenciadorItens,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Gerenciar Itens da Nota Fiscal'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                ),
              
              // Botão Salvar
              ElevatedButton(
                onPressed: _salvarNotaFiscal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Nota Fiscal'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}