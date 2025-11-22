// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovelAdapter extends TypeAdapter<Movel> {
  @override
  final int typeId = 0;

  @override
  Movel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movel(
      idMovel: fields[0] as int,
      tipoMovel: fields[1] as String,
      nome: fields[2] as String,
      dimensoes: fields[3] as String,
      precoVenda: fields[4] as double,
      idNotaFiscal: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Movel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idMovel)
      ..writeByte(1)
      ..write(obj.tipoMovel)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.dimensoes)
      ..writeByte(4)
      ..write(obj.precoVenda)
      ..writeByte(5)
      ..write(obj.idNotaFiscal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
