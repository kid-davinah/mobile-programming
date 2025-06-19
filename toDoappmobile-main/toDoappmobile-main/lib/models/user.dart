class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.preferences = const {},
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      preferences: json['preferences'] ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
} 