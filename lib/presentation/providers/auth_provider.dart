import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/domain/repositories/auth_repo.dart';

enum AuthStatus { initial, loading, authenticated, error }

final authProvider = StateNotifierProvider<AuthProvider, AuthStatus>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthProvider(repo);
});

class AuthProvider extends StateNotifier<AuthStatus> {
  final AuthRepository _repo;

  AuthProvider(this._repo) : super(AuthStatus.loading) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final res = await _repo.getAuthStatus();
      res.fold((err) => state = AuthStatus.initial, (has) {
        state = has ? AuthStatus.authenticated : AuthStatus.initial;
      });
    } catch (_) {
      state = AuthStatus.initial;
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthStatus.loading;
    final res = await _repo.login(email, password);
    res.fold((err) => state = AuthStatus.error, (userId) {
      state = AuthStatus.authenticated;
    });
  }

  Future<void> signup(String email, String password) async {
    state = AuthStatus.loading;
    final res = await _repo.signup(email, password);
    res.fold((err) => state = AuthStatus.error, (userId) {
      state = AuthStatus.authenticated;
    });
  }

  Future<void> logout() async {
    final res = await _repo.logout();
    res.fold(
        (err) => state = AuthStatus.initial, (_) => state = AuthStatus.initial);
  }
}
