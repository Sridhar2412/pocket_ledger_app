import 'package:json_annotation/json_annotation.dart';

part 'transaction_dto.g.dart';

@JsonSerializable()
class TransactionDTO {
  final String id;
  final double amount;
  final String category;
  final String walletId;
  final String note;
  final String? receiptUrl;
  final String date;
  final String updatedAt;
  final bool isDeleted;

  TransactionDTO({
    required this.id,
    required this.amount,
    required this.category,
    required this.walletId,
    required this.note,
    this.receiptUrl,
    required this.date,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory TransactionDTO.fromJson(Map<String, dynamic> json) =>
      _$TransactionDTOFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDTOToJson(this);
}
