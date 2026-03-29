import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import '../expense/expense_screen.dart';
import '../income/income_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// Hosts primary destinations behind a bottom navigation bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const <Widget>[
    DashboardScreen(),
    IncomeScreen(),
    ExpenseScreen(),
    WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_outlined),
            selectedIcon: const Icon(Icons.trending_up),
            label: l10n.income,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.expenseTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard_outlined),
            selectedIcon: const Icon(Icons.card_giftcard),
            label: l10n.wishlist,
          ),
        ],
      ),
    );
  }
}
