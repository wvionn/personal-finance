import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/wishlist_item.dart';
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
  late WishlistPriority _priority;
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl =
        TextEditingController(text: e?.estimatedPrice.toString() ?? '');
    _priority = e?.priority ?? WishlistPriority.medium;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                widget.existing == null ? 'Add wishlist item' : 'Edit item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Estimated price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text('Priority', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<WishlistPriority>(
                segments: const [
                  ButtonSegment(
                    value: WishlistPriority.low,
                    label: Text('Low'),
                  ),
                  ButtonSegment(
                    value: WishlistPriority.medium,
                    label: Text('Med'),
                  ),
                  ButtonSegment(
                    value: WishlistPriority.high,
                    label: Text('High'),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (s) =>
                    setState(() => _priority = s.first),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final repo = ref.read(financeRepositoryProvider);
                  final item = WishlistItem(
                    id: widget.existing?.id ?? _uuid.v4(),
                    name: _nameCtrl.text.trim(),
                    estimatedPrice: double.parse(_priceCtrl.text.trim()),
                    priority: _priority,
                    purchased: widget.existing?.purchased ?? false,
                    purchasedAt: widget.existing?.purchasedAt,
                  );
                  await repo.upsertWishlistItem(item);
                  ref.invalidate(wishlistProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
