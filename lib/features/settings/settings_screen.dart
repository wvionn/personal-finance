import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/notifications/budget_nudge_messages.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/auto_backup_service.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/database_backup_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_providers.dart';
import '../expense/expense_providers.dart';
import '../income/income_providers.dart';
import '../wishlist/wishlist_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '1.0.0';
  bool _busy = false;
  AutoBackupFrequency _autoBackupFrequency = AutoBackupFrequency.off;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadAutoBackupSetting();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _loadAutoBackupSetting() async {
    final frequency = await AutoBackupService.getFrequency();
    if (!mounted) return;
    setState(() {
      _autoBackupFrequency = frequency;
    });
  }

  void _invalidateImportedData() {
    ref.invalidate(incomeListProvider);
    ref.invalidate(expenseListProvider);
    ref.invalidate(wishlistProvider);
    ref.invalidate(averageMonthlySavingsProvider);
    ref.invalidate(quickActionsProvider);
    ref.invalidate(quickActionsCustomizeProvider);
    ref.invalidate(incomeQuickActionsProvider);
    ref.invalidate(incomeQuickActionsCustomizeProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(dailyInsightProvider);
  }

  Future<void> _exportDb() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final outputPath = await AutoBackupService.runNow(db);
      await Share.shareXFiles([
        XFile(outputPath),
      ], subject: 'Catat Uang DB backup');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExportFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setAutoBackupFrequency(AutoBackupFrequency frequency) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await AutoBackupService.setFrequency(frequency);
      if (!mounted) return;
      setState(() {
        _autoBackupFrequency = frequency;
      });
      final text = switch (frequency) {
        AutoBackupFrequency.off => l10n.autoBackupOffEnabled,
        AutoBackupFrequency.daily => l10n.autoBackupDailyEnabled,
        AutoBackupFrequency.weekly => l10n.autoBackupWeeklyEnabled,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.autoBackupSaveFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runAutoBackupNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final path = await AutoBackupService.runNow(db);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.autoBackupCreated(path))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.autoBackupCreateFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importDb() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // Use "any" so providers like Google Drive don't disable files
      // just because extension metadata is missing or non-standard.
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.single;
    var path = file.path;
    if (path == null && file.bytes != null) {
      final tempDir = await getTemporaryDirectory();
      final name = file.name.isEmpty ? 'import_backup.db' : file.name;
      final tempFile = File('${tempDir.path}/$name');
      await tempFile.writeAsBytes(file.bytes!, flush: true);
      path = tempFile.path;
    }
    if (path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importFailed('File path tidak valid'))),
      );
      return;
    }
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importDatabaseTitle),
        content: Text(l10n.importDatabaseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.importDatabase),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      await DatabaseBackupService.importFromPath(db: db, inputPath: path);
      _invalidateImportedData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importFailed(e.toString()))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final seed =
        DateTime.now().year * 400 +
        DateTime.now().month * 32 +
        DateTime.now().day;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
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
                const Icon(Icons.storage_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.backupRestoreTitle,
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
              l10n.backupRestoreSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton.icon(
              onPressed: _busy ? null : _exportDb,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.exportDatabase),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton.tonalIcon(
              onPressed: _busy ? null : _importDb,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.importDatabase),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              l10n.autoBackup,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AutoBackupFrequency>(
              segments: [
                ButtonSegment<AutoBackupFrequency>(
                  value: AutoBackupFrequency.off,
                  label: Text(l10n.off),
                ),
                ButtonSegment<AutoBackupFrequency>(
                  value: AutoBackupFrequency.daily,
                  label: Text(l10n.daily),
                ),
                ButtonSegment<AutoBackupFrequency>(
                  value: AutoBackupFrequency.weekly,
                  label: Text(l10n.weekly),
                ),
              ],
              selected: {_autoBackupFrequency},
              onSelectionChanged: _busy
                  ? null
                  : (set) async {
                      await _setAutoBackupFrequency(set.first);
                    },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _runAutoBackupNow,
              icon: const Icon(Icons.backup_outlined),
              label: Text(l10n.runAutoBackupNow),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              l10n.autoBackupHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              l10n.appVersion(_version),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
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
                  l10n.notificationTest,
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
              l10n.notificationTestSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              l10n.madeBy,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NotifTestTile(
            label: '🌞 ${l10n.notifNoonLabel}',
            preview: BudgetNudgeMessages.afternoon(seed),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 901,
                title: l10n.notifTitleNoon,
                body: BudgetNudgeMessages.afternoon(seed),
              );
            },
          ),
          _NotifTestTile(
            label: '☀️ ${l10n.notifNoonLateLabel}',
            preview: BudgetNudgeMessages.afternoonLate(seed + 1),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 902,
                title: l10n.notifTitleNoonLate,
                body: BudgetNudgeMessages.afternoonLate(seed + 1),
              );
            },
          ),
          _NotifTestTile(
            label: '🌙 ${l10n.notifNightLabel}',
            preview: BudgetNudgeMessages.evening(seed + 2),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 903,
                title: l10n.notifTitleNight,
                body: BudgetNudgeMessages.evening(seed + 2),
              );
            },
          ),
          _NotifTestTile(
            label: '🌑 ${l10n.notifLateNightLabel}',
            preview: BudgetNudgeMessages.night(seed + 3),
            onTap: () async {
              await NotificationService.showTestNotification(
                id: 904,
                title: l10n.notifTitleLateNight,
                body: BudgetNudgeMessages.night(seed + 3),
              );
            },
          ),
          _NotifTestTile(
            label: '👻 ${l10n.notifIdleLabel}',
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        child: ListTile(
          title: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(l10n.send),
          ),
        ),
      ),
    );
  }
}
