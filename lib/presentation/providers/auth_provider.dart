import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, loading, authenticated, error }

final authProvider = StateNotifierProvider<AuthProvider, AuthStatus>((ref) {
  return AuthProvider();
});

class AuthProvider extends StateNotifier<AuthStatus> {
  AuthProvider() : super(AuthStatus.loading) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token != null && token.isNotEmpty) {
        state = AuthStatus.authenticated;
      } else {
        state = AuthStatus.initial;
      }
    } catch (_) {
      // In unit tests or environments without bindings, avoid crashing.
      state = AuthStatus.initial;
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 1));
    // Check stored credentials (mock user store in SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user::${email.toLowerCase().trim()}');
    if (stored != null) {
      if (stored == password) {
        await prefs.setString('authToken', 'mockToken');
        await prefs.setString('userId', email.toLowerCase().trim());
        state = AuthStatus.authenticated;
        return;
      } else {
        state = AuthStatus.error;
        return;
      }
    }

    // fallback: allow the default test user for compatibility
    if (email == 'test@test.com' && password == 'password') {
      await prefs.setString('authToken', 'mockToken');
      await prefs.setString('userId', email.toLowerCase().trim());
      state = AuthStatus.authenticated;
      return;
    }

    state = AuthStatus.error;
  }

  Future<void> signup(String email, String password) async {
    state = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final key = 'user::${email.toLowerCase().trim()}';
    await prefs.setString(key, password);
    await prefs.setString('authToken', 'mockToken');
    await prefs.setString('userId', email.toLowerCase().trim());
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userId');
    state = AuthStatus.initial;
  }
}
