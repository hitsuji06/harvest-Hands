import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            _ProfileCard(user: user),
            const SizedBox(height: 16),
          ],
          const _SectionHeader(title: 'Apariencia'),
          Card(
            child: Column(
              children: [
                _ThemeOption(
                  icon: Symbols.settings_brightness,
                  label: 'Sistema',
                  value: ThemeMode.system,
                  current: themeProvider.themeMode,
                  onTap: () => themeProvider.setTheme(ThemeMode.system),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  icon: Symbols.light_mode,
                  label: 'Claro',
                  value: ThemeMode.light,
                  current: themeProvider.themeMode,
                  onTap: () => themeProvider.setTheme(ThemeMode.light),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  icon: Symbols.dark_mode,
                  label: 'Oscuro',
                  value: ThemeMode.dark,
                  current: themeProvider.themeMode,
                  onTap: () => themeProvider.setTheme(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'Cuenta'),
          Card(
            child: ListTile(
              leading: Icon(Symbols.logout, color: colorScheme.error),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () => _confirmLogout(context, auth),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'HarvestHands v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Cerrar el diálogo primero
              Navigator.of(dialogContext).pop();
              // Limpiar todo el stack de navegación antes de hacer logout,
              // para que SettingsScreen no quede encima de LoginScreen.
              Navigator.of(context).popUntil((route) => route.isFirst);
              auth.logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode value;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = value == current;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? colorScheme.primary : null,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
      trailing: selected
          ? Icon(Symbols.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(
                user.isCompany ? Symbols.business : Symbols.person,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.isCompany ? 'Empresa' : 'Voluntario',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
