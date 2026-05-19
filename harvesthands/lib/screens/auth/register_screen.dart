import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isCompany = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      role: _isCompany ? 'company' : 'volunteer',
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      password: _passwordCtrl.text,
      description: _isCompany ? _descriptionCtrl.text : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // El ScaffoldMessenger de MaterialApp persiste al hacer pop,
      // así el SnackBar se muestra en la pantalla de inicio.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Symbols.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Cuenta creada exitosamente'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      // Pop RegisterScreen; _AuthGate ya muestra FeedScreen o CompanyDashboard.
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Symbols.error, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(auth.error ?? 'Error al registrarse')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  bool get _canSubmit {
    if (_loading) return false;
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      return false;
    }

    // Validar con los validators para que el botón refleje el estado real
    if (_isCompany) {
      if (Validators.companyName(_nameCtrl.text) != null) return false;
    } else {
      if (Validators.volunteerName(_nameCtrl.text) != null) return false;
    }
    if (Validators.email(_emailCtrl.text) != null) return false;
    if (Validators.phone(_phoneCtrl.text) != null) return false;
    if (Validators.password(_passwordCtrl.text) != null) return false;
    if (Validators.confirmPassword(_confirmCtrl.text, _passwordCtrl.text) != null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoleToggle(
                      isCompany: _isCompany,
                      onChanged: (value) => setState(() {
                        _isCompany = value;
                        _formKey.currentState?.reset();
                        _nameCtrl.clear();
                      }),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: _isCompany ? 'Nombre de empresa' : 'Nombre completo',
                        prefixIcon: Icon(
                          _isCompany ? Symbols.business : Symbols.person,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      validator: _isCompany ? Validators.companyName : Validators.volunteerName,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Symbols.mail, color: colorScheme.onSurfaceVariant),
                      ),
                      validator: Validators.email,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Teléfono (10 dígitos)',
                        prefixIcon: Icon(Symbols.phone, color: colorScheme.onSurfaceVariant),
                      ),
                      validator: Validators.phone,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Symbols.lock, color: colorScheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                          icon: Icon(
                            _obscurePassword ? Symbols.visibility : Symbols.visibility_off,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: Validators.password,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Symbols.lock, color: colorScheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                          icon: Icon(
                            _obscureConfirm ? Symbols.visibility : Symbols.visibility_off,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_isCompany) ...[
                      const SizedBox(height: 16),
                      _DescriptionField(
                        controller: _descriptionCtrl,
                        onChanged: () => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _canSubmit ? _submit : null,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Symbols.person_add),
                        label: const Text('Crear cuenta'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Al registrarte aceptas los términos de uso.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final bool isCompany;
  final ValueChanged<bool> onChanged;

  const _RoleToggle({required this.isCompany, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Voluntario',
              icon: Symbols.volunteer_activism,
              selected: !isCompany,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Empresa',
              icon: Symbols.business,
              selected: isCompany,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _DescriptionField({required this.controller, required this.onChanged});

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
    widget.onChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 250,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Descripción de la empresa (opcional)',
        prefixIcon: Icon(Symbols.description, color: colorScheme.onSurfaceVariant),
        alignLabelWithHint: true,
        counterText: '',
      ),
      validator: Validators.companyDescription,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          Text('$currentLength/250', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
