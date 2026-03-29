import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/budget_nudge_messages.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final seed = DateTime.now().year * 400 + DateTime.now().month * 32 + DateTime.now().day;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'id',
                  label: Text(l10n.languageIndonesian),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.languageEnglish),
                ),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) async {
                final code = s.first;
                await ref.read(localeProvider.notifier).setLocale(Locale(code));
              },
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Test Notifikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Tap tombol di bawah untuk preview notifikasi yang akan dikirim ke HP kamu.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NotifTestTile(
            label: '🌞 Siang (12:30)',
            preview: BudgetNudgeMessages.afternoon(seed),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 901,
                title: 'Catat Uang · siang',
                body: BudgetNudgeMessages.afternoon(seed),
              );
            },
          ),
          _NotifTestTile(
            label: '☀️ Masih Siang (13:45)',
            preview: BudgetNudgeMessages.afternoonLate(seed + 1),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 902,
                title: 'Catat Uang · masih siang',
                body: BudgetNudgeMessages.afternoonLate(seed + 1),
              );
            },
          ),
          _NotifTestTile(
            label: '🌙 Malam (20:00)',
            preview: BudgetNudgeMessages.evening(seed + 2),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 903,
                title: 'Catat Uang · malam',
                body: BudgetNudgeMessages.evening(seed + 2),
              );
            },
          ),
          _NotifTestTile(
            label: '🌑 Bablas (21:30)',
            preview: BudgetNudgeMessages.night(seed + 3),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 904,
                title: 'Catat Uang · bablas',
                body: BudgetNudgeMessages.night(seed + 3),
              );
            },
          ),
          _NotifTestTile(
            label: '👻 Idle (tidak ada transaksi)',
            preview: BudgetNudgeMessages.idleRandom(),
            onTap: () async {
              await NotificationService.showIdleNoTransactionToday();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NotifTestTile extends StatelessWidget {
  const _NotifTestTile({
    required this.label,
    required this.preview,
    required this.onTap,
  });

  final String label;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        child: ListTile(
          title: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            preview,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Kirim'),
          ),
        ),
      ),
    );
  }
}
