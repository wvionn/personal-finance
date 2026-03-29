import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/localized_labels.dart';
import '../../domain/entities/expense.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'expense_providers.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({super.key, this.existing});

  final Expense? existing;

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _customCategoryCtrl;
  late DateTime _date;
  late String _presetCategory;
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(text: e?.amount.toString() ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _customCategoryCtrl = TextEditingController();
    _date = e?.date ?? DateTime.now();
    if (e == null) {
      _presetCategory = kExpenseCategories.first;
    } else if (kExpenseCategories.contains(e.category)) {
      _presetCategory = e.category;
    } else {
      _presetCategory = 'Other';
      _customCategoryCtrl.text = e.category;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  String get _resolvedCategory {
    if (_presetCategory == 'Other') {
      return _customCategoryCtrl.text.trim();
    }
    return _presetCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? l10n.expenseTitle : l10n.edit,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(labelText: l10n.amountLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return l10n.validatorAmountPositive;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _presetCategory,
                items: kExpenseCategories
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(expenseCategoryLabel(s, lang)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _presetCategory = v ?? 'Other'),
                decoration: InputDecoration(labelText: l10n.categoryField),
              ),
              if (_presetCategory == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customCategoryCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.categoryDescribeLabel,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (_presetCategory != 'Other') return null;
                    if (v == null || v.trim().isEmpty) {
                      return l10n.categoryRequired;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.dateLabel),
                subtitle: Text(_date.toLocal().toString().split(' ').first),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(labelText: l10n.noteOptionalLabel),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final cat = _resolvedCategory;
                  if (cat.isEmpty) return;
                  final repo = ref.read(financeRepositoryProvider);
                  final exp = Expense(
                    id: widget.existing?.id ?? _uuid.v4(),
                    amount: double.parse(_amountCtrl.text.trim()),
                    category: cat,
                    date: _date,
                    note: _noteCtrl.text.trim().isEmpty
                        ? null
                        : _noteCtrl.text.trim(),
                  );
                  await repo.upsertExpense(exp);
                  ref.invalidate(expenseListProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  ref.invalidate(dailyInsightProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
