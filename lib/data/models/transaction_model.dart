import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:pocket_ledger_app/domain/models/transaction_model.dart'
    as domain;

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// Hive Adapter Type ID = 1
@HiveType(typeId: 1)
@freezed
class TransactionModel with _$TransactionModel {
  const TransactionModel._(); // For adding custom methods

  const factory TransactionModel({
    @HiveField(0) required String id,
    @HiveField(1) required double amount,
    @HiveField(2) required DateTime date,
    @HiveField(3) required String category,
    @HiveField(4) required String walletId,
    @HiveField(5) required String note,
    @HiveField(6) String? receiptUrl,
    @HiveField(7) required DateTime updatedAt,
    @HiveField(8) @Default(false) bool isDeleted,
  }) = _TransactionModel;
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  // Domain to Data Mappers

  /// Convert Domain Entityt to Data Model
  factory TransactionModel.fromEntity(domain.TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
      walletId: entity.walletId,
      note: entity.note,
      receiptUrl: entity.receiptUrl,
      isDeleted: entity.isDeleted,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert Data Model to Domain Entity
  domain.TransactionEntity toEntity() {
    return domain.TransactionEntity(
      id: id,
      amount: amount,
      date: date,
      category: category,
      walletId: walletId,
      note: note,
      receiptUrl: receiptUrl,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }
}
