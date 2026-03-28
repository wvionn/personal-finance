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

class _SavingsGoalEditorSheetState extends ConsumerState<SavingsGoalEditorSheet> {
  late final _titleCtrl = TextEditingController(text: widget.initial.title);
  late final _targetCtrl =
      TextEditingController(text: widget.initial.targetAmount.toString());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
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
            Text(l10n.savingsGoal,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: l10n.goalName),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validatorTitleRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetCtrl,
              decoration: InputDecoration(labelText: l10n.amountField),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return l10n.validatorAmountPositive;
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final repo = ref.read(financeRepositoryProvider);
                await repo.upsertSavingsGoal(
                  SavingsGoal(
                    id: widget.initial.id,
                    title: _titleCtrl.text.trim(),
                    targetAmount: double.parse(_targetCtrl.text.trim()),
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
