// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_nota_fiscal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemNotaFiscalAdapter extends TypeAdapter<ItemNotaFiscal> {
  @override
  final int typeId = 3;

  @override
  ItemNotaFiscal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemNotaFiscal(
      idItem: fields[0] as int,
      idNotaFiscal: fields[1] as int,
      idMovel: fields[2] as int,
      quantidade: fields[3] as int,
      precoUnitario: fields[4] as double,
      valorTotalItem: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ItemNotaFiscal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idItem)
      ..writeByte(1)
      ..write(obj.idNotaFiscal)
      ..writeByte(2)
      ..write(obj.idMovel)
      ..writeByte(3)
      ..write(obj.quantidade)
      ..writeByte(4)
      ..write(obj.precoUnitario)
      ..writeByte(5)
      ..write(obj.valorTotalItem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemNotaFiscalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}