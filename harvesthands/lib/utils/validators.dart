class Validators {
  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
  static final _nameRegex = RegExp(r'^[a-zA-ZÁÉÍÓÚáéíóúÑñ ]+$');
  static final _companyNameRegex = RegExp(r'^[a-zA-ZÁÉÍÓÚáéíóúÑñ0-9 .,&\-]+$');
  static final _passwordLetterRegex = RegExp(r'[a-zA-Z]');
  static final _passwordNumberRegex = RegExp(r'[0-9]');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
    if (v.trim().length > 100) return 'Máximo 100 caracteres';
    if (!_emailRegex.hasMatch(v.trim())) return 'Correo no válido';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'El teléfono es obligatorio';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'El teléfono debe tener 10 dígitos';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < 8) return 'Mínimo 8 caracteres, con letras y números';
    if (v.length > 32) return 'Máximo 32 caracteres';
    if (!_passwordLetterRegex.hasMatch(v)) return 'Mínimo 8 caracteres, con letras y números';
    if (!_passwordNumberRegex.hasMatch(v)) return 'Mínimo 8 caracteres, con letras y números';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
    if (v != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? volunteerName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
    if (v.trim().length < 3) return 'El nombre debe tener al menos 3 caracteres';
    if (v.trim().length > 60) return 'Máximo 60 caracteres';
    if (!_nameRegex.hasMatch(v.trim())) return 'El nombre solo puede contener letras';
    return null;
  }

  static String? companyName(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre de empresa es obligatorio';
    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
    if (v.trim().length > 80) return 'Máximo 80 caracteres';
    if (!_companyNameRegex.hasMatch(v.trim())) return 'Nombre de empresa no válido';
    return null;
  }

  static String? companyDescription(String? v) {
    if (v == null || v.trim().isEmpty) return null; // Opcional
    if (v.trim().length > 250) return 'Máximo 250 caracteres';
    return null;
  }

  static String? volunteeringTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'El título es obligatorio';
    if (v.trim().length < 5) return 'El título debe tener entre 5 y 80 caracteres';
    if (v.trim().length > 80) return 'El título debe tener entre 5 y 80 caracteres';
    return null;
  }

  static String? volunteeringDescription(String? v) {
    if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
    if (v.trim().length < 20) return 'La descripción debe tener entre 20 y 500 caracteres';
    if (v.trim().length > 500) return 'La descripción debe tener entre 20 y 500 caracteres';
    return null;
  }

  static String? capacity(String? v) {
    if (v == null || v.trim().isEmpty) return 'El cupo es obligatorio';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 999) return 'El cupo debe estar entre 1 y 999';
    return null;
  }

  static String? futureDate(DateTime? d) {
    if (d == null) return 'La fecha es obligatoria';
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(d.year, d.month, d.day);
    if (!selectedDate.isAfter(todayDate)) return 'La fecha debe ser posterior a hoy';
    final maxDate = DateTime(today.year + 2, today.month, today.day);
    if (selectedDate.isAfter(maxDate)) return 'La fecha no puede ser mayor a 2 años';
    return null;
  }
}
