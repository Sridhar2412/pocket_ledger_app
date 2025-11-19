import 'package:hive/hive.dart';
import 'package:pocket_ledger_app/data/models/transaction_model.dart' as data;
import 'package:pocket_ledger_app/domain/models/transaction_model.dart';
import 'package:pocket_ledger_app/domain/repositories/transaction_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this.transactionBox);
  final Box<data.TransactionModel> transactionBox;

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return [];
    final prefix = '$userId::';
    final map = transactionBox.toMap();
    return map.entries
        .where((e) => (e.key as String).startsWith(prefix))
        .map((e) => (e.value).toEntity())
        .where((t) => !t.isDeleted)
        .toList();
  }

  @override
  Future<void> addTransaction(TransactionEntity txn) async {
    final model = data.TransactionModel.fromEntity(txn);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) throw Exception('No userId for adding transaction');
    var key = '$userId::${model.id}';
    if (transactionBox.containsKey(key)) {
      final newId = '${model.id}_${DateTime.now().microsecondsSinceEpoch}';
      final newModel = model.copyWith(id: newId);
      key = '$userId::${newModel.id}';
      await transactionBox.put(key, newModel);
      return;
    }
    await transactionBox.put(key, model);
  }

  @override
  Future<void> editTransaction(TransactionEntity txn) async {
    final model = data.TransactionModel.fromEntity(txn);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) throw Exception('No userId for editing transaction');
    final key = '$userId::${model.id}';
    await transactionBox.put(key, model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;
    final key = '$userId::$id';
    final model = transactionBox.get(key);
    if (model != null) {
      final deleted = (model).copyWith(isDeleted: true);
      await transactionBox.put(key, deleted);
    }
  }
}
