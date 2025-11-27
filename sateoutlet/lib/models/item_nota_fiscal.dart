import 'package:hive/hive.dart';

part 'item_nota_fiscal.g.dart';

@HiveType(typeId: 3)
class ItemNotaFiscal {
  @HiveField(0)
  final int idItem;
  
  @HiveField(1)
  final int idNotaFiscal;
  
  @HiveField(2)
  final int idMovel;
  
  @HiveField(3)
  final int quantidade;
  
  @HiveField(4)
  final double precoUnitario;
  
  @HiveField(5)
  final double valorTotalItem;

  ItemNotaFiscal({
    required this.idItem,
    required this.idNotaFiscal,
    required this.idMovel,
    required this.quantidade,
    required this.precoUnitario,
    required this.valorTotalItem,
  });

  // Para Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'idItem': idItem,
      'idNotaFiscal': idNotaFiscal,
      'idMovel': idMovel,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
      'valorTotalItem': valorTotalItem,
    };
  }

  factory ItemNotaFiscal.fromMap(Map<String, dynamic> map) {
    return ItemNotaFiscal(
      idItem: map['idItem'] as int,
      idNotaFiscal: map['idNotaFiscal'] as int,
      idMovel: map['idMovel'] as int,
      quantidade: map['quantidade'] as int,
      precoUnitario: (map['precoUnitario'] as num).toDouble(),
      valorTotalItem: (map['valorTotalItem'] as num).toDouble(),
    );
  }
}