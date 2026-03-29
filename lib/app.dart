import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';
import 'l10n/app_localizations.dart';

class CatatUangApp extends ConsumerWidget {
  const CatatUangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Piyon finance tracking',
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
