import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/data/dto/transaction_dto.dart';
import 'package:pocket_ledger_app/data/models/transaction_model.dart'
    as data_model;
import 'package:pocket_ledger_app/data/source/api_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastTxnSyncKey = 'last_sync_transactions';

final syncServiceProvider = Provider<SyncService>((ref) {
  final api = ref.watch(apiProvider);
  final transactionBox = ref.watch(transactionBoxProvider);
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (v) => v,
        orElse: () => null,
      );
  return SyncService(api, transactionBox, prefs);
});

class SyncService {
  final ApiSource _api;
  final Box<data_model.TransactionModel> _transactionBox;
  final SharedPreferences? _prefs;

  SyncService(this._api, this._transactionBox, this._prefs);

  DateTime _lastSync() {
    final millis = _prefs?.getInt(_kLastTxnSyncKey) ?? 0;
    if (millis == 0) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _setLastSync(DateTime t) async {
    await _prefs?.setInt(_kLastTxnSyncKey, t.millisecondsSinceEpoch);
  }

  TransactionDTO _toDto(data_model.TransactionModel m) {
    return TransactionDTO(
      id: m.id,
      amount: m.amount,
      category: m.category,
      walletId: m.walletId,
      note: m.note,
      receiptUrl: m.receiptUrl,
      date: m.date.toIso8601String(),
      updatedAt: m.updatedAt.toIso8601String(),
      isDeleted: m.isDeleted,
    );
  }

  data_model.TransactionModel _fromDto(TransactionDTO dto) {
    return data_model.TransactionModel(
      id: dto.id,
      amount: dto.amount,
      date: DateTime.parse(dto.date),
      category: dto.category,
      walletId: dto.walletId,
      note: dto.note,
      receiptUrl: dto.receiptUrl,
      updatedAt: DateTime.parse(dto.updatedAt),
      isDeleted: dto.isDeleted,
    );
  }

  /// Push local changes that are newer than last sync.
  Future<bool> pushLocalChanges() async {
    try {
      final lastSync = _lastSync();
      final local = _transactionBox.values.toList();

      for (final tx in local) {
        if (tx.updatedAt.isAfter(lastSync)) {
          final dto = _toDto(tx);
          if (tx.isDeleted) {
            try {
              await _api.deleteTransaction(tx.id);
              // remove locally
              await _transactionBox.delete(tx.id);
            } catch (e) {
              continue;
            }
          } else {
            try {
              await _api.updateTransaction(tx.id, dto);
            } catch (e) {
              try {
                await _api.addTransaction(dto);
              } catch (e) {
                continue;
              }
            }
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pull remote transactions and insert into local box using updatedAt.
  Future<bool> pullRemoteUpdates() async {
    try {
      final remote = await _api.getTransactions();
      for (final dto in remote) {
        final local = _transactionBox.get(dto.id);
        final remoteModel = _fromDto(dto);
        if (local == null) {
          await _transactionBox.put(remoteModel.id, remoteModel);
        } else {
          if (remoteModel.updatedAt.isAfter(local.updatedAt)) {
            await _transactionBox.put(remoteModel.id, remoteModel);
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Full sync: push local changes then pull remote updates. Updates lastSync on success.
  Future<bool> performFullSync() async {
    final pushed = await pushLocalChanges();
    if (!pushed) return false;
    final pulled = await pullRemoteUpdates();
    if (!pulled) return false;
    await _setLastSync(DateTime.now().toUtc());
    return true;
  }
}
