import 'package:hive/hive.dart';

part 'estoque.g.dart';

@HiveType(typeId: 1)
class Estoque {
  @HiveField(0)
  final int idEstoque;
  
  @HiveField(1)
  final int idMovel;
  
  @HiveField(2)
  final String localizacaoFisica;
  
  @HiveField(3)
  final String status;
  
  @HiveField(4)
  final DateTime dataAtualizacao;

  Estoque({
    required this.idEstoque,
    required this.idMovel,
    required this.localizacaoFisica,
    required this.status,
    required this.dataAtualizacao,
  });

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idEstoque': idEstoque,
      'idMovel': idMovel,
      'localizacaoFisica': localizacaoFisica,
      'status': status,
      'dataAtualizacao': dataAtualizacao.toIso8601String(),
    };
  }

  factory Estoque.fromMap(Map<String, dynamic> map) {
    return Estoque(
      idEstoque: map['idEstoque'] as int,
      idMovel: map['idMovel'] as int,
      localizacaoFisica: map['localizacaoFisica'] as String,
      status: map['status'] as String,
      dataAtualizacao: DateTime.parse(map['dataAtualizacao'] as String),
    );
  }
}