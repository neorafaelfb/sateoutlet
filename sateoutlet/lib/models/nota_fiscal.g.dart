// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota_fiscal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotaFiscalAdapter extends TypeAdapter<NotaFiscal> {
  @override
  final int typeId = 2;

  @override
  NotaFiscal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotaFiscal(
      idNotaFiscal: fields[0] as int,
      dataEmissao: fields[1] as DateTime,
      detalhesFornecedor: fields[2] as String,
      valorTotal: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NotaFiscal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idNotaFiscal)
      ..writeByte(1)
      ..write(obj.dataEmissao)
      ..writeByte(2)
      ..write(obj.detalhesFornecedor)
      ..writeByte(3)
      ..write(obj.valorTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaFiscalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
