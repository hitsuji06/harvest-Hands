import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/volunteering.dart';
import '../../repositories/volunteering_repository.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/volunteering_card.dart';
import '../shared/settings_screen.dart';
import 'my_enrollments_screen.dart';
import 'volunteering_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _repo = VolunteeringRepository();
  List<Volunteering> _volunteerings = [];
  bool _loading = true;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getFeed();
      if (mounted) setState(() => _volunteerings = data);
    } catch (_) {
      if (mounted) setState(() => _error = 'Error al cargar los voluntariados');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voluntariados'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: _load,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyEnrollmentsScreen()),
            ).then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
          } else if (i == 2) {
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
            icon: Icon(Symbols.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Symbols.bookmark),
            label: 'Mis inscripciones',
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

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.error, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Symbols.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_volunteerings.isEmpty) {
      return const EmptyState(
        icon: Symbols.volunteer_activism,
        message: 'No hay voluntariados disponibles',
        subtitle: 'Vuelve pronto, se publicarán nuevas oportunidades.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _volunteerings.length,
        itemBuilder: (context, i) {
          final v = _volunteerings[i];
          return VolunteeringCard(
            volunteering: v,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VolunteeringDetailScreen(volunteeringId: v.id!),
                ),
              ).then((_) => _load());
            },
          );
        },
      ),
    );
  }
}
