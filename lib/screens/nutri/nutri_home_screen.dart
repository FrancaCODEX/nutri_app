import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/cloud_repository.dart';
import '../../data/sample_recipes.dart';
import '../../models/patient_profile.dart';
import '../../models/recipe.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_image.dart';
import '../auth/change_password_screen.dart';
import 'new_patient_screen.dart';
import 'patient_detail_screen.dart';
import 'recipe_editor_screen.dart';

/// Início da nutricionista: pacientes, receitas e conta.
class NutriHomeScreen extends StatefulWidget {
  const NutriHomeScreen({super.key, required this.auth, required this.repo});

  final AuthService auth;
  final CloudRepository repo;

  @override
  State<NutriHomeScreen> createState() => _NutriHomeScreenState();
}

class _NutriHomeScreenState extends State<NutriHomeScreen> {
  int _index = 0;
  late final Stream<List<PatientProfile>> _patients = widget.repo.patients();
  late final Stream<List<Recipe>> _recipes = widget.repo.recipes();

  @override
  Widget build(BuildContext context) {
    final pages = [
      _PatientsTab(repo: widget.repo, patients: _patients, recipes: _recipes),
      _RecipesTab(repo: widget.repo, recipes: _recipes),
      _AccountTab(auth: widget.auth),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: StreamBuilder<List<PatientProfile>>(
        stream: _patients,
        builder: (context, snap) {
          final unread = (snap.data ?? const []).where((p) => p.hasUnread).length;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.people_outline),
                ),
                selectedIcon: const Icon(Icons.people),
                label: 'Pacientes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Receitas',
              ),
              const NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle),
                label: 'Conta',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PatientsTab extends StatefulWidget {
  const _PatientsTab({required this.repo, required this.patients, required this.recipes});

  final CloudRepository repo;
  final Stream<List<PatientProfile>> patients;
  final Stream<List<Recipe>> recipes;

  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  String _query = '';

  String _lastSeen(PatientProfile p) {
    final seen = p.lastSeenAt;
    if (seen == null) return 'Ainda não entrou no app';
    final days = DateTime.now().difference(seen).inDays;
    if (days == 0) return 'Ativo hoje';
    if (days == 1) return 'Ativo ontem';
    return 'Último acesso em ${DateFormat('dd/MM').format(seen)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: StreamBuilder<List<PatientProfile>>(
        stream: widget.patients,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Erro ao carregar. Verifique a internet.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final q = _query.toLowerCase();
          final list = snap.data!.where((p) => p.name.toLowerCase().contains(q)).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar paciente'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: snap.data!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Nenhum paciente ainda.\nToque em "Novo paciente" para criar o acesso.',
                              textAlign: TextAlign.center),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final p = list[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(p.name.isEmpty ? '?' : p.name[0].toUpperCase())),
                            title: Text(p.name, style: p.hasUnread ? const TextStyle(fontWeight: FontWeight.bold) : null),
                            subtitle: Text(p.hasUnread ? 'Nova mensagem' : _lastSeen(p)),
                            trailing: p.hasUnread
                                ? Icon(Icons.mark_chat_unread, color: Theme.of(context).colorScheme.primary)
                                : const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => PatientDetailScreen(
                                repo: widget.repo,
                                uid: p.uid,
                                recipes: widget.recipes,
                                openChat: p.hasUnread,
                              ),
                            )),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Novo paciente'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewPatientScreen(repo: widget.repo)),
        ),
      ),
    );
  }
}

class _RecipesTab extends StatelessWidget {
  const _RecipesTab({required this.repo, required this.recipes});

  final CloudRepository repo;
  final Stream<List<Recipe>> recipes;

  String _newId() => 'r_${DateTime.now().microsecondsSinceEpoch}';

  void _open(BuildContext context, [Recipe? recipe]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RecipeEditorScreen(
        initial: recipe,
        newId: _newId,
        onSave: repo.saveRecipe,
        onDelete: recipe == null ? null : () => repo.deleteRecipe(recipe.id),
      ),
    ));
  }

  Future<void> _importSamples(BuildContext context) async {
    for (final r in sampleRecipes) {
      await repo.saveRecipe(r);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${sampleRecipes.length} receitas de exemplo adicionadas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: StreamBuilder<List<Recipe>>(
        stream: recipes,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Erro ao carregar. Verifique a internet.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Nenhuma receita publicada.\nAs receitas aparecem para todos os pacientes.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _importSamples(context),
                      child: const Text('Adicionar receitas de exemplo'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              return ListTile(
                leading: r.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppImage(r.imageUrl!, width: 48, height: 48),
                      )
                    : CircleAvatar(child: Text(r.category.label[0])),
                title: Text(r.title),
                subtitle: Text('${r.category.label} · ${r.kcalPerServing.round()} kcal/porção'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _open(context, r),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
        onPressed: () => _open(context),
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Nutricionista'),
            subtitle: Text(auth.currentUser?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Alterar senha'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChangePasswordScreen(auth: auth)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: auth.signOut,
          ),
        ],
      ),
    );
  }
}
