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
      numeroNota: fields[1] as String,
      serie: fields[2] as String,
      dataEmissao: fields[3] as DateTime,
      dataEntrada: fields[4] as DateTime,
      cnpjFornecedor: fields[5] as String,
      razaoSocialFornecedor: fields[6] as String,
      enderecoFornecedor: fields[7] as String?,
      telefoneFornecedor: fields[8] as String?,
      valorTotalProdutos: fields[9] as double,
      valorTotalNota: fields[10] as double,
      valorFrete: fields[11] as double?,
      valorSeguro: fields[12] as double?,
      outrasDespesas: fields[13] as double?,
      tipoFrete: fields[14] as String,
      status: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotaFiscal obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.idNotaFiscal)
      ..writeByte(1)
      ..write(obj.numeroNota)
      ..writeByte(2)
      ..write(obj.serie)
      ..writeByte(3)
      ..write(obj.dataEmissao)
      ..writeByte(4)
      ..write(obj.dataEntrada)
      ..writeByte(5)
      ..write(obj.cnpjFornecedor)
      ..writeByte(6)
      ..write(obj.razaoSocialFornecedor)
      ..writeByte(7)
      ..write(obj.enderecoFornecedor)
      ..writeByte(8)
      ..write(obj.telefoneFornecedor)
      ..writeByte(9)
      ..write(obj.valorTotalProdutos)
      ..writeByte(10)
      ..write(obj.valorTotalNota)
      ..writeByte(11)
      ..write(obj.valorFrete)
      ..writeByte(12)
      ..write(obj.valorSeguro)
      ..writeByte(13)
      ..write(obj.outrasDespesas)
      ..writeByte(14)
      ..write(obj.tipoFrete)
      ..writeByte(15)
      ..write(obj.status);
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