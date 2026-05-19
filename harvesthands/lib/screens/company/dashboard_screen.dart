import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../models/volunteering.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/volunteering_repository.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/volunteering_card.dart';
import '../shared/settings_screen.dart';
import 'create_volunteering_screen.dart';
import 'enrollees_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  final _repo = VolunteeringRepository();
  List<Volunteering> _volunteerings = [];
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      final data = await _repo.getByCompany(user.id!);
      if (mounted) setState(() => _volunteerings = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis publicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Capturar antes del await para evitar uso de context tras gap async
          final messenger = ScaffoldMessenger.of(context);
          final primaryColor = Theme.of(context).colorScheme.primary;

          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateVolunteeringScreen()),
          );
          if (!mounted) return;
          if (created == true) {
            messenger.showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Symbols.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Voluntariado publicado'),
                  ],
                ),
                backgroundColor: primaryColor,
              ),
            );
          }
          _load();
        },
        icon: const Icon(Symbols.add),
        label: const Text('Nueva publicación'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.dashboard),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Symbols.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_volunteerings.isEmpty) {
      return EmptyState(
        icon: Symbols.add_circle,
        message: 'Sin publicaciones aún',
        subtitle: 'Crea tu primer voluntariado con el botón inferior.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: _volunteerings.length,
        itemBuilder: (context, i) {
          final v = _volunteerings[i];
          return VolunteeringCard(
            volunteering: v,
            showStatus: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnrolleesScreen(volunteering: v),
                ),
              ).then((_) => _load());
            },
          );
        },
      ),
    );
  }
}
