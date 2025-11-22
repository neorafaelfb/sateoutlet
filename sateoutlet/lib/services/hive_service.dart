import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/movel.dart';
import '../models/estoque.dart';
import '../models/nota_fiscal.dart';

class HiveService {
  static late Box<Movel> movelBox;
  static late Box<Estoque> estoqueBox;
  static late Box<NotaFiscal> notaFiscalBox;

  static Future<void> init() async {
    // Configuração diferente para Web e Mobile
    if (!kIsWeb) {
      // Para Mobile/Desktop
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    } else {
      // Para Web - não precisa de path
      Hive.init(null);
    }
    
    // Registrar adaptadores
    Hive.registerAdapter(MovelAdapter());
    Hive.registerAdapter(EstoqueAdapter());
    Hive.registerAdapter(NotaFiscalAdapter());
    
    try {
      // Abrir caixas
      movelBox = await Hive.openBox<Movel>('moveis');
      estoqueBox = await Hive.openBox<Estoque>('estoque');
      notaFiscalBox = await Hive.openBox<NotaFiscal>('notas_fiscais');
      
      // Adicionar alguns dados de exemplo para teste
      await _adicionarDadosExemplo();
    } catch (e) {
      print('Erro ao inicializar Hive: $e');
      // Tentar abrir sem dados de exemplo em caso de erro
      movelBox = await Hive.openBox<Movel>('moveis');
      estoqueBox = await Hive.openBox<Estoque>('estoque');
      notaFiscalBox = await Hive.openBox<NotaFiscal>('notas_fiscais');
    }
  }

  // Método para adicionar dados de exemplo
  static Future<void> _adicionarDadosExemplo() async {
    // Verificar se já existem dados
    if (movelBox.isEmpty) {
      // Criar nota fiscal exemplo
      final notaExemplo = NotaFiscal(
        idNotaFiscal: 1,
        dataEmissao: DateTime.now(),
        detalhesFornecedor: 'Fornecedor Exemplo Ltda',
        valorTotal: 2500.00,
      );
      await addNotaFiscal(notaExemplo);

      // Criar móveis exemplo
      final movel1 = Movel(
        idMovel: 1,
        tipoMovel: 'Sofá',
        nome: 'Sofá Retrátil 3 Lugares',
        dimensoes: '200x90x80 cm',
        precoVenda: 1200.00,
        idNotaFiscal: 1,
      );

      final movel2 = Movel(
        idMovel: 2,
        tipoMovel: 'Mesa',
        nome: 'Mesa de Jantar 6 Lugares',
        dimensoes: '180x90x75 cm',
        precoVenda: 800.00,
        idNotaFiscal: 1,
      );

      await addMovel(movel1);
      await addMovel(movel2);

      // Criar estoque exemplo
      final estoque1 = Estoque(
        idEstoque: 1,
        idMovel: 1,
        localizacaoFisica: 'Prateleira A-15',
        status: 'Disponível',
        dataAtualizacao: DateTime.now(),
      );

      final estoque2 = Estoque(
        idEstoque: 2,
        idMovel: 2,
        localizacaoFisica: 'Setor B-20',
        status: 'Disponível',
        dataAtualizacao: DateTime.now(),
      );

      await addEstoque(estoque1);
      await addEstoque(estoque2);
    }
  }

  // CRUD para Móveis
  static Future<void> addMovel(Movel movel) async {
    await movelBox.put(movel.idMovel, movel);
  }

  static Movel? getMovel(int id) {
    return movelBox.get(id);
  }

  static List<Movel> getAllMoveis() {
    return movelBox.values.toList();
  }

  static Future<void> updateMovel(Movel movel) async {
    await movelBox.put(movel.idMovel, movel);
  }

  static Future<void> deleteMovel(int id) async {
    await movelBox.delete(id);
  }

  // CRUD para Estoque
  static Future<void> addEstoque(Estoque estoque) async {
    await estoqueBox.put(estoque.idEstoque, estoque);
  }

  static Estoque? getEstoque(int id) {
    return estoqueBox.get(id);
  }

  static List<Estoque> getAllEstoque() {
    return estoqueBox.values.toList();
  }

  static Future<void> updateEstoque(Estoque estoque) async {
    await estoqueBox.put(estoque.idEstoque, estoque);
  }

  static Future<void> deleteEstoque(int id) async {
    await estoqueBox.delete(id);
  }

  // CRUD para Nota Fiscal
  static Future<void> addNotaFiscal(NotaFiscal nota) async {
    await notaFiscalBox.put(nota.idNotaFiscal, nota);
  }

  static NotaFiscal? getNotaFiscal(int id) {
    return notaFiscalBox.get(id);
  }

  static List<NotaFiscal> getAllNotasFiscais() {
    return notaFiscalBox.values.toList();
  }

  static Future<void> updateNotaFiscal(NotaFiscal nota) async {
    await notaFiscalBox.put(nota.idNotaFiscal, nota);
  }

  static Future<void> deleteNotaFiscal(int id) async {
    await notaFiscalBox.delete(id);
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

  static bool existeMovel(int idMovel) {
    return movelBox.containsKey(idMovel);
  }

  static bool existeNotaFiscal(int idNotaFiscal) {
    return notaFiscalBox.containsKey(idNotaFiscal);
  }

  // No HiveService, adicione este método:
static List<Movel> getMoveisDisponiveis() {
  return movelBox.values.toList();
}

static List<Movel> getMoveisParaEstoque() {
  final todosMoveis = movelBox.values.toList();
  final estoques = estoqueBox.values.toList();
  
  // Filtrar móveis que ainda não têm estoque cadastrado
  return todosMoveis.where((movel) {
    return !estoques.any((estoque) => estoque.idMovel == movel.idMovel);
  }).toList();
}
}