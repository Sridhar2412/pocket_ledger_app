// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDTO _$TransactionDTOFromJson(Map<String, dynamic> json) =>
    TransactionDTO(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      walletId: json['walletId'] as String,
      note: json['note'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      date: json['date'] as String,
      updatedAt: json['updatedAt'] as String,
      isDeleted: json['isDeleted'] as bool,
    );

Map<String, dynamic> _$TransactionDTOToJson(TransactionDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'category': instance.category,
      'walletId': instance.walletId,
      'note': instance.note,
      'receiptUrl': instance.receiptUrl,
      'date': instance.date,
      'updatedAt': instance.updatedAt,
      'isDeleted': instance.isDeleted,
    };
