class User {
  final int? id;
  final String role; // 'volunteer' | 'company'
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final String salt;
  final String? description;
  final String createdAt;

  const User({
    this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.salt,
    this.description,
    required this.createdAt,
  });

  bool get isVolunteer => role == 'volunteer';
  bool get isCompany => role == 'company';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      role: map['role'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'salt': salt,
      'description': description,
      'created_at': createdAt,
    };
  }

  User copyWith({
    int? id,
    String? role,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    String? salt,
    String? description,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
