import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String id,
    required double amount,
    required DateTime date,
    required String category,
    required String walletId,
    required String note,
    String? receiptUrl,
    @Default(false) bool isDeleted,
    required DateTime updatedAt,
  }) = _TransactionModel;
}
