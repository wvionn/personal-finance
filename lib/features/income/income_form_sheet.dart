import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../domain/entities/income.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'income_providers.dart';

class IncomeFormSheet extends ConsumerStatefulWidget {
  const IncomeFormSheet({super.key, this.existing});

  final Income? existing;

  @override
  ConsumerState<IncomeFormSheet> createState() => _IncomeFormSheetState();
}

class _IncomeFormSheetState extends ConsumerState<IncomeFormSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _customSourceCtrl;
  late DateTime _date;
  late String _presetSource;
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(text: e?.amount.toString() ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _customSourceCtrl = TextEditingController();
    _date = e?.date ?? DateTime.now();
    if (e == null) {
      _presetSource = kIncomeSources.first;
    } else if (kIncomeSources.contains(e.source)) {
      _presetSource = e.source;
    } else {
      _presetSource = 'Other';
      _customSourceCtrl.text = e.source;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customSourceCtrl.dispose();
    super.dispose();
  }

  String get _resolvedSource {
    if (_presetSource == 'Other') {
      return _customSourceCtrl.text.trim();
    }
    return _presetSource;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                widget.existing == null ? l10n.income : l10n.edit,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _presetSource,
                items: kIncomeSources
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _presetSource = v ?? 'Other'),
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              if (_presetSource == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customSourceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Describe source',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (_presetSource != 'Other') return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a source';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
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
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final src = _resolvedSource;
                  if (src.isEmpty) return;
                  final repo = ref.read(financeRepositoryProvider);
                  final inc = Income(
                    id: widget.existing?.id ?? _uuid.v4(),
                    amount: double.parse(_amountCtrl.text.trim()),
                    source: src,
                    date: _date,
                    note: _noteCtrl.text.trim().isEmpty
                        ? null
                        : _noteCtrl.text.trim(),
                  );
                  await repo.upsertIncome(inc);
                  ref.invalidate(incomeListProvider);
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
