import 'package:pocket_ledger_app/domain/models/transaction_model.dart';

// A repository for transaction operations
abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity txn);
  Future<void> editTransaction(TransactionEntity txn);
  Future<void> deleteTransaction(String id);
}
