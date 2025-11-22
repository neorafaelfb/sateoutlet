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
}