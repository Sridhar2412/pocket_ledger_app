import 'package:pocket_ledger_app/domain/models/wallet_model.dart';

// A repository for wallet operations
abstract class WalletRepository {
  Future<List<WalletModel>> getWalletList();
  Future<void> saveWallet(WalletModel wallet);
  Future<void> editWallet(WalletModel wallet);
  Future<void> deleteWallet(String id);
}
