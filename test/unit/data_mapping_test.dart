import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ledger_app/data/models/transaction_model.dart' as data;
import 'package:pocket_ledger_app/domain/models/transaction_model.dart'
    as domain;

void main() {
  group('Transaction data<->domain mapping', () {
    test('fromEntity and toEntity preserve values', () {
      final domainTxn = domain.TransactionEntity(
        id: 't1',
        amount: 123.45,
        date: DateTime.utc(2023, 1, 2),
        category: 'Food',
        walletId: 'w1',
        note: 'Lunch',
        receiptUrl: 'path/to/receipt',
        updatedAt: DateTime.utc(2023, 1, 2),
        isDeleted: false,
      );

      final dataModel = data.TransactionModel.fromEntity(domainTxn);
      final converted = dataModel.toEntity();

      expect(converted.id, domainTxn.id);
      expect(converted.amount, domainTxn.amount);
      expect(converted.category, domainTxn.category);
      expect(converted.walletId, domainTxn.walletId);
      expect(converted.note, domainTxn.note);
      expect(converted.receiptUrl, domainTxn.receiptUrl);
      expect(converted.updatedAt, domainTxn.updatedAt);
      expect(converted.isDeleted, domainTxn.isDeleted);
    });
  });
}
