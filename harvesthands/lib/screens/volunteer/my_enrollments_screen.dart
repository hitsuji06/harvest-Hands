import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../models/enrollment.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/enrollment_repository.dart';
import '../../widgets/empty_state.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  final _repo = EnrollmentRepository();
  List<Enrollment> _enrollments = [];
  bool _loading = true;

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
      final data = await _repo.getByVolunteer(user.id!);
      if (mounted) setState(() => _enrollments = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis inscripciones'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_enrollments.isEmpty) {
      return const EmptyState(
        icon: Symbols.bookmark,
        message: 'Sin inscripciones aún',
        subtitle: 'Explora el feed y únete a un voluntariado.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _enrollments.length,
        itemBuilder: (context, i) {
          final e = _enrollments[i];
          return _EnrollmentTile(enrollment: e);
        },
      ),
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final Enrollment enrollment;

  const _EnrollmentTile({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dt = DateTime.tryParse(enrollment.enrolledAt);
    final dateStr = dt != null ? _formatDate(dt) : '';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(Symbols.volunteer_activism, color: colorScheme.primary),
        ),
        title: Text(
          enrollment.volunteeringTitle ?? 'Voluntariado',
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Inscrito el $dateStr',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Symbols.check_circle,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${meses[dt.month - 1]} ${dt.year}';
  }
}
