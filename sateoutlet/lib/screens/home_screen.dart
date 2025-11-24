import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import 'movel_screen.dart';
import 'estoque_screen.dart';
import 'nota_fiscal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Estoque - Móveis'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          final crossAxisCount = isSmallScreen ? 2 : 3;
          final childAspectRatio = isSmallScreen ? 1.0 : 0.8;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
              children: [
                _buildMenuCard(
                  context,
                  'Móveis',
                  Icons.chair,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MovelScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Estoque',
                  Icons.inventory,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EstoqueScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Notas Fiscais',
                  Icons.receipt,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotaFiscalScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Relatórios',
                  Icons.analytics,
                  Colors.purple,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                ),
                // Debug Menu
                _buildMenuCard(
                  context,
                  'Debug SP',
                  Icons.storage,
                  Colors.purple,
                  () {
                    HiveService.debugSharedPreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared Preferences impresso no console')),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Forçar Restauração',
                  Icons.restore,
                  Colors.red,
                  () async {
                    await HiveService.forceRestoreFromBackup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restauração forçada executada')),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Info Restauração',
                  Icons.info,
                  Colors.amber,
                  () {
                    HiveService.debugRestorationInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Info restauração no console')),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Limpar Tudo',
                  Icons.delete_forever,
                  Colors.red[900]!,
                  () async {
                    await HiveService.clearAllData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todos os dados foram limpos')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}