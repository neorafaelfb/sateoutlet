import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ Shared Preferences inicializado');
  }

  // Salvar lista de móveis
  static Future<void> saveMoveis(List<Map<String, dynamic>> moveis) async {
    await _prefs.setString('moveis', json.encode(moveis));
    print('💾 Móveis salvos no Shared Preferences: ${moveis.length} itens');
  }

  // Carregar lista de móveis
  static List<Map<String, dynamic>> loadMoveis() {
    final data = _prefs.getString('moveis');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Salvar lista de estoques
  static Future<void> saveEstoques(List<Map<String, dynamic>> estoques) async {
    await _prefs.setString('estoques', json.encode(estoques));
    print('💾 Estoques salvos no Shared Preferences: ${estoques.length} itens');
  }

  // Carregar lista de estoques
  static List<Map<String, dynamic>> loadEstoques() {
    final data = _prefs.getString('estoques');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Salvar lista de notas fiscais
  static Future<void> saveNotasFiscais(List<Map<String, dynamic>> notas) async {
    await _prefs.setString('notas_fiscais', json.encode(notas));
    print('💾 Notas Fiscais salvas no Shared Preferences: ${notas.length} itens');
  }

  // Carregar lista de notas fiscais
  static List<Map<String, dynamic>> loadNotasFiscais() {
    final data = _prefs.getString('notas_fiscais');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Limpar todos os dados
  static Future<void> clearAll() async {
    await _prefs.remove('moveis');
    await _prefs.remove('estoques');
    await _prefs.remove('notas_fiscais');
    print('🗑️ Todos os dados do Shared Preferences foram limpos');
  }

  // Verificar se existem dados salvos
  static bool hasData() {
    return _prefs.containsKey('moveis') || 
           _prefs.containsKey('estoques') || 
           _prefs.containsKey('notas_fiscais');
  }

  // Contar dados salvos
  static void printStatus() {
    final moveis = loadMoveis();
    final estoques = loadEstoques();
    final notas = loadNotasFiscais();
    
    print('=== STATUS SHARED PREFERENCES ===');
    print('Móveis: ${moveis.length}');
    print('Estoques: ${estoques.length}');
    print('Notas Fiscais: ${notas.length}');
    print('=================================');
  }
}