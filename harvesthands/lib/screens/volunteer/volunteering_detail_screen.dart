import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../models/volunteering.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/enrollment_repository.dart';
import '../../repositories/volunteering_repository.dart';
import '../../widgets/image_placeholder.dart';

class VolunteeringDetailScreen extends StatefulWidget {
  final int volunteeringId;

  const VolunteeringDetailScreen({super.key, required this.volunteeringId});

  @override
  State<VolunteeringDetailScreen> createState() => _VolunteeringDetailScreenState();
}

class _VolunteeringDetailScreenState extends State<VolunteeringDetailScreen> {
  final _volRepo = VolunteeringRepository();
  final _enrollRepo = EnrollmentRepository();

  Volunteering? _volunteering;
  bool _isEnrolled = false;
  bool _loading = true;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      final v = await _volRepo.getById(widget.volunteeringId);
      final enrolled = v != null && user != null
          ? await _enrollRepo.isEnrolled(
              volunteeringId: widget.volunteeringId,
              volunteerId: user.id!,
            )
          : false;
      if (mounted) {
        setState(() {
          _volunteering = v;
          _isEnrolled = enrolled;
        });
      }
    } finally {
      if (mounted && showSpinner) setState(() => _loading = false);
    }
  }

  Future<void> _enroll() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _enrolling = true);
    try {
      await _enrollRepo.enroll(
        volunteeringId: widget.volunteeringId,
        volunteerId: user.id!,
      );
      if (!mounted) return;
      setState(() => _isEnrolled = true);
      // showSpinner=false para no flashear la pantalla completa durante el refresco
      await _load(showSpinner: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Symbols.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Te inscribiste correctamente'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Symbols.error, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString().replaceFirst('Exception: ', ''))),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_volunteering == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Voluntariado no encontrado')),
      );
    }

    final v = _volunteering!;
    final colorScheme = Theme.of(context).colorScheme;
    final spotsLeft = v.maxCapacity - v.enrolledCount;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Symbols.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(v),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (v.companyName != null)
                    Row(
                      children: [
                        Icon(Symbols.business, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          v.companyName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _InfoChip(
                    icon: Symbols.event,
                    label: _formatDate(v.eventDate),
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Symbols.group,
                    label: '$spotsLeft lugar${spotsLeft == 1 ? '' : 'es'} disponible${spotsLeft == 1 ? '' : 's'} de ${v.maxCapacity}',
                    color: spotsLeft <= 3 ? colorScheme.error : colorScheme.primary,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionButton(context, v, spotsLeft),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Volunteering v) {
    if (v.imagePath == null) return const ImagePlaceholder(height: 220);
    if (kIsWeb) {
      return Image.network(
        v.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ImagePlaceholder(height: 220),
      );
    }
    return Image.file(
      File(v.imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ImagePlaceholder(height: 220),
    );
  }

  Widget _buildActionButton(BuildContext context, Volunteering v, int spotsLeft) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isEnrolled) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Symbols.check_circle),
          label: const Text('Ya estás inscrito'),
        ),
      );
    }

    if (spotsLeft <= 0) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Symbols.group_off, color: colorScheme.error),
          label: Text('Cupo lleno', style: TextStyle(color: colorScheme.error)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _enrolling ? null : _enroll,
        icon: _enrolling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Symbols.volunteer_activism),
        label: const Text('Inscribirme'),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    const dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    return '${dias[dt.weekday - 1]}, ${dt.day} de ${meses[dt.month - 1]} de ${dt.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
