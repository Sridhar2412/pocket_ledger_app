import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';
import 'package:pocket_ledger_app/domain/repositories/wallet_repo.dart';
import 'package:pocket_ledger_app/presentation/screens/wallet_page.dart';

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
  testWidgets('Add wallet via WalletPage bottom sheet', (tester) async {
    final fakeRepo = FakeWalletRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [walletRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: WalletPage()),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure no wallets initially
    expect(find.byType(ListTile), findsNothing);

    // Tap FAB to add wallet
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Enter name and balance into the bottom sheet
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'My Wallet');
    await tester.enterText(textFields.at(1), '250');
    await tester.pumpAndSettle();

    // Tap Add button
    final addButton = find.text('Add');
    expect(addButton, findsWidgets);
    await tester.tap(addButton.last);
    await tester.pumpAndSettle();

    // Now list should show the added wallet
    expect(find.text('My Wallet'), findsOneWidget);
    expect(find.textContaining('250'), findsOneWidget);
  });
}
