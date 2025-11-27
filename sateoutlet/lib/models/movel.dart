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
  final double precoVendaSugerido;
  
  @HiveField(5)
  final String? codigoBarras;
  
  @HiveField(6)
  final String? material;
  
  @HiveField(7)
  final String? cor;
  
  @HiveField(8)
  final String? fabricante;

  // REMOVIDO: idNotaFiscal

  Movel({
    required this.idMovel,
    required this.tipoMovel,
    required this.nome,
    required this.dimensoes,
    required this.precoVendaSugerido,
    this.codigoBarras,
    this.material,
    this.cor,
    this.fabricante,
  });

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idMovel': idMovel,
      'tipoMovel': tipoMovel,
      'nome': nome,
      'dimensoes': dimensoes,
      'precoVendaSugerido': precoVendaSugerido,
      'codigoBarras': codigoBarras,
      'material': material,
      'cor': cor,
      'fabricante': fabricante,
    };
  }

  factory Movel.fromMap(Map<String, dynamic> map) {
    return Movel(
      idMovel: map['idMovel'] as int,
      tipoMovel: map['tipoMovel'] as String,
      nome: map['nome'] as String,
      dimensoes: map['dimensoes'] as String,
      precoVendaSugerido: (map['precoVendaSugerido'] as num).toDouble(),
      codigoBarras: map['codigoBarras'] as String?,
      material: map['material'] as String?,
      cor: map['cor'] as String?,
      fabricante: map['fabricante'] as String?,
    );
  }
}