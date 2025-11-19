import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';

@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String id,
    required String name,
    required double balance,
    @Default(false) bool isDeleted,
    required DateTime updatedAt,
  }) = _WalletModel;
}
