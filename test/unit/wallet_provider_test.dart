import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';
import 'package:pocket_ledger_app/domain/repositories/wallet_repo.dart';
import 'package:pocket_ledger_app/presentation/providers/wallet_provider.dart';

class FakeWalletRepository implements WalletRepository {
  final List<WalletModel> _store = [];

  @override
  Future<void> deleteWallet(String id) async {
    _store.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> editWallet(WalletModel wallet) async {
    final idx = _store.indexWhere((w) => w.id == wallet.id);
    if (idx >= 0) _store[idx] = wallet;
  }

  @override
  Future<List<WalletModel>> getWalletList() async {
    return List.unmodifiable(_store);
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    _store.add(wallet);
  }
}

void main() {
  test('WalletProvider add/edit/delete updates state', () async {
    final fakeRepo = FakeWalletRepository();
    final container = ProviderContainer(overrides: [
      walletRepositoryProvider.overrideWithValue(fakeRepo),
    ]);

    final notifier = container.read(walletProvider.notifier);

    // initially loads wallets (constructor calls loadWallets)
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(walletProvider), isEmpty);

    final wallet = WalletModel(
      id: 'w1',
      name: 'Test Wallet',
      balance: 100.0,
      updatedAt: DateTime.now(),
    );

    await notifier.addWallet(wallet);
    expect(container.read(walletProvider), hasLength(1));
    expect(container.read(walletProvider).first.name, 'Test Wallet');

    final edited = wallet.copyWith(name: 'Edited');
    await notifier.editWallet(edited);
    expect(container.read(walletProvider).first.name, 'Edited');

    await notifier.deleteWallet(wallet.id);
    expect(container.read(walletProvider), isEmpty);

    container.dispose();
  });
}
