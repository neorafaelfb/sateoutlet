import 'package:hive/hive.dart';

part 'nota_fiscal.g.dart';

@HiveType(typeId: 2)
class NotaFiscal {
  @HiveField(0)
  final int idNotaFiscal;
  
  @HiveField(1)
  final DateTime dataEmissao;
  
  @HiveField(2)
  final String detalhesFornecedor;
  
  @HiveField(3)
  final double valorTotal;

  NotaFiscal({
    required this.idNotaFiscal,
    required this.dataEmissao,
    required this.detalhesFornecedor,
    required this.valorTotal,
  });
}