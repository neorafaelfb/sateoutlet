import 'package:hive/hive.dart';

part 'movel.g.dart';

@HiveType(typeId: 0)
class Movel {
  @HiveField(0)
  final int idMovel;
  
  @HiveField(1)
  final String tipoMovel;
  
  @HiveField(2)
  final String nome;
  
  @HiveField(3)
  final String dimensoes;
  
  @HiveField(4)
  final double precoVenda;
  
  @HiveField(5)
  final int idNotaFiscal;

  Movel({
    required this.idMovel,
    required this.tipoMovel,
    required this.nome,
    required this.dimensoes,
    required this.precoVenda,
    required this.idNotaFiscal,
  });

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idMovel': idMovel,
      'tipoMovel': tipoMovel,
      'nome': nome,
      'dimensoes': dimensoes,
      'precoVenda': precoVenda,
      'idNotaFiscal': idNotaFiscal,
    };
  }

  factory Movel.fromMap(Map<String, dynamic> map) {
    return Movel(
      idMovel: map['idMovel'] as int,
      tipoMovel: map['tipoMovel'] as String,
      nome: map['nome'] as String,
      dimensoes: map['dimensoes'] as String,
      precoVenda: (map['precoVenda'] as num).toDouble(),
      idNotaFiscal: map['idNotaFiscal'] as int,
    );
  }
}