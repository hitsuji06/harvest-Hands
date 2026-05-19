import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/enrollment.dart';
import '../../models/volunteering.dart';
import '../../repositories/enrollment_repository.dart';
import '../../widgets/empty_state.dart';

class EnrolleesScreen extends StatefulWidget {
  final Volunteering volunteering;

  const EnrolleesScreen({super.key, required this.volunteering});

  @override
  State<EnrolleesScreen> createState() => _EnrolleesScreenState();
}

class _EnrolleesScreenState extends State<EnrolleesScreen> {
  final _repo = EnrollmentRepository();
  List<Enrollment> _enrollees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getByVolunteering(widget.volunteering.id!);
      if (mounted) setState(() => _enrollees = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.volunteering;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscritos'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(volunteering: v, count: _enrollees.length),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_enrollees.isEmpty) {
      return const EmptyState(
        icon: Symbols.group,
        message: 'Sin inscritos aún',
        subtitle: 'Cuando alguien se inscriba aparecerá aquí.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _enrollees.length,
        itemBuilder: (context, i) {
          return _EnrolleeTile(
            enrollment: _enrollees[i],
            index: i + 1,
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Volunteering volunteering;
  final int count;

  const _Header({required this.volunteering, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isClosed = volunteering.isFull || volunteering.isPast;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            volunteering.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Symbols.group, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '$count / ${volunteering.maxCapacity} inscritos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 12),
              if (isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    volunteering.isFull ? 'Cupo lleno' : 'Concluido',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _CapacityBar(
            current: count,
            max: volunteering.maxCapacity,
          ),
        ],
      ),
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final int current;
  final int max;

  const _CapacityBar({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final colorScheme = Theme.of(context).colorScheme;
    final barColor = fraction >= 1.0
        ? colorScheme.error
        : fraction >= 0.8
            ? colorScheme.secondary
            : colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        backgroundColor: colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
        minHeight: 6,
      ),
    );
  }
}

class _EnrolleeTile extends StatelessWidget {
  final Enrollment enrollment;
  final int index;

  const _EnrolleeTile({required this.enrollment, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            '$index',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          enrollment.volunteerName ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(enrollment.volunteerEmail ?? ''),
        trailing: IconButton(
          icon: Icon(Symbols.phone, color: colorScheme.primary),
          tooltip: 'Ver contacto',
          onPressed: () => _showContact(context),
        ),
        onTap: () => _showContact(context),
      ),
    );
  }

  void _showContact(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Symbols.person, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                enrollment.volunteerName ?? 'Voluntario',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContactRow(
              icon: Symbols.mail,
              label: 'Correo',
              value: enrollment.volunteerEmail ?? '-',
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Symbols.phone,
              label: 'Teléfono',
              value: enrollment.volunteerPhone ?? '-',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
