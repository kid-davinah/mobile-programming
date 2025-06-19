import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));
    
    final userInfo = AuthState.demoUsers[username];
    if (userInfo != null && userInfo['password'] == password) {
      state = AuthState(isLoading: false, user: username);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Invalid username or password');
      return false;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
); 