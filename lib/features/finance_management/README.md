# Finance Management Module

## Folder Structure

lib/features/finance_management/
- models/
  - finance_account.dart
  - finance_transaction.dart
- providers/
  - finance_controller.dart
- ui/
  - finance_dashboard_screen.dart

## Notes

- Follows clean separation: Models, Provider/Controller, and UI.
- Uses Provider (ChangeNotifier) for state management.
- Includes input validation and sanitization in controller layer.
- Uses Dart 3 records and pattern matching in balance/report calculations.
