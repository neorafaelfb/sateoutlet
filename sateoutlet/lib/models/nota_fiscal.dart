import 'package:hive/hive.dart';

part 'nota_fiscal.g.dart';

@HiveType(typeId: 2)
class NotaFiscal {
  @HiveField(0)
  final int idNotaFiscal;
  
  @HiveField(1)
  final String numeroNota;
  
  @HiveField(2)
  final String serie;
  
  @HiveField(3)
  final DateTime dataEmissao;
  
  @HiveField(4)
  final DateTime dataEntrada;
  
  @HiveField(5)
  final String cnpjFornecedor;
  
  @HiveField(6)
  final String razaoSocialFornecedor;
  
  @HiveField(7)
  final String? enderecoFornecedor;
  
  @HiveField(8)
  final String? telefoneFornecedor;
  
  @HiveField(9)
  final double valorTotalProdutos;
  
  @HiveField(10)
  final double valorTotalNota;
  
  @HiveField(11)
  final double? valorFrete;
  
  @HiveField(12)
  final double? valorSeguro;
  
  @HiveField(13)
  final double? outrasDespesas;
  
  @HiveField(14)
  final String tipoFrete;
  
  @HiveField(15)
  final String status;

  NotaFiscal({
    required this.idNotaFiscal,
    required this.numeroNota,
    required this.serie,
    required this.dataEmissao,
    required this.dataEntrada,
    required this.cnpjFornecedor,
    required this.razaoSocialFornecedor,
    this.enderecoFornecedor,
    this.telefoneFornecedor,
    required this.valorTotalProdutos,
    required this.valorTotalNota,
    this.valorFrete,
    this.valorSeguro,
    this.outrasDespesas,
    required this.tipoFrete,
    required this.status,
  });

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idNotaFiscal': idNotaFiscal,
      'numeroNota': numeroNota,
      'serie': serie,
      'dataEmissao': dataEmissao.toIso8601String(),
      'dataEntrada': dataEntrada.toIso8601String(),
      'cnpjFornecedor': cnpjFornecedor,
      'razaoSocialFornecedor': razaoSocialFornecedor,
      'enderecoFornecedor': enderecoFornecedor,
      'telefoneFornecedor': telefoneFornecedor,
      'valorTotalProdutos': valorTotalProdutos,
      'valorTotalNota': valorTotalNota,
      'valorFrete': valorFrete,
      'valorSeguro': valorSeguro,
      'outrasDespesas': outrasDespesas,
      'tipoFrete': tipoFrete,
      'status': status,
    };
  }

  factory NotaFiscal.fromMap(Map<String, dynamic> map) {
    return NotaFiscal(
      idNotaFiscal: map['idNotaFiscal'] as int,
      numeroNota: map['numeroNota'] as String,
      serie: map['serie'] as String,
      dataEmissao: DateTime.parse(map['dataEmissao'] as String),
      dataEntrada: DateTime.parse(map['dataEntrada'] as String),
      cnpjFornecedor: map['cnpjFornecedor'] as String,
      razaoSocialFornecedor: map['razaoSocialFornecedor'] as String,
      enderecoFornecedor: map['enderecoFornecedor'] as String?,
      telefoneFornecedor: map['telefoneFornecedor'] as String?,
      valorTotalProdutos: (map['valorTotalProdutos'] as num).toDouble(),
      valorTotalNota: (map['valorTotalNota'] as num).toDouble(),
      valorFrete: (map['valorFrete'] as num?)?.toDouble(),
      valorSeguro: (map['valorSeguro'] as num?)?.toDouble(),
      outrasDespesas: (map['outrasDespesas'] as num?)?.toDouble(),
      tipoFrete: map['tipoFrete'] as String,
      status: map['status'] as String,
    );
  }
}