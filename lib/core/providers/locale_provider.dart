import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('id')) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    final code = await _ref.read(financeRepositoryProvider).getLocaleCode();
    state = Locale(code == 'en' ? 'en' : 'id');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _ref
        .read(financeRepositoryProvider)
        .setLocaleCode(locale.languageCode);
  }
}
