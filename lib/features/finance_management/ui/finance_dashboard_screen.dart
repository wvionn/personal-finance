import 'package:flutter/material.dart';

import '../../dashboard/dashboard_screen.dart';

/// Finance dashboard now intentionally reuses the main dashboard UI
/// so both screens always stay visually and behaviorally consistent.
class FinanceDashboardModule extends StatelessWidget {
  const FinanceDashboardModule({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
