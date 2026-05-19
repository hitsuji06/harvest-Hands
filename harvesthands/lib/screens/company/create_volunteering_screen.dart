import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/volunteering_repository.dart';
import '../../utils/validators.dart';

class CreateVolunteeringScreen extends StatefulWidget {
  const CreateVolunteeringScreen({super.key});

  @override
  State<CreateVolunteeringScreen> createState() => _CreateVolunteeringScreenState();
}

class _CreateVolunteeringScreenState extends State<CreateVolunteeringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = VolunteeringRepository();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  DateTime? _eventDate;
  XFile? _pickedImage;
  bool _loading = false;
  int _descChars = 0;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl.addListener(() {
      setState(() => _descChars = _descriptionCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() => _pickedImage = file);
  }

  Future<String?> _saveImage(XFile file) async {
    if (kIsWeb) {
      return file.path;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'vol_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final destPath = p.join(appDir.path, fileName);
    await File(file.path).copy(destPath);
    return destPath;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  bool get _formValid =>
      _titleCtrl.text.isNotEmpty &&
      _descriptionCtrl.text.isNotEmpty &&
      _capacityCtrl.text.isNotEmpty &&
      _eventDate != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (Validators.futureDate(_eventDate) != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Symbols.error, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('La fecha debe ser posterior a hoy'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final imagePath = _pickedImage != null ? await _saveImage(_pickedImage!) : null;

      if (!mounted) return;
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      await _repo.create(
        companyId: user.id!,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        imagePath: imagePath,
        eventDate: _eventDate!,
        maxCapacity: int.parse(_capacityCtrl.text.trim()),
      );

      if (!mounted) return;
      // Volver primero y luego mostrar el SnackBar desde el scaffold padre (dashboard).
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Symbols.error, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Error al publicar'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImagePickerWidget(
                  pickedImage: _pickedImage,
                  onPick: _pickImage,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Symbols.title, color: colorScheme.onSurfaceVariant),
                    counterText: '',
                  ),
                  maxLength: 80,
                  validator: Validators.volunteeringTitle,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionCtrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Symbols.description, color: colorScheme.onSurfaceVariant),
                    alignLabelWithHint: true,
                    counterText: '$_descChars/500',
                    counterStyle: TextStyle(
                      color: _descChars > 500
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  validator: Validators.volunteeringDescription,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Cupo máximo',
                    prefixIcon: Icon(Symbols.group, color: colorScheme.onSurfaceVariant),
                    hintText: '1 – 999',
                  ),
                  validator: Validators.capacity,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _DatePickerField(
                  selectedDate: _eventDate,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _formValid && !_loading ? _submit : null,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Symbols.publish),
                    label: const Text('Publicar voluntariado'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  final XFile? pickedImage;
  final VoidCallback onPick;

  const _ImagePickerWidget({required this.pickedImage, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: pickedImage != null
            ? _buildPreview(pickedImage!)
            : _buildEmpty(context),
      ),
    );
  }

  Widget _buildPreview(XFile file) {
    final imageWidget = kIsWeb
        ? Image.network(file.path, fit: BoxFit.cover)
        : Image.file(File(file.path), fit: BoxFit.cover);

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        const Positioned(
          bottom: 8,
          right: 8,
          child: _EditChip(),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Symbols.add_a_photo, size: 40, color: colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          'Agregar imagen (opcional)',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EditChip extends StatelessWidget {
  const _EditChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.edit, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text('Cambiar', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = selectedDate != null ? _formatDate(selectedDate!) : null;
    final hasError = selectedDate != null && Validators.futureDate(selectedDate) != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha del evento',
          prefixIcon: Icon(
            Symbols.event,
            color: hasError ? colorScheme.error : null,
          ),
          errorText: hasError ? 'La fecha debe ser posterior a hoy' : null,
        ),
        child: Text(
          dateStr ?? 'Seleccionar fecha',
          style: TextStyle(
            color: dateStr != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${dt.day} de ${meses[dt.month - 1]} de ${dt.year}';
  }
}
