import 'package:flutter/foundation.dart';

enum AccountType { cash, bank }

extension AccountTypeX on AccountType {
  String get value => switch (this) {
    AccountType.cash => 'cash',
    AccountType.bank => 'bank',
  };

  String get label => switch (this) {
    AccountType.cash => 'Physical Cash',
    AccountType.bank => 'Bank Account',
  };

  static AccountType fromRaw(Object? raw) => switch (raw) {
    'cash' || 'physical_cash' => AccountType.cash,
    'bank' || 'bank_account' => AccountType.bank,
    _ => AccountType.cash,
  };
}

@immutable
class FinanceAccount {
  const FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final DateTime createdAt;

  FinanceAccount copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    DateTime? createdAt,
  }) {
    return FinanceAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FinanceAccount.fromJson(Map<String, dynamic> json) {
    final balanceRaw = json['balance'];

    return FinanceAccount(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      type: AccountTypeX.fromRaw(json['type']),
      balance: switch (balanceRaw) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s) ?? 0,
        _ => 0,
      },
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
