import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';

import '../models/finance_account.dart';
import '../models/finance_transaction.dart';

typedef OperationResult = ({bool success, String? error});

class FinanceController extends ChangeNotifier {
  FinanceController({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  List<FinanceAccount> _accounts = const [];
  List<FinanceTransaction> _transactions = const [];
  bool _isInitialized = false;
  bool _isDisposed = false;

  UnmodifiableListView<FinanceAccount> get accounts =>
      UnmodifiableListView(_accounts);

  UnmodifiableListView<FinanceTransaction> get transactions =>
      UnmodifiableListView(_transactions);

  List<FinanceTransaction> get recentTransactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted.take(10));
  }

  ({double cash, double bank, double total}) get totalBalanceBreakdown {
    ({double cash, double bank}) totals = (cash: 0, bank: 0);

    for (final account in _accounts) {
      totals = switch (account.type) {
        AccountType.cash => (
          cash: totals.cash + account.balance,
          bank: totals.bank,
        ),
        AccountType.bank => (
          cash: totals.cash,
          bank: totals.bank + account.balance,
        ),
      };
    }

    return (
      cash: totals.cash,
      bank: totals.bank,
      total: totals.cash + totals.bank,
    );
  }

  ({double income, double expense, double net}) get weeklySummary {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    return _cashFlowForRange(start, now);
  }

  ({double income, double expense, double net}) get monthlySummary {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _cashFlowForRange(start, now);
  }

  Future<void> initializeDefaults() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    await Future<void>.microtask(() {
      if (_accounts.isNotEmpty) {
        return;
      }

      _accounts = [
        FinanceAccount(
          id: _uuid.v4(),
          name: 'Wallet',
          type: AccountType.cash,
          balance: 0,
          createdAt: DateTime.now(),
        ),
        FinanceAccount(
          id: _uuid.v4(),
          name: 'Main Bank',
          type: AccountType.bank,
          balance: 0,
          createdAt: DateTime.now(),
        ),
      ];

      _notifySafely();
    });
  }

  OperationResult addAccountFromInput({
    required String nameInput,
    required AccountType type,
    required String openingBalanceInput,
  }) {
    final sanitizedName = _sanitizeText(nameInput, maxLength: 40);
    if (sanitizedName.isEmpty) {
      return (success: false, error: 'Account name is required.');
    }

    final openingBalance = _tryParseMoney(openingBalanceInput);
    if (openingBalance == null) {
      return (success: false, error: 'Opening balance is invalid.');
    }
    if (openingBalance < 0) {
      return (success: false, error: 'Opening balance cannot be negative.');
    }

    final account = FinanceAccount(
      id: _uuid.v4(),
      name: sanitizedName,
      type: type,
      balance: openingBalance,
      createdAt: DateTime.now(),
    );

    _accounts = [..._accounts, account];
    _notifySafely();
    return (success: true, error: null);
  }

  OperationResult addTransactionFromInput({
    required String accountId,
    required TransactionType type,
    required String amountInput,
    required String descriptionInput,
    bool allowNegativeBalance = false,
  }) {
    final selectedAccountId = accountId.trim();
    if (selectedAccountId.isEmpty) {
      return (success: false, error: 'Please choose an account.');
    }

    final account = _accounts
        .where((item) => item.id == selectedAccountId)
        .cast<FinanceAccount?>()
        .firstOrNull;

    if (account == null) {
      return (success: false, error: 'Selected account was not found.');
    }

    final amount = _tryParseMoney(amountInput);
    if (amount == null || amount <= 0) {
      return (success: false, error: 'Amount must be greater than zero.');
    }

    final description = _sanitizeText(descriptionInput, maxLength: 100);
    if (description.isEmpty) {
      return (success: false, error: 'Description is required.');
    }

    if (type case TransactionType.expense) {
      if (!allowNegativeBalance && account.balance < amount) {
        return (
          success: false,
          error: 'Insufficient balance for this expense.',
        );
      }
    }

    final updatedBalance = switch (type) {
      TransactionType.income => account.balance + amount,
      TransactionType.expense => account.balance - amount,
    };

    final updatedAccount = account.copyWith(balance: updatedBalance);

    final transaction = FinanceTransaction(
      id: _uuid.v4(),
      accountId: updatedAccount.id,
      type: type,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
    );

    _accounts = _accounts
        .map((item) => item.id == updatedAccount.id ? updatedAccount : item)
        .toList(growable: false);

    _transactions = [transaction, ..._transactions];
    _notifySafely();
    return (success: true, error: null);
  }

  ({double income, double expense, double net}) _cashFlowForRange(
    DateTime start,
    DateTime end,
  ) {
    ({double income, double expense}) totals = (income: 0, expense: 0);

    for (final item in _transactions) {
      if (item.createdAt.isBefore(start) || item.createdAt.isAfter(end)) {
        continue;
      }

      totals = switch (item.type) {
        TransactionType.income => (
          income: totals.income + item.amount,
          expense: totals.expense,
        ),
        TransactionType.expense => (
          income: totals.income,
          expense: totals.expense + item.amount,
        ),
      };
    }

    return (
      income: totals.income,
      expense: totals.expense,
      net: totals.income - totals.expense,
    );
  }

  double? _tryParseMoney(String input) {
    final normalized = input
        .trim()
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  String _sanitizeText(String input, {required int maxLength}) {
    final noControls = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');
    final compacted = noControls.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (compacted.length <= maxLength) {
      return compacted;
    }

    return compacted.substring(0, maxLength).trim();
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    switch (phase) {
      case SchedulerPhase.idle:
      case SchedulerPhase.postFrameCallbacks:
        notifyListeners();
      default:
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed) {
            return;
          }
          notifyListeners();
        });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
