import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../l10n/app_localizations.dart';
import '../dashboard_providers.dart';

class SavingsGoalEditorSheet extends ConsumerStatefulWidget {
  const SavingsGoalEditorSheet({super.key, required this.initial});

  final SavingsGoal initial;

  @override
  ConsumerState<SavingsGoalEditorSheet> createState() =>
      _SavingsGoalEditorSheetState();
}

class _SavingsGoalEditorSheetState
    extends ConsumerState<SavingsGoalEditorSheet> {
  late final _titleCtrl = TextEditingController(text: widget.initial.title);
  late final _targetCtrl = TextEditingController(
    text: widget.initial.targetAmount.toString(),
  );
  late final _savedCtrl = TextEditingController(
    text: widget.initial.savedAmount.toString(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  Future<void> _adjustSaved(BuildContext context, bool isAdd) async {
    final l10n = AppLocalizations.of(context)!;
    final title = isAdd ? l10n.addSavingsTitle : l10n.withdrawSavingsTitle;

    final ctrl = TextEditingController();
    final amt = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(hintText: '0', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              Navigator.pop(ctx, val);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    ctrl.dispose();

    if (amt != null && amt > 0) {
      final current = double.tryParse(_savedCtrl.text.trim()) ?? 0.0;
      final next = isAdd ? current + amt : current - amt;
      setState(() {
        _savedCtrl.text = (next < 0 ? 0.0 : next).toString();
      });
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.savingsGoal,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _savedCtrl,
              decoration: InputDecoration(labelText: l10n.currentlySaved),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (double.tryParse(v ?? '') == null) return l10n.mustBeNumber;
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _adjustSaved(context, true),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.deposit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _adjustSaved(context, false),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: Text(l10n.withdraw),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: l10n.goalName),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.validatorTitleRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetCtrl,
              decoration: InputDecoration(labelText: l10n.amountField),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return l10n.validatorAmountPositive;
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final repo = ref.read(financeRepositoryProvider);
                await repo.upsertSavingsGoal(
                  SavingsGoal(
                    id: widget.initial.id,
                    title: _titleCtrl.text.trim(),
                    targetAmount: double.tryParse(_targetCtrl.text.trim()) ?? 0,
                    savedAmount: double.tryParse(_savedCtrl.text.trim()) ?? 0,
                  ),
                );
                ref.invalidate(savingsGoalProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
