import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/movel.dart';
import '../models/estoque.dart';
import '../models/nota_fiscal.dart';
import '../models/item_nota_fiscal.dart';
import 'storage_service.dart';
import 'package:path/path.dart' as path;
import 'dart:io';


class HiveService {
  static late Box<Movel> movelBox;
  static late Box<Estoque> estoqueBox;
  static late Box<NotaFiscal> notaFiscalBox;
  static late Box<ItemNotaFiscal> itemNotaFiscalBox;

  static bool _initialized = false;
  static bool _usingFallback = false;
  static bool _needsMigration = false;

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
        final appDocumentDir = await _getDatabaseDirectory();
        Hive.init(appDocumentDir.path);
        print('📁 Hive Directory: ${appDocumentDir.path}');
      } else {
        Hive.init(null);
        print('🌐 Hive Web: Modo null initialization');
      }

      // Registrar adaptadores
      _registerAdapters();

      // Tentar abrir boxes com tratamento de erro
      await _openBoxesWithMigration();

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

  static Future<void> migrarParaRelease() async {
  if (kIsWeb) return;
  
  try {
    print('🔄 Iniciando migração para release...');
    
    // Obter diretórios
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    final appSupportDir = await path_provider.getApplicationSupportDirectory();
    final releaseDir = Directory(path.join(appSupportDir.path, 'database'));
    
    if (!releaseDir.existsSync()) {
      releaseDir.createSync(recursive: true);
    }
    
    // Listar arquivos no Documents (debug)
    final debugFiles = Directory(appDocumentDir.path).listSync();
    int filesMigrated = 0;
    
    for (var file in debugFiles) {
      if (file is File && file.path.endsWith('.hive')) {
        final fileName = path.basename(file.path);
        final releaseFile = File(path.join(releaseDir.path, fileName));
        
        // Copiar arquivo para release directory
        file.copySync(releaseFile.path);
        filesMigrated++;
        print('✅ Migrado: $fileName');
      }
    }
    
    print('🎉 Migração concluída! $filesMigrated arquivos migrados para release.');
    print('📁 Release directory: ${releaseDir.path}');
    
  } catch (e) {
    print('❌ Erro na migração: $e');
  }
}

static Future<void> mostrarInfoDiretorios() async {
  if (kIsWeb) {
    print('🌐 Web: Dados no IndexedDB');
    return;
  }
  
  try {
    // Verificar modo
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    
    print('🔍 INFORMAÇÕES DE DIRETÓRIOS:');
    print('   - Modo: ${isDebug ? "DEBUG 🐛" : "RELEASE 🚀"}');
    
    // Mostrar todos os diretórios possíveis
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    final appSupportDir = await path_provider.getApplicationSupportDirectory();
    final tempDir = await path_provider.getTemporaryDirectory();
    
    print('   - Documents: ${appDocumentDir.path}');
    print('   - Application Support: ${appSupportDir.path}');
    print('   - Temporary: ${tempDir.path}');
    
    // Verificar onde estão os arquivos atuais
    final currentDir = await _getDatabaseDirectory();
    print('   - Diretório Atual: ${currentDir.path}');
    
    // Listar arquivos no diretório atual
    if (currentDir.existsSync()) {
      final files = currentDir.listSync();
      print('   - Arquivos no diretório atual:');
      for (var file in files) {
        if (file is File) {
          final size = file.lengthSync();
          print('     📄 ${path.basename(file.path)} (${size} bytes)');
        }
      }
    }
    
  } catch (e) {
    print('❌ Erro ao verificar diretórios: $e');
  }
}

  /// Define o diretório do banco baseado no ambiente (debug/release)
  static Future<Directory> _getDatabaseDirectory() async {
    if (kIsWeb) {
      throw Exception('Web não suporta filesystem');
    }

    // Verificar se estamos em modo debug
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());

    if (isDebug) {
      // DEBUG: Usar Documents para facilitar acesso
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      print('🐛 MODO DEBUG: Usando Documents directory');
      return appDocumentDir;
    } else {
      // RELEASE: Usar Application Support (mais seguro)
      final appSupportDir = await path_provider.getApplicationSupportDirectory();
      final databaseDir = Directory(path.join(appSupportDir.path, 'database'));
      
      if (!databaseDir.existsSync()) {
        databaseDir.createSync(recursive: true);
      }
      
      print('🚀 MODO RELEASE: Usando Application Support directory');
      return databaseDir;
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
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ItemNotaFiscalAdapter());
      }
      print('🔧 Adaptadores registrados');
    } catch (e) {
      print('❌ Erro ao registrar adaptadores: $e');
    }
  }

  // No HiveService
  static Future<void> resetParaDesenvolvimento() async {
    print('🧹 RESET COMPLETO PARA DESENVOLVIMENTO...');

    try {
      // Fechar todas as boxes
      await movelBox.close();
      await estoqueBox.close();
      await notaFiscalBox.close();
      await itemNotaFiscalBox.close();

      // Deletar todas as boxes do disco
      await Hive.deleteBoxFromDisk('moveis');
      await Hive.deleteBoxFromDisk('estoque');
      await Hive.deleteBoxFromDisk('notas_fiscais');
      await Hive.deleteBoxFromDisk('itens_nota_fiscal');

      // Limpar Shared Preferences
      await StorageService.clearAll();

      print('✅ Reset completo concluído!');
      print('🔄 Reinicializando Hive...');

      // Reinicializar
      _initialized = false;
      await init();
    } catch (e) {
      print('❌ Erro no reset: $e');
    }
  }

  // No método _openBoxesWithMigration, substitua por:
  static Future<void> _openBoxesWithMigration() async {
    print('🔄 Abrindo boxes com tratamento de migração...');

    // Sempre recriar as boxes para garantir compatibilidade
    await _recreateBox('moveis');
    await _recreateBox('estoque');
    await _recreateBox('notas_fiscais');
    await _recreateBox('itens_nota_fiscal');
  }

  static Future<void> _recreateBox(String boxName) async {
    try {
      // Fechar se já estiver aberta
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }

      // Deletar do disco
      await Hive.deleteBoxFromDisk(boxName);

      // Abrir nova
      switch (boxName) {
        case 'moveis':
          movelBox = await Hive.openBox<Movel>(boxName);
          break;
        case 'estoque':
          estoqueBox = await Hive.openBox<Estoque>(boxName);
          break;
        case 'notas_fiscais':
          notaFiscalBox = await Hive.openBox<NotaFiscal>(boxName);
          break;
        case 'itens_nota_fiscal':
          itemNotaFiscalBox = await Hive.openBox<ItemNotaFiscal>(boxName);
          break;
      }

      print('📦 Caixa $boxName recriada: ${_getBoxLength(boxName)} itens');
    } catch (e) {
      print('❌ Erro ao recriar caixa $boxName: $e');
      // Tentar abrir normalmente como fallback
      try {
        switch (boxName) {
          case 'moveis':
            movelBox = await Hive.openBox<Movel>(boxName);
            break;
          case 'estoque':
            estoqueBox = await Hive.openBox<Estoque>(boxName);
            break;
          case 'notas_fiscais':
            notaFiscalBox = await Hive.openBox<NotaFiscal>(boxName);
            break;
          case 'itens_nota_fiscal':
            itemNotaFiscalBox = await Hive.openBox<ItemNotaFiscal>(boxName);
            break;
        }
      } catch (e2) {
        print('❌ Erro crítico ao abrir caixa $boxName: $e2');
        rethrow;
      }
    }
  }

  static int _getBoxLength(String boxName) {
    switch (boxName) {
      case 'moveis':
        return movelBox.length;
      case 'estoque':
        return estoqueBox.length;
      case 'notas_fiscais':
        return notaFiscalBox.length;
      case 'itens_nota_fiscal':
        return itemNotaFiscalBox.length;
      default:
        return 0;
    }
  }

  static Future<void> _checkAndRestoreData() async {
    final hiveHasData = movelBox.isNotEmpty ||
        estoqueBox.isNotEmpty ||
        notaFiscalBox.isNotEmpty;
    final spHasData = StorageService.hasData();

    print('🔍 Verificação de dados:');
    print('   - Hive tem dados: $hiveHasData');
    print('   - Shared Preferences tem dados: $spHasData');
    print('   - Precisa de migração: $_needsMigration');

    if (!hiveHasData && spHasData) {
      print('🔄 Restaurando dados do Shared Preferences...');
      await _restoreFromFallback();
    } else if (!hiveHasData && !spHasData) {
      print('📝 Adicionando dados de exemplo...');
      await _adicionarDadosExemplo();
    } else if (hiveHasData && _needsMigration) {
      print('🔄 Migrando dados existentes...');
      await _migrarDadosExistentes();
    } else {
      print('✅ Dados já existem, fazendo backup...');
      await _backupToFallback();
    }
  }

  static Future<void> _migrarDadosExistentes() async {
    try {
      print('🔄 Iniciando migração de dados...');

      // Backup dos dados atuais antes da migração
      await _backupToFallback();

      // Limpar boxes problemáticas
      await movelBox.clear();
      await notaFiscalBox.clear();
      await itemNotaFiscalBox.clear();

      // Restaurar do backup
      await _restoreFromFallback();

      print('✅ Migração concluída com sucesso!');
    } catch (e) {
      print('❌ Erro na migração: $e');
      print('🔄 Criando dados de exemplo...');
      await _adicionarDadosExemplo();
    }
  }

  static Future<void> _restoreFromFallback() async {
    try {
      // Restaurar Notas Fiscais
      final notasData = StorageService.loadNotasFiscais();
      for (final notaData in notasData) {
        final nota = NotaFiscal(
          idNotaFiscal: notaData['idNotaFiscal'] as int,
          numeroNota: notaData['numeroNota'] as String? ??
              notaData['idNotaFiscal'].toString(),
          serie: notaData['serie'] as String? ?? '1',
          dataEmissao: DateTime.parse(notaData['dataEmissao'] as String),
          dataEntrada: DateTime.parse(notaData['dataEntrada'] as String? ??
              notaData['dataEmissao'] as String),
          cnpjFornecedor:
              notaData['cnpjFornecedor'] as String? ?? '00.000.000/0001-00',
          razaoSocialFornecedor: notaData['razaoSocialFornecedor'] as String? ??
              notaData['detalhesFornecedor'] as String,
          valorTotalProdutos:
              (notaData['valorTotalProdutos'] as num?)?.toDouble() ??
                  (notaData['valorTotal'] as num).toDouble(),
          valorTotalNota: (notaData['valorTotalNota'] as num?)?.toDouble() ??
              (notaData['valorTotal'] as num).toDouble(),
          tipoFrete: notaData['tipoFrete'] as String? ?? 'CIF',
          status: notaData['status'] as String? ?? 'Finalizada',
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
          precoVendaSugerido:
              (movelData['precoVendaSugerido'] as num?)?.toDouble() ??
                  (movelData['precoVenda'] as num).toDouble(),
        );
        await movelBox.put(movel.idMovel, movel);
      }

      // Restaurar Itens Nota Fiscal
      final itensData = StorageService.loadItensNotaFiscal();
      for (final itemData in itensData) {
        final item = ItemNotaFiscal(
          idItem: itemData['idItem'] as int,
          idNotaFiscal: itemData['idNotaFiscal'] as int,
          idMovel: itemData['idMovel'] as int,
          quantidade: itemData['quantidade'] as int,
          precoUnitario: (itemData['precoUnitario'] as num).toDouble(),
          valorTotalItem: (itemData['valorTotalItem'] as num).toDouble(),
        );
        await itemNotaFiscalBox.put(item.idItem, item);
      }

      // Restaurar Estoques
      final estoquesData = StorageService.loadEstoques();
      for (final estoqueData in estoquesData) {
        final estoque = Estoque(
          idEstoque: estoqueData['idEstoque'] as int,
          idMovel: estoqueData['idMovel'] as int,
          localizacaoFisica: estoqueData['localizacaoFisica'] as String,
          status: estoqueData['status'] as String,
          dataAtualizacao:
              DateTime.parse(estoqueData['dataAtualizacao'] as String),
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
      final notasData =
          notaFiscalBox.values.map((nota) => nota.toMap()).toList();
      await StorageService.saveNotasFiscais(notasData);

      // Backup de Móveis
      final moveisData = movelBox.values.map((movel) => movel.toMap()).toList();
      await StorageService.saveMoveis(moveisData);

      // Backup de Itens Nota Fiscal
      final itensData =
          itemNotaFiscalBox.values.map((item) => item.toMap()).toList();
      await StorageService.saveItensNotaFiscal(itensData);

      // Backup de Estoques
      final estoquesData =
          estoqueBox.values.map((estoque) => estoque.toMap()).toList();
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
        numeroNota: '000001',
        serie: '1',
        dataEmissao: DateTime.now(),
        dataEntrada: DateTime.now(),
        cnpjFornecedor: '12.345.678/0001-90',
        razaoSocialFornecedor: 'Madeireira Silva Ltda',
        enderecoFornecedor: 'Rua das Madeiras, 123 - Centro',
        telefoneFornecedor: '(11) 9999-9999',
        valorTotalProdutos: 3500.00,
        valorTotalNota: 3500.00,
        tipoFrete: 'CIF',
        status: 'Finalizada',
      );
      await addNotaFiscal(nota1);

      // Nota Fiscal 2
      final nota2 = NotaFiscal(
        idNotaFiscal: 2,
        numeroNota: '000002',
        serie: '1',
        dataEmissao: DateTime.now().subtract(const Duration(days: 5)),
        dataEntrada: DateTime.now().subtract(const Duration(days: 3)),
        cnpjFornecedor: '98.765.432/0001-10',
        razaoSocialFornecedor: 'Marcenaria Premium S.A',
        enderecoFornecedor: 'Av. dos Móveis, 456 - Industrial',
        telefoneFornecedor: '(11) 8888-8888',
        valorTotalProdutos: 5200.00,
        valorTotalNota: 5200.00,
        tipoFrete: 'FOB',
        status: 'Finalizada',
      );
      await addNotaFiscal(nota2);

      // Móveis
      final movel1 = Movel(
        idMovel: 1,
        tipoMovel: 'Sofá',
        nome: 'Sofá Retrátil 3 Lugares Couro',
        dimensoes: '200x90x80 cm',
        precoVendaSugerido: 1899.90,
        material: 'Couro sintético',
        cor: 'Marrom',
        fabricante: 'MoveisConfort',
      );
      await addMovel(movel1);

      final movel2 = Movel(
        idMovel: 2,
        tipoMovel: 'Mesa',
        nome: 'Mesa de Jantar 6 Lugares Madeira Maciça',
        dimensoes: '180x90x75 cm',
        precoVendaSugerido: 1200.00,
        material: 'Madeira maciça',
        cor: 'Natural',
        fabricante: 'MadeiraNobre',
      );
      await addMovel(movel2);

      final movel3 = Movel(
        idMovel: 3,
        tipoMovel: 'Cama',
        nome: 'Cama Box Queen Size Casal',
        dimensoes: '198x138x100 cm',
        precoVendaSugerido: 850.00,
        material: 'Madeira MDF',
        cor: 'Branco',
        fabricante: 'DormirBem',
      );
      await addMovel(movel3);

      // Itens Nota Fiscal
      final item1 = ItemNotaFiscal(
        idItem: 1,
        idNotaFiscal: 1,
        idMovel: 1,
        quantidade: 2,
        precoUnitario: 1200.00,
        valorTotalItem: 2400.00,
      );
      await addItemNotaFiscal(item1);

      final item2 = ItemNotaFiscal(
        idItem: 2,
        idNotaFiscal: 1,
        idMovel: 3,
        quantidade: 1,
        precoUnitario: 1100.00,
        valorTotalItem: 1100.00,
      );
      await addItemNotaFiscal(item2);

      final item3 = ItemNotaFiscal(
        idItem: 3,
        idNotaFiscal: 2,
        idMovel: 2,
        quantidade: 3,
        precoUnitario: 1500.00,
        valorTotalItem: 4500.00,
      );
      await addItemNotaFiscal(item3);

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

  // CRUD para Item Nota Fiscal
  static Future<void> addItemNotaFiscal(ItemNotaFiscal item) async {
    await itemNotaFiscalBox.put(item.idItem, item);
    await _backupToFallback();
    print('✅ Item ${item.idItem} adicionado à nota ${item.idNotaFiscal}');
  }

  static ItemNotaFiscal? getItemNotaFiscal(int id) {
    return itemNotaFiscalBox.get(id);
  }

  static List<ItemNotaFiscal> getAllItensNotaFiscal() {
    return itemNotaFiscalBox.values.toList();
  }

  static Future<void> updateItemNotaFiscal(ItemNotaFiscal item) async {
    await itemNotaFiscalBox.put(item.idItem, item);
    await _backupToFallback();
    print('✅ Item ${item.idItem} atualizado');
  }

  static Future<void> deleteItemNotaFiscal(int id) async {
    await itemNotaFiscalBox.delete(id);
    await _backupToFallback();
    print('✅ Item $id excluído');
  }

  // NOVOS MÉTODOS PARA RELACIONAMENTOS
  static List<ItemNotaFiscal> getItensPorNotaFiscal(int idNotaFiscal) {
    return itemNotaFiscalBox.values
        .where((item) => item.idNotaFiscal == idNotaFiscal)
        .toList();
  }

  static List<Movel> getMoveisPorNotaFiscal(int idNotaFiscal) {
    final itens = getItensPorNotaFiscal(idNotaFiscal);
    final moveisIds = itens.map((item) => item.idMovel).toSet();

    return movelBox.values
        .where((movel) => moveisIds.contains(movel.idMovel))
        .toList();
  }

  static List<NotaFiscal> getNotasFiscaisPorMovel(int idMovel) {
    final itens = itemNotaFiscalBox.values
        .where((item) => item.idMovel == idMovel)
        .toList();
    final notasIds = itens.map((item) => item.idNotaFiscal).toSet();

    return notaFiscalBox.values
        .where((nota) => notasIds.contains(nota.idNotaFiscal))
        .toList();
  }

  static double calcularValorTotalNota(int idNotaFiscal) {
    final itens = getItensPorNotaFiscal(idNotaFiscal);
    return itens.fold(0.0, (sum, item) => sum + item.valorTotalItem);
  }

  static int getQuantidadeTotalMovel(int idMovel) {
    final itens = itemNotaFiscalBox.values
        .where((item) => item.idMovel == idMovel)
        .toList();
    return itens.fold(0, (sum, item) => sum + item.quantidade);
  }

  // Métodos auxiliares
  static List<Estoque> getEstoquePorMovel(int idMovel) {
    return estoqueBox.values
        .where((estoque) => estoque.idMovel == idMovel)
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
    final itensVinculados = getItensPorNotaFiscal(id);

    if (itensVinculados.isNotEmpty) {
      throw Exception(
          'Não é possível excluir a nota fiscal pois existem ${itensVinculados.length} item(ns) vinculado(s) a ela.');
    }

    await notaFiscalBox.delete(id);
    await _backupToFallback();
  }

  static Future<void> deleteMovelSafe(int id) async {
    final estoquesVinculados = getEstoquePorMovel(id);
    final itensVinculados =
        itemNotaFiscalBox.values.where((item) => item.idMovel == id).toList();

    if (estoquesVinculados.isNotEmpty || itensVinculados.isNotEmpty) {
      throw Exception(
          'Não é possível excluir o móvel pois existem vinculações com estoque ou notas fiscais.');
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

    final itensVinculados =
        itemNotaFiscalBox.values.where((item) => item.idMovel == id).toList();
    for (final item in itensVinculados) {
      await itemNotaFiscalBox.delete(item.idItem);
    }

    await movelBox.delete(id);
    await _backupToFallback();
    print('✅ Móvel $id, estoques e itens de nota fiscal excluídos em cascata');
  }

  static Future<void> deleteNotaFiscalCascade(int id) async {
    final itensVinculados = getItensPorNotaFiscal(id);
    for (final item in itensVinculados) {
      await itemNotaFiscalBox.delete(item.idItem);
    }

    await notaFiscalBox.delete(id);
    await _backupToFallback();
    print('✅ Nota Fiscal $id e itens excluídos em cascata');
  }

  // Status
  static void printStatus() {
    print('=== STATUS GERAL ===');
    print('HIVE - Móveis: ${movelBox.length}');
    print('HIVE - Estoques: ${estoqueBox.length}');
    print('HIVE - Notas Fiscais: ${notaFiscalBox.length}');
    print('HIVE - Itens Nota Fiscal: ${itemNotaFiscalBox.length}');
    StorageService.printStatus();
    print('Usando Fallback: $_usingFallback');
    print('==================');
  }

  // Debug
  static void debugData() {
    print('\n🔍 DEBUG DOS DADOS:');
    print('MÓVEIS:');
    movelBox.values.forEach((movel) {
      print(' - ${movel.idMovel}: ${movel.nome}');
    });
    print('ESTOQUES:');
    estoqueBox.values.forEach((estoque) {
      print(
          ' - ${estoque.idEstoque}: Móvel ${estoque.idMovel} - ${estoque.localizacaoFisica}');
    });
    print('NOTAS FISCAIS:');
    notaFiscalBox.values.forEach((nota) {
      print(
          ' - ${nota.idNotaFiscal}: ${nota.razaoSocialFornecedor} - R\$ ${nota.valorTotalNota}');
    });
    print('ITENS NOTA FISCAL:');
    itemNotaFiscalBox.values.forEach((item) {
      print(
          ' - Item ${item.idItem}: Nota ${item.idNotaFiscal}, Móvel ${item.idMovel}, Qtd: ${item.quantidade}');
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
    final itens = StorageService.loadItensNotaFiscal();

    print('MÓVEIS NO SP (${moveis.length}):');
    for (final movel in moveis) {
      print(' - ${movel['idMovel']}: ${movel['nome']}');
    }

    print('ESTOQUES NO SP (${estoques.length}):');
    for (final estoque in estoques) {
      print(
          ' - ${estoque['idEstoque']}: Móvel ${estoque['idMovel']} - ${estoque['localizacaoFisica']}');
    }

    print('NOTAS NO SP (${notas.length}):');
    for (final nota in notas) {
      print(' - ${nota['idNotaFiscal']}: ${nota['razaoSocialFornecedor']}');
    }

    print('ITENS NOTA FISCAL NO SP (${itens.length}):');
    for (final item in itens) {
      print(
          ' - Item ${item['idItem']}: Nota ${item['idNotaFiscal']}, Móvel ${item['idMovel']}, Qtd: ${item['quantidade']}');
    }
  }

  static void debugRestorationInfo() {
    print('\n🔍 INFO RESTAURAÇÃO:');
    final hiveHasData = movelBox.isNotEmpty ||
        estoqueBox.isNotEmpty ||
        notaFiscalBox.isNotEmpty;
    final spHasData = StorageService.hasData();

    print('- Hive tem dados: $hiveHasData');
    print('- Shared Preferences tem dados: $spHasData');
    print('- Móveis no Hive: ${movelBox.length}');
    print('- Estoques no Hive: ${estoqueBox.length}');
    print('- Notas no Hive: ${notaFiscalBox.length}');
    print('- Itens Nota Fiscal no Hive: ${itemNotaFiscalBox.length}');

    final moveisSP = StorageService.loadMoveis();
    final estoquesSP = StorageService.loadEstoques();
    final notasSP = StorageService.loadNotasFiscais();
    final itensSP = StorageService.loadItensNotaFiscal();

    print('- Móveis no SP: ${moveisSP.length}');
    print('- Estoques no SP: ${estoquesSP.length}');
    print('- Notas no SP: ${notasSP.length}');
    print('- Itens Nota Fiscal no SP: ${itensSP.length}');
    print('- Usando Fallback: $_usingFallback');
  }

  static Future<void> clearAllData() async {
    await movelBox.clear();
    await estoqueBox.clear();
    await notaFiscalBox.clear();
    await itemNotaFiscalBox.clear();
    await StorageService.clearAll();
    print('🗑️ TODOS os dados foram limpos (Hive + Shared Preferences)');
  }
}
