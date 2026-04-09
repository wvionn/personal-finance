import 'package:flutter/foundation.dart';

enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get value => switch (this) {
    TransactionType.income => 'income',
    TransactionType.expense => 'expense',
  };

  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
  };

  static TransactionType fromRaw(Object? raw) => switch (raw) {
    'income' => TransactionType.income,
    'expense' => TransactionType.expense,
    _ => TransactionType.expense,
  };
}

@immutable
class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;

  FinanceTransaction copyWith({
    String? id,
    String? accountId,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? createdAt,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];

    return FinanceTransaction(
      id: (json['id'] as String?)?.trim() ?? '',
      accountId: (json['accountId'] as String?)?.trim() ?? '',
      type: TransactionTypeX.fromRaw(json['type']),
      amount: switch (amountRaw) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s) ?? 0,
        _ => 0,
      },
      description: (json['description'] as String?)?.trim() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.value,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
