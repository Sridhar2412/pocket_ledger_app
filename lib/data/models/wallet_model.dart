import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:pocket_ledger_app/domain/models/wallet_model.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart'; // Hive & JSON adapter

// Adapter Type ID 0
@HiveType(typeId: 0)
@freezed
class Wallet with _$Wallet {
  const Wallet._(); // Private constructor for custom methods

  const factory Wallet({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required double balance,
    @HiveField(3) @Default(false) bool isDeleted,
    @HiveField(4) required DateTime updatedAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  // Mappers
  factory Wallet.fromEntity(WalletModel entity) => Wallet(
        id: entity.id,
        name: entity.name,
        balance: entity.balance,
        isDeleted: entity.isDeleted,
        updatedAt: entity.updatedAt,
      );

  WalletModel toEntity() => WalletModel(
        id: id,
        name: name,
        balance: balance,
        isDeleted: isDeleted,
        updatedAt: updatedAt,
      );
}
