import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_ledger_app/domain/models/transaction_model.dart';

Future<bool> exportTransactionsAsJson(
    BuildContext context, List<TransactionEntity> txns) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final List<Map<String, dynamic>> jsonList = txns.map((t) {
      return {
        'id': t.id,
        'amount': t.amount,
        'date': t.date.toIso8601String(),
        'category': t.category,
        'walletId': t.walletId,
        'note': t.note,
        'receiptUrl': t.receiptUrl,
        'isDeleted': t.isDeleted,
        'updatedAt': t.updatedAt.toIso8601String(),
      };
    }).toList();

    final pretty = const JsonEncoder.withIndent('  ').convert(jsonList);

    if (kIsWeb) {
      // On web we can't write to user's filesystem reliably; copy to clipboard
      await Clipboard.setData(ClipboardData(text: pretty));
      messenger.showSnackBar(
          const SnackBar(content: Text('Exported JSON copied to clipboard.')));
      return true;
    }

    // Try platform-specific public Downloads (Android), then desktop Downloads,
    // otherwise fall back to application documents directory.
    Directory? targetDir;
    if (Platform.isAndroid) {
      try {
        final dirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads);
        if (dirs != null && dirs.isNotEmpty) {
          targetDir = dirs.first;
        }
      } catch (_) {
        targetDir = null;
      }
    }

    if (targetDir == null) {
      try {
        targetDir = await getDownloadsDirectory();
      } catch (_) {
        targetDir = null;
      }
    }

    // Fallback to application documents directory if no public downloads available.
    targetDir ??= await getApplicationDocumentsDirectory();

    final filename =
        'transactions_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${targetDir.path}/$filename');
    await file.writeAsString(pretty);

    messenger.showSnackBar(
        SnackBar(content: Text('Exported JSON saved to ${file.path}')));
    return true;
  } catch (e, st) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    debugPrint('Export failed: $e\n$st');
    return false;
  }
}
