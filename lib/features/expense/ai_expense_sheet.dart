import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/expense.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'expense_providers.dart';

class AiExpenseParser {
  static Expense? parse(String raw, String id) {
    final s = raw.toLowerCase().trim();
    if (s.isEmpty) return null;

    final numMatch =
        RegExp(r'([\d][\d.,]*)\s*(k|rb|ribu|jt|juta)?', caseSensitive: false)
            .firstMatch(s);
    if (numMatch == null) return null;

    var rawNum = numMatch.group(1)!.replaceAll('.', '');
    if (rawNum.contains(',')) {
      rawNum = rawNum.replaceAll(',', '.');
    }
    var amount = double.tryParse(rawNum);
    if (amount == null) return null;

    final mult = numMatch.group(2)?.toLowerCase();
    if (mult == 'k' || mult == 'rb' || mult == 'ribu') {
      amount *= 1000;
    } else if (mult == 'jt' || mult == 'juta') {
      amount *= 1000000;
    }

    if (amount <= 0) return null;

    var category = 'Lainnya';
    if (RegExp(r'makan|nasi|warung|warteg').hasMatch(s)) {
      category = 'Makan';
    } else if (RegExp(r'bensin|bbm|spbu|pertalite').hasMatch(s)) {
      category = 'Bahan bakar';
    } else if (RegExp(r'kopi|kafe|coffee|minum').hasMatch(s)) {
      category = 'Minuman';
    } else if (RegExp(
      r'transport|gojek|grab|ojek|taksi|angkot|bus|mrt',
    ).hasMatch(s)) {
      category = 'Transport';
    } else if (RegExp(r'belanja|indomaret|alfamart').hasMatch(s)) {
      category = 'Belanja';
    }

    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: DateTime.now(),
      note: raw.trim(),
    );
  }
}

class AiExpenseSheet extends ConsumerStatefulWidget {
  const AiExpenseSheet({super.key});

  @override
  ConsumerState<AiExpenseSheet> createState() => _AiExpenseSheetState();
}

class _AiExpenseSheetState extends ConsumerState<AiExpenseSheet> {
  final _ctrl = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.aiInput, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l10n.aiHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: l10n.aiHint,
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final parsed = AiExpenseParser.parse(_ctrl.text, _uuid.v4());
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.aiParseError)),
        );
      }
      return;
    }
    final repo = ref.read(financeRepositoryProvider);
    await repo.upsertExpense(parsed);
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dailyInsightProvider);
    if (mounted) Navigator.pop(context);
  }
}
