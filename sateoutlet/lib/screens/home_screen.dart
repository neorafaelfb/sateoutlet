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
                  'Cadastro de produtos',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MovelScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Estoque',
                  Icons.inventory,
                  Colors.green,
                  'Controle de estoque',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EstoqueScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Notas Fiscais',
                  Icons.receipt,
                  Colors.orange,
                  'Entrada de mercadorias',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotaFiscalScreen()),
                  ),
                ),
                /*
                _buildMenuCard(
                  context,
                  'Relatórios',
                  Icons.analytics,
                  Colors.purple,
                  'Em desenvolvimento',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                ),*/
                // Debug Menu
                /*
                _buildMenuCard(
                  context,
                  'Status Sistema',
                  Icons.storage,
                  Colors.purple,
                  'Ver status do banco',
                  () {
                    HiveService.printStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Status impresso no console')),
                    );
                  },
                ),*/
                /*
                _buildMenuCard(
                  context,
                  'Forçar Restauração',
                  Icons.restore,
                  Colors.red,
                  'Restaurar do backup',
                  () async {
                    await HiveService.forceRestoreFromBackup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Restauração forçada executada')),
                    );
                  },
                ),*/
                // No home_screen.dart, adicione este card:
                /*
                _buildMenuCard(
                  context,
                  'Reset Desenvolvimento',
                  Icons.refresh,
                  Colors.red,
                  'Limpar todos os dados',
                  () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Completo'),
                        content: const Text(
                            'Tem certeza que deseja limpar TODOS os dados? Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await HiveService.resetParaDesenvolvimento();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Reset completo realizado')),
                              );
                            },
                            child: const Text('Resetar Tudo'),
                          ),
                        ],
                      ),
                    );
                  },
                ),*/
                /*
                _buildMenuCard(
  context,
  'Info Diretórios',
  Icons.folder,
  Colors.brown,
  'Ver locais do banco',
  () {
    HiveService.mostrarInfoDiretorios();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Info diretórios no console')),
    );
  },
),
*/
/*
_buildMenuCard(
  context,
  'Migrar Release',
  Icons.upgrade,
  Colors.purple,
  'Preparar para release',
  () async {
    await HiveService.migrarParaRelease();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Migração para release iniciada')),
    );
  },
),
*/
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
    String subtitle,
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
