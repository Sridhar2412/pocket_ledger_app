import 'package:hive/hive.dart';
import 'package:pocket_ledger_app/core/exceptions/app_exception.dart';
import 'package:pocket_ledger_app/data/models/wallet_model.dart' as data;
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';
import 'package:pocket_ledger_app/domain/repositories/wallet_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

// part 'wallet_repo_impl.g.dart';

//
class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this.walletBox);
  final Box<data.Wallet> walletBox;
  @override
  Future<List<WalletModel>> getWalletList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return [];
      final prefix = '$userId::';
      final map = walletBox.toMap();
      return map.entries
          .where((e) => (e.key as String).startsWith(prefix))
          .map((e) => (e.value).toEntity())
          .toList();
    } catch (e) {
      throw AppException(
          type: ErrorType.other,
          message: 'Failed to get wallets from local storage: $e');
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    try {
      // Soft delete: mark as deleted, actual removal happens on sync cleanup
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return;
      final key = '$userId::$id';
      final wallet = walletBox.get(key);
      if (wallet != null) {
        await walletBox.put(
            key, (wallet).copyWith(isDeleted: true, updatedAt: DateTime.now()));
      }
    } catch (e) {
      throw AppException(
          type: ErrorType.other,
          message: 'Failed to delete wallet locally: $e');
    }
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception('No userId for saving wallet');
      final key = '$userId::${wallet.id}';
      await walletBox.put(key, data.Wallet.fromEntity(wallet));
    } catch (e) {
      throw AppException(
          type: ErrorType.other,
          message: 'Failed to save wallet to local storage: $e');
    }
  }

  @override
  Future<void> editWallet(WalletModel wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception('No userId for editing wallet');
      final key = '$userId::${wallet.id}';
      await walletBox.put(key, data.Wallet.fromEntity(wallet));
    } catch (e) {
      throw AppException(
          type: ErrorType.other,
          message: 'Failed to edit wallet to local storage: $e');
    }
  }
}
