import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';
import 'package:pocket_ledger_app/domain/repositories/wallet_repo.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';

final walletProvider =
    StateNotifierProvider<WalletProvider, List<WalletModel>>((ref) {
  final repo = ref.read(walletRepositoryProvider);
  final provider = WalletProvider(repo);
  // Reload wallets when auth status changes
  ref.listen<AuthStatus>(
    authProvider,
    (previous, next) {
      if (next == AuthStatus.authenticated) {
        provider.loadWallets();
      } else {
        provider.clear();
      }
    },
  );
  return provider;
});

class WalletProvider extends StateNotifier<List<WalletModel>> {
  final WalletRepository _repository;

  WalletProvider(this._repository) : super([]) {
    // initial load handled by auth listener when authenticated
  }

  Future<void> loadWallets() async {
    state = await _repository.getWalletList();
  }

  void clear() {
    state = [];
  }

  Future<void> addWallet(WalletModel wallet) async {
    await _repository.saveWallet(wallet);
    await loadWallets();
  }

  Future<void> editWallet(WalletModel wallet) async {
    await _repository.editWallet(wallet);
    await loadWallets();
  }

  Future<void> deleteWallet(String id) async {
    await _repository.deleteWallet(id);
    await loadWallets();
  }
}
