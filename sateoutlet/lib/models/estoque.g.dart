// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estoque.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EstoqueAdapter extends TypeAdapter<Estoque> {
  @override
  final int typeId = 1;

  @override
  Estoque read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Estoque(
      idEstoque: fields[0] as int,
      idMovel: fields[1] as int,
      localizacaoFisica: fields[2] as String,
      status: fields[3] as String,
      dataAtualizacao: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Estoque obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.idEstoque)
      ..writeByte(1)
      ..write(obj.idMovel)
      ..writeByte(2)
      ..write(obj.localizacaoFisica)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.dataAtualizacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstoqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
