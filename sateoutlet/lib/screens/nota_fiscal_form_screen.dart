import 'package:flutter/material.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';

class NotaFiscalFormScreen extends StatefulWidget {
  final NotaFiscal? notaFiscal;

  const NotaFiscalFormScreen({super.key, this.notaFiscal});

  @override
  State<NotaFiscalFormScreen> createState() => _NotaFiscalFormScreenState();
}

class _NotaFiscalFormScreenState extends State<NotaFiscalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _fornecedorController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _dataEmissao = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.notaFiscal != null) {
      _idController.text = widget.notaFiscal!.idNotaFiscal.toString();
      _fornecedorController.text = widget.notaFiscal!.detalhesFornecedor;
      _valorController.text = widget.notaFiscal!.valorTotal.toString();
      _dataEmissao = widget.notaFiscal!.dataEmissao;
    } else {
      final notas = HiveService.getAllNotasFiscais();
      final novoId = notas.isEmpty ? 1 : (notas.last.idNotaFiscal + 1);
      _idController.text = novoId.toString();
    }
  }

  Future<void> _selecionarData() async {
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

  void _salvarNotaFiscal() {
    if (_formKey.currentState!.validate()) {
      final notaFiscal = NotaFiscal(
        idNotaFiscal: int.parse(_idController.text),
        dataEmissao: _dataEmissao,
        detalhesFornecedor: _fornecedorController.text,
        valorTotal: double.parse(_valorController.text),
      );

      if (widget.notaFiscal == null) {
        HiveService.addNotaFiscal(notaFiscal);
      } else {
        HiveService.updateNotaFiscal(notaFiscal);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notaFiscal == null ? 'Nova Nota Fiscal' : 'Editar Nota Fiscal'),
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
                  labelText: 'Número da Nota Fiscal',
                  border: OutlineInputBorder(),
                ),
                readOnly: widget.notaFiscal != null,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _fornecedorController,
                decoration: const InputDecoration(
                  labelText: 'Detalhes do Fornecedor',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor Total',
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
              
              Row(
                children: [
                  const Text(
                    'Data de Emissão:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_dataEmissao.day}/${_dataEmissao.month}/${_dataEmissao.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selecionarData,
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
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