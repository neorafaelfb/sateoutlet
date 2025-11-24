import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/movel.dart';
import '../models/estoque.dart';
import '../models/nota_fiscal.dart';
import 'storage_service.dart';

class HiveService {
  static late Box<Movel> movelBox;
  static late Box<Estoque> estoqueBox;
  static late Box<NotaFiscal> notaFiscalBox;

  static bool _initialized = false;
  static bool _usingFallback = false;

  static Future<void> init() async {
    if (_initialized) {
      print('Hive já está inicializado');
      return;
    }

    try {
      print('🚀 Inicializando Hive...');
      
      // Inicializar Shared Preferences primeiro
      await StorageService.init();
      
      if (!kIsWeb) {
        final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
        print('📁 Hive Mobile: ${appDocumentDir.path}');
      } else {
        Hive.init(null);
        print('🌐 Hive Web: Modo null initialization');
      }

      // Registrar adaptadores
      _registerAdapters();

      // Abrir boxes
      await _openBoxesWithRetry();

      // Verificar dados e restaurar se necessário
      await _checkAndRestoreData();

      _initialized = true;
      print('✅ Hive inicializado com sucesso!');
      printStatus();
      
    } catch (e) {
      print('❌ ERRO CRÍTICO no Hive: $e');
      print('🔄 Usando apenas Shared Preferences...');
      _usingFallback = true;
      _initialized = true;
    }
  }

  static void _registerAdapters() {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MovelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(EstoqueAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(NotaFiscalAdapter());
      }
      print('🔧 Adaptadores registrados');
    } catch (e) {
      print('❌ Erro ao registrar adaptadores: $e');
    }
  }

  static Future<void> _openBoxesWithRetry() async {
    try {
      movelBox = await Hive.openBox<Movel>('moveis');
      print('📦 Caixa móveis: ${movelBox.length} itens');
    } catch (e) {
      print('❌ Erro ao abrir caixa móveis: $e');
      movelBox = Hive.box<Movel>('moveis');
    }

    try {
      estoqueBox = await Hive.openBox<Estoque>('estoque');
      print('📦 Caixa estoque: ${estoqueBox.length} itens');
    } catch (e) {
      print('❌ Erro ao abrir caixa estoque: $e');
      estoqueBox = Hive.box<Estoque>('estoque');
    }

    try {
      notaFiscalBox = await Hive.openBox<NotaFiscal>('notas_fiscais');
      print('📦 Caixa notas: ${notaFiscalBox.length} itens');
    } catch (e) {
      print('❌ Erro ao abrir caixa notas: $e');
      notaFiscalBox = Hive.box<NotaFiscal>('notas_fiscais');
    }
  }

  static Future<void> _checkAndRestoreData() async {
    final hiveHasData = movelBox.isNotEmpty || estoqueBox.isNotEmpty || notaFiscalBox.isNotEmpty;
    final spHasData = StorageService.hasData();

    print('🔍 Verificação de dados:');
    print('   - Hive tem dados: $hiveHasData');
    print('   - Shared Preferences tem dados: $spHasData');

    if (!hiveHasData && spHasData) {
      print('🔄 Restaurando dados do Shared Preferences...');
      await _restoreFromFallback();
    } else if (!hiveHasData && !spHasData) {
      print('📝 Adicionando dados de exemplo...');
      await _adicionarDadosExemplo();
    } else {
      print('✅ Dados já existem, fazendo backup...');
      await _backupToFallback();
    }
  }

  static Future<void> _restoreFromFallback() async {
    try {
      // Restaurar Notas Fiscais
      final notasData = StorageService.loadNotasFiscais();
      for (final notaData in notasData) {
        final nota = NotaFiscal(
          idNotaFiscal: notaData['idNotaFiscal'] as int,
          dataEmissao: DateTime.parse(notaData['dataEmissao'] as String),
          detalhesFornecedor: notaData['detalhesFornecedor'] as String,
          valorTotal: (notaData['valorTotal'] as num).toDouble(),
        );
        await notaFiscalBox.put(nota.idNotaFiscal, nota);
      }

      // Restaurar Móveis
      final moveisData = StorageService.loadMoveis();
      for (final movelData in moveisData) {
        final movel = Movel(
          idMovel: movelData['idMovel'] as int,
          tipoMovel: movelData['tipoMovel'] as String,
          nome: movelData['nome'] as String,
          dimensoes: movelData['dimensoes'] as String,
          precoVenda: (movelData['precoVenda'] as num).toDouble(),
          idNotaFiscal: movelData['idNotaFiscal'] as int,
        );
        await movelBox.put(movel.idMovel, movel);
      }

      // Restaurar Estoques
      final estoquesData = StorageService.loadEstoques();
      for (final estoqueData in estoquesData) {
        final estoque = Estoque(
          idEstoque: estoqueData['idEstoque'] as int,
          idMovel: estoqueData['idMovel'] as int,
          localizacaoFisica: estoqueData['localizacaoFisica'] as String,
          status: estoqueData['status'] as String,
          dataAtualizacao: DateTime.parse(estoqueData['dataAtualizacao'] as String),
        );
        await estoqueBox.put(estoque.idEstoque, estoque);
      }

      print('✅ Dados restaurados do Shared Preferences!');
    } catch (e) {
      print('❌ Erro ao restaurar dados: $e');
    }
  }

  static Future<void> _backupToFallback() async {
    try {
      // Backup de Notas Fiscais
      final notasData = notaFiscalBox.values.map((nota) => {
        'idNotaFiscal': nota.idNotaFiscal,
        'dataEmissao': nota.dataEmissao.toIso8601String(),
        'detalhesFornecedor': nota.detalhesFornecedor,
        'valorTotal': nota.valorTotal,
      }).toList();
      await StorageService.saveNotasFiscais(notasData);

      // Backup de Móveis
      final moveisData = movelBox.values.map((movel) => {
        'idMovel': movel.idMovel,
        'tipoMovel': movel.tipoMovel,
        'nome': movel.nome,
        'dimensoes': movel.dimensoes,
        'precoVenda': movel.precoVenda,
        'idNotaFiscal': movel.idNotaFiscal,
      }).toList();
      await StorageService.saveMoveis(moveisData);

      // Backup de Estoques
      final estoquesData = estoqueBox.values.map((estoque) => {
        'idEstoque': estoque.idEstoque,
        'idMovel': estoque.idMovel,
        'localizacaoFisica': estoque.localizacaoFisica,
        'status': estoque.status,
        'dataAtualizacao': estoque.dataAtualizacao.toIso8601String(),
      }).toList();
      await StorageService.saveEstoques(estoquesData);

      print('💾 Backup realizado no Shared Preferences');
    } catch (e) {
      print('❌ Erro no backup: $e');
    }
  }

  static Future<void> _adicionarDadosExemplo() async {
    try {
      // Nota Fiscal 1
      final nota1 = NotaFiscal(
        idNotaFiscal: 1,
        dataEmissao: DateTime.now(),
        detalhesFornecedor: 'Madeireira Silva Ltda',
        valorTotal: 3500.00,
      );
      await addNotaFiscal(nota1);

      // Nota Fiscal 2
      final nota2 = NotaFiscal(
        idNotaFiscal: 2,
        dataEmissao: DateTime.now().subtract(const Duration(days: 5)),
        detalhesFornecedor: 'Marcenaria Premium S.A',
        valorTotal: 5200.00,
      );
      await addNotaFiscal(nota2);

      // Móveis
      final movel1 = Movel(
        idMovel: 1,
        tipoMovel: 'Sofá',
        nome: 'Sofá Retrátil 3 Lugares Couro',
        dimensoes: '200x90x80 cm',
        precoVenda: 1899.90,
        idNotaFiscal: 1,
      );
      await addMovel(movel1);

      final movel2 = Movel(
        idMovel: 2,
        tipoMovel: 'Mesa',
        nome: 'Mesa de Jantar 6 Lugares Madeira Maciça',
        dimensoes: '180x90x75 cm',
        precoVenda: 1200.00,
        idNotaFiscal: 2,
      );
      await addMovel(movel2);

      final movel3 = Movel(
        idMovel: 3,
        tipoMovel: 'Cama',
        nome: 'Cama Box Queen Size Casal',
        dimensoes: '198x138x100 cm',
        precoVenda: 850.00,
        idNotaFiscal: 1,
      );
      await addMovel(movel3);

      // Estoques
      final estoque1 = Estoque(
        idEstoque: 1,
        idMovel: 1,
        localizacaoFisica: 'Prateleira A-15',
        status: 'Disponível',
        dataAtualizacao: DateTime.now(),
      );
      await addEstoque(estoque1);

      final estoque2 = Estoque(
        idEstoque: 2,
        idMovel: 2,
        localizacaoFisica: 'Setor B-20',
        status: 'Disponível',
        dataAtualizacao: DateTime.now(),
      );
      await addEstoque(estoque2);

      // Fazer backup
      await _backupToFallback();
      
      print('✅ Dados de exemplo adicionados com sucesso!');
      
    } catch (e) {
      print('❌ Erro ao adicionar dados de exemplo: $e');
    }
  }

  // CRUD para Móveis
  static Future<void> addMovel(Movel movel) async {
    await movelBox.put(movel.idMovel, movel);
    await _backupToFallback();
    print('✅ Móvel ${movel.idMovel} salvo: ${movel.nome}');
  }

  static Movel? getMovel(int id) {
    return movelBox.get(id);
  }

  static List<Movel> getAllMoveis() {
    return movelBox.values.toList();
  }

  static Future<void> updateMovel(Movel movel) async {
    await movelBox.put(movel.idMovel, movel);
    await _backupToFallback();
    print('✅ Móvel ${movel.idMovel} atualizado');
  }

  static Future<void> deleteMovel(int id) async {
    await movelBox.delete(id);
    await _backupToFallback();
    print('✅ Móvel $id excluído');
  }

  // CRUD para Estoque
  static Future<void> addEstoque(Estoque estoque) async {
    await estoqueBox.put(estoque.idEstoque, estoque);
    await _backupToFallback();
    print('✅ Estoque ${estoque.idEstoque} salvo para móvel ${estoque.idMovel}');
  }

  static Estoque? getEstoque(int id) {
    return estoqueBox.get(id);
  }

  static List<Estoque> getAllEstoque() {
    return estoqueBox.values.toList();
  }

  static Future<void> updateEstoque(Estoque estoque) async {
    await estoqueBox.put(estoque.idEstoque, estoque);
    await _backupToFallback();
    print('✅ Estoque ${estoque.idEstoque} atualizado');
  }

  static Future<void> deleteEstoque(int id) async {
    await estoqueBox.delete(id);
    await _backupToFallback();
    print('✅ Estoque $id excluído');
  }

  // CRUD para Nota Fiscal
  static Future<void> addNotaFiscal(NotaFiscal nota) async {
    await notaFiscalBox.put(nota.idNotaFiscal, nota);
    await _backupToFallback();
    print('✅ Nota Fiscal ${nota.idNotaFiscal} salva');
  }

  static NotaFiscal? getNotaFiscal(int id) {
    return notaFiscalBox.get(id);
  }

  static List<NotaFiscal> getAllNotasFiscais() {
    return notaFiscalBox.values.toList();
  }

  static Future<void> updateNotaFiscal(NotaFiscal nota) async {
    await notaFiscalBox.put(nota.idNotaFiscal, nota);
    await _backupToFallback();
    print('✅ Nota Fiscal ${nota.idNotaFiscal} atualizada');
  }

  static Future<void> deleteNotaFiscal(int id) async {
    await notaFiscalBox.delete(id);
    await _backupToFallback();
    print('✅ Nota Fiscal $id excluída');
  }

  // Métodos auxiliares
  static List<Estoque> getEstoquePorMovel(int idMovel) {
    return estoqueBox.values
        .where((estoque) => estoque.idMovel == idMovel)
        .toList();
  }

  static List<Movel> getMoveisPorNotaFiscal(int idNotaFiscal) {
    return movelBox.values
        .where((movel) => movel.idNotaFiscal == idNotaFiscal)
        .toList();
  }

  static List<Movel> getMoveisDisponiveis() {
    return movelBox.values.toList();
  }

  static List<Movel> getMoveisParaEstoque() {
    final todosMoveis = movelBox.values.toList();
    final estoques = estoqueBox.values.toList();
    
    return todosMoveis.where((movel) {
      return !estoques.any((estoque) => estoque.idMovel == movel.idMovel);
    }).toList();
  }

  static bool existeMovel(int idMovel) {
    return movelBox.containsKey(idMovel);
  }

  static bool existeNotaFiscal(int idNotaFiscal) {
    return notaFiscalBox.containsKey(idNotaFiscal);
  }

  // Exclusão segura
  static Future<void> deleteNotaFiscalSafe(int id) async {
    final moveisVinculados = getMoveisPorNotaFiscal(id);
    
    if (moveisVinculados.isNotEmpty) {
      throw Exception('Não é possível excluir a nota fiscal pois existem ${moveisVinculados.length} móvel(éis) vinculado(s) a ela.');
    }
    
    await notaFiscalBox.delete(id);
    await _backupToFallback();
  }

  static Future<void> deleteMovelSafe(int id) async {
    final estoquesVinculados = getEstoquePorMovel(id);
    
    if (estoquesVinculados.isNotEmpty) {
      throw Exception('Não é possível excluir o móvel pois existem ${estoquesVinculados.length} item(ns) em estoque vinculado(s) a ele.');
    }
    
    await movelBox.delete(id);
    await _backupToFallback();
  }

  // Exclusão em cascata
  static Future<void> deleteMovelCascade(int id) async {
    final estoquesVinculados = getEstoquePorMovel(id);
    for (final estoque in estoquesVinculados) {
      await estoqueBox.delete(estoque.idEstoque);
    }
    
    await movelBox.delete(id);
    await _backupToFallback();
    print('✅ Móvel $id e estoques excluídos em cascata');
  }

  static Future<void> deleteNotaFiscalCascade(int id) async {
    final moveisVinculados = getMoveisPorNotaFiscal(id);
    for (final movel in moveisVinculados) {
      await deleteMovelCascade(movel.idMovel);
    }
    
    await notaFiscalBox.delete(id);
    await _backupToFallback();
    print('✅ Nota Fiscal $id, móveis e estoques excluídos em cascata');
  }

  // Status
  static void printStatus() {
    print('=== STATUS GERAL ===');
    print('HIVE - Móveis: ${movelBox.length}');
    print('HIVE - Estoques: ${estoqueBox.length}');
    print('HIVE - Notas Fiscais: ${notaFiscalBox.length}');
    StorageService.printStatus();
    print('Usando Fallback: $_usingFallback');
    print('==================');
  }

  // Debug
  static void debugData() {
    print('\n🔍 DEBUG DOS DADOS:');
    print('MÓVEIS:');
    movelBox.values.forEach((movel) {
      print(' - ${movel.idMovel}: ${movel.nome} (Nota: ${movel.idNotaFiscal})');
    });
    print('ESTOQUES:');
    estoqueBox.values.forEach((estoque) {
      print(' - ${estoque.idEstoque}: Móvel ${estoque.idMovel} - ${estoque.localizacaoFisica}');
    });
    print('NOTAS FISCAIS:');
    notaFiscalBox.values.forEach((nota) {
      print(' - ${nota.idNotaFiscal}: ${nota.detalhesFornecedor}');
    });
  }

  // Métodos de Debug
  static Future<void> forceRestoreFromBackup() async {
    print('🔄 FORÇANDO RESTAURAÇÃO MANUAL...');
    await _restoreFromFallback();
    print('✅ Restauração manual concluída!');
  }

  static void debugSharedPreferences() {
    print('\n🔍 DEBUG SHARED PREFERENCES:');
    final moveis = StorageService.loadMoveis();
    final estoques = StorageService.loadEstoques();
    final notas = StorageService.loadNotasFiscais();
    
    print('MÓVEIS NO SP (${moveis.length}):');
    for (final movel in moveis) {
      print(' - ${movel['idMovel']}: ${movel['nome']}');
    }
    
    print('ESTOQUES NO SP (${estoques.length}):');
    for (final estoque in estoques) {
      print(' - ${estoque['idEstoque']}: Móvel ${estoque['idMovel']} - ${estoque['localizacaoFisica']}');
    }
    
    print('NOTAS NO SP (${notas.length}):');
    for (final nota in notas) {
      print(' - ${nota['idNotaFiscal']}: ${nota['detalhesFornecedor']}');
    }
  }

  static void debugRestorationInfo() {
    print('\n🔍 INFO RESTAURAÇÃO:');
    final hiveHasData = movelBox.isNotEmpty || estoqueBox.isNotEmpty || notaFiscalBox.isNotEmpty;
    final spHasData = StorageService.hasData();
    
    print('- Hive tem dados: $hiveHasData');
    print('- Shared Preferences tem dados: $spHasData');
    print('- Móveis no Hive: ${movelBox.length}');
    print('- Estoques no Hive: ${estoqueBox.length}');
    print('- Notas no Hive: ${notaFiscalBox.length}');
    
    final moveisSP = StorageService.loadMoveis();
    final estoquesSP = StorageService.loadEstoques();
    final notasSP = StorageService.loadNotasFiscais();
    
    print('- Móveis no SP: ${moveisSP.length}');
    print('- Estoques no SP: ${estoquesSP.length}');
    print('- Notas no SP: ${notasSP.length}');
    print('- Usando Fallback: $_usingFallback');
  }

  static Future<void> clearAllData() async {
    await movelBox.clear();
    await estoqueBox.clear();
    await notaFiscalBox.clear();
    await StorageService.clearAll();
    print('🗑️ TODOS os dados foram limpos (Hive + Shared Preferences)');
  }
}