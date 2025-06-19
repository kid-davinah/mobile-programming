class AuthState {
  final bool isLoading;
  final String? error;
  final String? user; // You can use a User model if you want

  static const Map<String, Map<String, String>> demoUsers = {
    'admin': {'password': 'admin123', 'role': 'admin'},
    'user': {'password': 'user123', 'role': 'user'},
    'demo': {'password': 'demo123', 'role': 'demo'},
  };

  AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, String? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }

  List<String> get availableUsernames => demoUsers.keys.toList();

  Map<String, String>? getUserInfo(String username) => demoUsers[username];
} 