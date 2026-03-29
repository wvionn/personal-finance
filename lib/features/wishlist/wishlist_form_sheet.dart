import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import 'wishlist_providers.dart';

class WishlistFormSheet extends ConsumerStatefulWidget {
  const WishlistFormSheet({super.key, this.existing});

  final WishlistItem? existing;

  @override
  ConsumerState<WishlistFormSheet> createState() => _WishlistFormSheetState();
}

class _WishlistFormSheetState extends ConsumerState<WishlistFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _savedCtrl;
  late final TextEditingController _urlCtrl;
  late WishlistPriority _priority;
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(
      text: e?.estimatedPrice.toString() ?? '',
    );
    _savedCtrl = TextEditingController(
      text: e != null && e.savedAmount > 0 ? e.savedAmount.toString() : '',
    );
    _urlCtrl = TextEditingController(text: e?.itemUrl ?? '');
    _priority = e?.priority ?? WishlistPriority.medium;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _savedCtrl.dispose();
    _urlCtrl.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null
                    ? l10n.wishlistAddItem
                    : l10n.wishlistEditItem,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.nameLabel),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(labelText: l10n.estimatedPrice),
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
              TextFormField(
                controller: _savedCtrl,
                decoration: InputDecoration(
                  labelText: l10n.alreadySavedOptional,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return l10n.validAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlCtrl,
                decoration: InputDecoration(
                  labelText: l10n.ecommerceLinkOptional,
                  hintText: 'https://shopee.co.id/...',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.priority,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<WishlistPriority>(
                segments: [
                  ButtonSegment(
                    value: WishlistPriority.low,
                    label: Text(l10n.priorityLow),
                  ),
                  ButtonSegment(
                    value: WishlistPriority.medium,
                    label: Text(l10n.priorityMedium),
                  ),
                  ButtonSegment(
                    value: WishlistPriority.high,
                    label: Text(l10n.priorityHigh),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final repo = ref.read(financeRepositoryProvider);
                  final savedAmt =
                      double.tryParse(_savedCtrl.text.trim()) ?? 0.0;
                  final itemUrl = _urlCtrl.text.trim().isEmpty
                      ? null
                      : _urlCtrl.text.trim();

                  final item = WishlistItem(
                    id: widget.existing?.id ?? _uuid.v4(),
                    name: _nameCtrl.text.trim(),
                    estimatedPrice: double.parse(_priceCtrl.text.trim()),
                    priority: _priority,
                    targetAmount: double.parse(_priceCtrl.text.trim()),
                    savedAmount: savedAmt,
                    itemUrl: itemUrl,
                    purchased: widget.existing?.purchased ?? false,
                    purchasedAt: widget.existing?.purchasedAt,
                  );
                  await repo.upsertWishlistItem(item);
                  ref.invalidate(wishlistProvider);
                  ref.invalidate(dashboardSummaryProvider);
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
