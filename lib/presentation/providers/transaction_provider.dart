import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/domain/models/transaction_model.dart';
import 'package:pocket_ledger_app/domain/repositories/transaction_repo.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';

final transactionProvider =
    StateNotifierProvider<TransactionProvider, List<TransactionEntity>>((ref) {
  final repo = ref.read(transactionRepositoryProvider);
  final provider = TransactionProvider(repo);
  ref.listen<AuthStatus>(
    authProvider,
    (previous, next) {
      if (next == AuthStatus.authenticated) {
        provider.loadTransactions();
      } else {
        provider.clear();
      }
    },
  );
  return provider;
});

class TransactionProvider extends StateNotifier<List<TransactionEntity>> {
  final TransactionRepository _repo;

  TransactionProvider(this._repo) : super([]) {
    // initial load handled by auth listener
  }

  Future<void> loadTransactions() async {
    state = await _repo.getTransactions();
  }

  Future<void> addTransaction(TransactionEntity txn) async {
    await _repo.addTransaction(txn);
    await loadTransactions();
  }

  Future<void> editTransaction(TransactionEntity txn) async {
    await _repo.editTransaction(txn);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    await loadTransactions();
  }

  void clear() {
    state = [];
  }
}
