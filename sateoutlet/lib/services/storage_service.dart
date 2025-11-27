import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ Shared Preferences inicializado');
  }

  // Método melhorado para migração com conversão de tipos
  static Future<void> migrarDadosAntigos() async {
    print('🔄 Verificando dados antigos para migração...');
    
    try {
      // Limpar dados migrados anteriores se existirem
      await _prefs.remove('itens_nota_fiscal');
      
      // Converter móveis
      await _migrarMoveis();
      
      // Converter notas fiscais
      await _migrarNotasFiscais();
      
      // Criar itens de nota fiscal
      await _criarItensNotaFiscal();
      
      print('✅ Migração de dados concluída com sucesso!');
      
    } catch (e) {
      print('❌ Erro na migração de dados: $e');
      // Em caso de erro, criar dados de exemplo
      await _criarDadosExemplo();
    }
  }

  static Future<void> _migrarMoveis() async {
    final dadosAntigos = _prefs.getString('moveis');
    if (dadosAntigos == null) {
      print('📝 Nenhum dado de móveis encontrado, criando dados de exemplo...');
      await _criarDadosExemplo();
      return;
    }

    try {
      final List<dynamic> decoded = json.decode(dadosAntigos);
      final moveisNovos = <Map<String, dynamic>>[];
      
      for (final movel in decoded) {
        if (movel is Map<String, dynamic>) {
          // Conversão robusta de tipos
          final movelNovo = {
            'idMovel': _converterParaInt(movel['idMovel']),
            'tipoMovel': _converterParaString(movel['tipoMovel']),
            'nome': _converterParaString(movel['nome']),
            'dimensoes': _converterParaString(movel['dimensoes']),
            'precoVendaSugerido': _converterParaDouble(movel['precoVenda'] ?? movel['precoVendaSugerido']),
            'codigoBarras': _converterParaStringOptional(movel['codigoBarras']),
            'material': _converterParaStringOptional(movel['material']),
            'cor': _converterParaStringOptional(movel['cor']),
            'fabricante': _converterParaStringOptional(movel['fabricante']),
          };
          moveisNovos.add(movelNovo);
        }
      }
      
      await saveMoveis(moveisNovos);
      print('✅ Móveis migrados: ${moveisNovos.length}');
      
    } catch (e) {
      print('❌ Erro ao migrar móveis: $e');
      throw e;
    }
  }

  static Future<void> _migrarNotasFiscais() async {
    final dadosAntigos = _prefs.getString('notas_fiscais');
    if (dadosAntigos == null) {
      print('📝 Nenhum dado de notas fiscais encontrado, criando dados de exemplo...');
      return;
    }

    try {
      final List<dynamic> decoded = json.decode(dadosAntigos);
      final notasNovas = <Map<String, dynamic>>[];
      
      for (final nota in decoded) {
        if (nota is Map<String, dynamic>) {
          final notaNova = {
            'idNotaFiscal': _converterParaInt(nota['idNotaFiscal']),
            'numeroNota': _converterParaString(nota['numeroNota'] ?? nota['idNotaFiscal'].toString()),
            'serie': _converterParaString(nota['serie'] ?? '1'),
            'dataEmissao': _converterParaDateTime(nota['dataEmissao']),
            'dataEntrada': _converterParaDateTime(nota['dataEntrada'] ?? nota['dataEmissao']),
            'cnpjFornecedor': _converterParaString(nota['cnpjFornecedor'] ?? '12.345.678/0001-90'),
            'razaoSocialFornecedor': _converterParaString(nota['razaoSocialFornecedor'] ?? nota['detalhesFornecedor'] ?? 'Fornecedor Padrão'),
            'enderecoFornecedor': _converterParaStringOptional(nota['enderecoFornecedor']),
            'telefoneFornecedor': _converterParaStringOptional(nota['telefoneFornecedor']),
            'valorTotalProdutos': _converterParaDouble(nota['valorTotalProdutos'] ?? nota['valorTotal']),
            'valorTotalNota': _converterParaDouble(nota['valorTotalNota'] ?? nota['valorTotal']),
            'valorFrete': _converterParaDoubleOptional(nota['valorFrete']),
            'valorSeguro': _converterParaDoubleOptional(nota['valorSeguro']),
            'outrasDespesas': _converterParaDoubleOptional(nota['outrasDespesas']),
            'tipoFrete': _converterParaString(nota['tipoFrete'] ?? 'CIF'),
            'status': _converterParaString(nota['status'] ?? 'Finalizada'),
          };
          notasNovas.add(notaNova);
        }
      }
      
      await saveNotasFiscais(notasNovas);
      print('✅ Notas fiscais migradas: ${notasNovas.length}');
      
    } catch (e) {
      print('❌ Erro ao migrar notas fiscais: $e');
      throw e;
    }
  }

  static Future<void> _criarItensNotaFiscal() async {
    try {
      final moveis = loadMoveis();
      final itensNotaFiscal = <Map<String, dynamic>>[];
      int itemId = 1;
      
      // Para cada móvel que tinha idNotaFiscal no formato antigo, criar um item
      for (final movel in moveis) {
        // Se o móvel tinha um idNotaFiscal no formato antigo, criar item
        if (movel['idNotaFiscal'] != null && _converterParaInt(movel['idNotaFiscal']) > 0) {
          final item = {
            'idItem': itemId++,
            'idNotaFiscal': _converterParaInt(movel['idNotaFiscal']),
            'idMovel': _converterParaInt(movel['idMovel']),
            'quantidade': 1,
            'precoUnitario': _converterParaDouble(movel['precoVendaSugerido']),
            'valorTotalItem': _converterParaDouble(movel['precoVendaSugerido']),
          };
          itensNotaFiscal.add(item);
        }
      }
      
      // Se não encontrou relacionamentos antigos, criar alguns exemplos
      if (itensNotaFiscal.isEmpty && moveis.isNotEmpty) {
        print('📝 Criando itens de nota fiscal de exemplo...');
        final notas = loadNotasFiscais();
        if (notas.isNotEmpty && moveis.length >= 2) {
          itensNotaFiscal.addAll([
            {
              'idItem': 1,
              'idNotaFiscal': _converterParaInt(notas[0]['idNotaFiscal']),
              'idMovel': _converterParaInt(moveis[0]['idMovel']),
              'quantidade': 2,
              'precoUnitario': 1200.00,
              'valorTotalItem': 2400.00,
            },
            {
              'idItem': 2,
              'idNotaFiscal': _converterParaInt(notas[0]['idNotaFiscal']),
              'idMovel': _converterParaInt(moveis[1]['idMovel']),
              'quantidade': 1,
              'precoUnitario': 850.00,
              'valorTotalItem': 850.00,
            },
          ]);
        }
      }
      
      await saveItensNotaFiscal(itensNotaFiscal);
      print('✅ Itens de nota fiscal criados: ${itensNotaFiscal.length}');
      
    } catch (e) {
      print('❌ Erro ao criar itens de nota fiscal: $e');
      throw e;
    }
  }

  // Métodos auxiliares para conversão de tipos
  static int _converterParaInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _converterParaDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _converterParaDoubleOptional(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed == 0.0 ? null : parsed;
    }
    return null;
  }

  static String _converterParaString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _converterParaStringOptional(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    final stringValue = value.toString();
    return stringValue.isEmpty ? null : stringValue;
  }

  static String _converterParaDateTime(dynamic value) {
    if (value == null) return DateTime.now().toIso8601String();
    if (value is String) {
      try {
        DateTime.parse(value);
        return value;
      } catch (e) {
        return DateTime.now().toIso8601String();
      }
    }
    return DateTime.now().toIso8601String();
  }

  static Future<void> _criarDadosExemplo() async {
    print('📝 Criando dados de exemplo...');
    
    final moveisExemplo = [
      {
        'idMovel': 1,
        'tipoMovel': 'Sofá',
        'nome': 'Sofá Retrátil 3 Lugares Couro',
        'dimensoes': '200x90x80 cm',
        'precoVendaSugerido': 1899.90,
        'material': 'Couro sintético',
        'cor': 'Marrom',
        'fabricante': 'MoveisConfort',
      },
      {
        'idMovel': 2,
        'tipoMovel': 'Mesa',
        'nome': 'Mesa de Jantar 6 Lugares Madeira Maciça',
        'dimensoes': '180x90x75 cm',
        'precoVendaSugerido': 1200.00,
        'material': 'Madeira maciça',
        'cor': 'Natural',
        'fabricante': 'MadeiraNobre',
      },
    ];
    
    final notasExemplo = [
      {
        'idNotaFiscal': 1,
        'numeroNota': '000001',
        'serie': '1',
        'dataEmissao': DateTime.now().toIso8601String(),
        'dataEntrada': DateTime.now().toIso8601String(),
        'cnpjFornecedor': '12.345.678/0001-90',
        'razaoSocialFornecedor': 'Madeireira Silva Ltda',
        'valorTotalProdutos': 3250.00,
        'valorTotalNota': 3250.00,
        'tipoFrete': 'CIF',
        'status': 'Finalizada',
      },
    ];
    
    await saveMoveis(moveisExemplo);
    await saveNotasFiscais(notasExemplo);
    
    print('✅ Dados de exemplo criados!');
  }

  // Mantenha os outros métodos existentes (saveMoveis, loadMoveis, etc.)
  static Future<void> saveMoveis(List<Map<String, dynamic>> moveis) async {
    await _prefs.setString('moveis', json.encode(moveis));
    print('💾 Móveis salvos no Shared Preferences: ${moveis.length} itens');
  }

  static List<Map<String, dynamic>> loadMoveis() {
    final data = _prefs.getString('moveis');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('❌ Erro ao carregar móveis: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> saveEstoques(List<Map<String, dynamic>> estoques) async {
    await _prefs.setString('estoques', json.encode(estoques));
    print('💾 Estoques salvos no Shared Preferences: ${estoques.length} itens');
  }

  static List<Map<String, dynamic>> loadEstoques() {
    final data = _prefs.getString('estoques');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('❌ Erro ao carregar estoques: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> saveNotasFiscais(List<Map<String, dynamic>> notas) async {
    await _prefs.setString('notas_fiscais', json.encode(notas));
    print('💾 Notas Fiscais salvas no Shared Preferences: ${notas.length} itens');
  }

  static List<Map<String, dynamic>> loadNotasFiscais() {
    final data = _prefs.getString('notas_fiscais');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('❌ Erro ao carregar notas fiscais: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> saveItensNotaFiscal(List<Map<String, dynamic>> itens) async {
    await _prefs.setString('itens_nota_fiscal', json.encode(itens));
    print('💾 Itens Nota Fiscal salvos no Shared Preferences: ${itens.length} itens');
  }

  static List<Map<String, dynamic>> loadItensNotaFiscal() {
    final data = _prefs.getString('itens_nota_fiscal');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('❌ Erro ao carregar itens nota fiscal: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> clearAll() async {
    await _prefs.remove('moveis');
    await _prefs.remove('estoques');
    await _prefs.remove('notas_fiscais');
    await _prefs.remove('itens_nota_fiscal');
    print('🗑️ Todos os dados do Shared Preferences foram limpos');
  }

  static bool hasData() {
    return _prefs.containsKey('moveis') || 
           _prefs.containsKey('estoques') || 
           _prefs.containsKey('notas_fiscais') ||
           _prefs.containsKey('itens_nota_fiscal');
  }

  static void printStatus() {
    final moveis = loadMoveis();
    final estoques = loadEstoques();
    final notas = loadNotasFiscais();
    final itens = loadItensNotaFiscal();
    
    print('=== STATUS SHARED PREFERENCES ===');
    print('Móveis: ${moveis.length}');
    print('Estoques: ${estoques.length}');
    print('Notas Fiscais: ${notas.length}');
    print('Itens Nota Fiscal: ${itens.length}');
    print('=================================');
  }
}