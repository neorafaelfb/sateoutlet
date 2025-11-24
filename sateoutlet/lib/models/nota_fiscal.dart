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

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idNotaFiscal': idNotaFiscal,
      'dataEmissao': dataEmissao.toIso8601String(),
      'detalhesFornecedor': detalhesFornecedor,
      'valorTotal': valorTotal,
    };
  }

  factory NotaFiscal.fromMap(Map<String, dynamic> map) {
    return NotaFiscal(
      idNotaFiscal: map['idNotaFiscal'] as int,
      dataEmissao: DateTime.parse(map['dataEmissao'] as String),
      detalhesFornecedor: map['detalhesFornecedor'] as String,
      valorTotal: (map['valorTotal'] as num).toDouble(),
    );
  }
}