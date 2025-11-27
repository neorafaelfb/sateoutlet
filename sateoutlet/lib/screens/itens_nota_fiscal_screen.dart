import 'package:flutter/material.dart';
import '../models/nota_fiscal.dart';
import '../models/item_nota_fiscal.dart';
import '../models/movel.dart';
import '../services/hive_service.dart';
import 'adicionar_item_nota_screen.dart';

class ItensNotaFiscalScreen extends StatefulWidget {
  final NotaFiscal notaFiscal;

  const ItensNotaFiscalScreen({super.key, required this.notaFiscal});

  @override
  State<ItensNotaFiscalScreen> createState() => _ItensNotaFiscalScreenState();
}

class _ItensNotaFiscalScreenState extends State<ItensNotaFiscalScreen> {
  List<ItemNotaFiscal> _itens = [];
  double _valorTotalItens = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  void _carregarItens() {
    setState(() {
      _itens = HiveService.getItensPorNotaFiscal(widget.notaFiscal.idNotaFiscal);
      _valorTotalItens = _itens.fold(0.0, (sum, item) => sum + item.valorTotalItem);
    });
  }

  // Adicione este método para atualizar o valor da nota fiscal
void _atualizarValorNotaFiscal() {
  if (widget.notaFiscal.status.toLowerCase() == 'pendente') {
    final valorTotalItens = HiveService.calcularValorTotalNota(widget.notaFiscal.idNotaFiscal);
    
    // Atualizar a nota fiscal com o novo valor
    final notaAtualizada = NotaFiscal(
      idNotaFiscal: widget.notaFiscal.idNotaFiscal,
      numeroNota: widget.notaFiscal.numeroNota,
      serie: widget.notaFiscal.serie,
      dataEmissao: widget.notaFiscal.dataEmissao,
      dataEntrada: widget.notaFiscal.dataEntrada,
      cnpjFornecedor: widget.notaFiscal.cnpjFornecedor,
      razaoSocialFornecedor: widget.notaFiscal.razaoSocialFornecedor,
      enderecoFornecedor: widget.notaFiscal.enderecoFornecedor,
      telefoneFornecedor: widget.notaFiscal.telefoneFornecedor,
      valorTotalProdutos: valorTotalItens, // Atualiza com valor dos itens
      valorTotalNota: valorTotalItens + 
          (widget.notaFiscal.valorFrete ?? 0) +
          (widget.notaFiscal.valorSeguro ?? 0) +
          (widget.notaFiscal.outrasDespesas ?? 0),
      valorFrete: widget.notaFiscal.valorFrete,
      valorSeguro: widget.notaFiscal.valorSeguro,
      outrasDespesas: widget.notaFiscal.outrasDespesas,
      tipoFrete: widget.notaFiscal.tipoFrete,
      status: widget.notaFiscal.status,
    );
    
    HiveService.updateNotaFiscal(notaAtualizada);
  }
}


  // Chame este método sempre que adicionar, editar ou excluir um item
void _adicionarItem() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AdicionarItemNotaScreen(
        idNotaFiscal: widget.notaFiscal.idNotaFiscal,
      ),
    ),
  );
  _carregarItens();
  _atualizarValorNotaFiscal(); // Atualiza o valor da nota
}

  void _editarItem(ItemNotaFiscal item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarItemNotaScreen(
          idNotaFiscal: widget.notaFiscal.idNotaFiscal,
          itemExistente: item,
        ),
      ),
    );
    _carregarItens();
  }

  void _excluirItem(int idItem) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: const Text('Tem certeza que deseja excluir este item da nota fiscal?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            HiveService.deleteItemNotaFiscal(idItem);
            _carregarItens();
            _atualizarValorNotaFiscal(); // Atualiza o valor da nota
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item excluído com sucesso')),
            );
          },
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
}

  Widget _buildMovelInfo(int idMovel) {
    final movel = HiveService.getMovel(idMovel);
    if (movel == null) {
      return const ListTile(
        leading: Icon(Icons.error, color: Colors.red),
        title: Text('Móvel não encontrado'),
        subtitle: Text('O móvel pode ter sido excluído'),
      );
    }

    return ListTile(
      leading: const Icon(Icons.chair, size: 40),
      title: Text(movel.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo: ${movel.tipoMovel}'),
          Text('Dimensões: ${movel.dimensoes}'),
          Text('Preço Sugerido: R\$ ${movel.precoVendaSugerido.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens da Nota ${widget.notaFiscal.numeroNota}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarItem,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo da Nota Fiscal
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Nota Fiscal ${widget.notaFiscal.numeroNota}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Fornecedor: ${widget.notaFiscal.razaoSocialFornecedor}'),
                  Text('Valor Total dos Itens: R\$ ${_valorTotalItens.toStringAsFixed(2)}'),
                  Text('Quantidade de Itens: ${_itens.length}'),
                ],
              ),
            ),
          ),

          // Lista de Itens
          Expanded(
            child: _itens.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum item na nota fiscal',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Clique no + para adicionar itens',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      final movel = HiveService.getMovel(item.idMovel);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.inventory, size: 40),
                          title: Text(movel?.nome ?? 'Móvel #${item.idMovel}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quantidade: ${item.quantidade}'),
                              Text('Preço Unitário: R\$ ${item.precoUnitario.toStringAsFixed(2)}'),
                              Text(
                                'Valor Total: R\$ ${item.valorTotalItem.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarItem(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _excluirItem(item.idItem),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarItem,
        child: const Icon(Icons.add),
      ),
    );
  }
  
}