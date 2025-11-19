import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_ledger_app/core/constants/constants.dart';
import 'package:pocket_ledger_app/data/helper/dio_instance.dart';
import 'package:pocket_ledger_app/data/models/transaction_model.dart';
import 'package:pocket_ledger_app/data/models/wallet_model.dart';
import 'package:pocket_ledger_app/data/repositories/transaction_repo_impl.dart';
import 'package:pocket_ledger_app/data/repositories/wallet_repo_impl.dart';
import 'package:pocket_ledger_app/data/source/api_source.dart';
// domain transaction model not required here
import 'package:pocket_ledger_app/domain/repositories/transaction_repo.dart';
import 'package:pocket_ledger_app/domain/repositories/wallet_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Initialization Providers ---
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final hiveInitializerProvider = FutureProvider<void>((ref) async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register Adapters
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<Wallet>(Constants.walletBox);
  await Hive.openBox<TransactionModel>(Constants.transactionBox);
  // Auth box is simple SharedPreferences mock, no dedicated Hive box for token.
});

// --- Data Layer Providers ---
final dioProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw Exception('SharedPreferences not initialized');
  return createDio(prefs);
});

final apiProvider = Provider((ref) => ApiSource(ref.watch(dioProvider)));

final walletBoxProvider = Provider((ref) {
  // Wait for Hive initialization
  ref.watch(hiveInitializerProvider);
  return Hive.box<Wallet>(Constants.walletBox);
});

final transactionBoxProvider = Provider((ref) {
  ref.watch(hiveInitializerProvider);
  return Hive.box<TransactionModel>(Constants.transactionBox);
});

final walletRepositoryProvider = Provider<WalletRepository>(
    (ref) => WalletRepositoryImpl(ref.watch(walletBoxProvider)));

final transactionRepositoryProvider = Provider<TransactionRepository>(
    (ref) => TransactionRepositoryImpl(ref.watch(transactionBoxProvider)));
