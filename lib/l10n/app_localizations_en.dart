// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anti Boncos';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get balance => 'Balance';

  @override
  String get balanceSubtitle => 'All-time in − out';

  @override
  String get periodIncome => 'In (period)';

  @override
  String get periodExpense => 'Out (period)';

  @override
  String get trend => 'Trend';

  @override
  String get trendIncome => 'In';

  @override
  String get trendExpense => 'Out';

  @override
  String get monthly => 'Monthly';

  @override
  String get daily => 'Daily';

  @override
  String get savingsGoal => 'Savings goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get validatorTitleRequired => 'Please enter a title';

  @override
  String get validatorAmountPositive => 'Enter a positive amount';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get quickAddIncome10 => '+10 rb';

  @override
  String get quickAddIncome20 => '+20 rb';

  @override
  String get quickAddExpense10 => '−10 rb';

  @override
  String get dailyStatus => 'No data';

  @override
  String get statusHemat => 'Hemat';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusBoros => 'Boros';

  @override
  String get statusHematHint => 'Spending lighter than your month average.';

  @override
  String get statusNormalHint => 'Right around your usual pace.';

  @override
  String get statusBorosHint => 'Above your month average — pace yourself.';

  @override
  String get statusNoData => 'Log a few expenses this month to unlock status.';

  @override
  String get smartQuickAdd => 'One tap';

  @override
  String get customizeQuick => 'Edit buttons';

  @override
  String get aiInput => 'Type to log (smart)';

  @override
  String get aiHint => 'Example: makan 25rb, kopi 15k';

  @override
  String get searchExpense => 'Search category or note';

  @override
  String get monthlyReport => 'Monthly report';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get noChartData => 'No data';

  @override
  String get wishlistPlanned => 'Planned';

  @override
  String get wishlistPurchased => 'Purchased';

  @override
  String get addQuickTitle => 'Add quick button';

  @override
  String get editQuickTitle => 'Edit quick button';

  @override
  String get labelField => 'Label';

  @override
  String get amountField => 'Amount (Rp)';

  @override
  String get categoryField => 'Category';

  @override
  String get emojiField => 'Emoji';

  @override
  String get edit => 'Edit';

  @override
  String get purchased => 'Purchased';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get incomeSourceQuick => 'Quick add';

  @override
  String get noteQuickDash => 'Dashboard quick';

  @override
  String get recorded => 'Recorded';

  @override
  String get todaySpend => 'Today';

  @override
  String get expenseTitle => 'Spending';

  @override
  String get aiParseError => 'Could not parse. Try: food 25k';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get noSearchMatches => 'No matches';

  @override
  String get tapToLog => 'Use quick buttons or + to add.';

  @override
  String get reportEmptyMonth => 'No expenses this month.';

  @override
  String percentOfSpend(Object pct) {
    return '$pct% of spend';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get noIncomeYet => 'No income yet';

  @override
  String get noIncomeMatches => 'No matches';

  @override
  String get tapToAddIncome => 'Tap + to add income.';

  @override
  String get searchIncome => 'Search source or note';

  @override
  String get wishlistEmptyTitle => 'Wishlist is empty';

  @override
  String get wishlistEmptySubtitle => 'Save things you plan to buy later.';

  @override
  String get savingsWithdrawalNote => 'Savings withdrawal';

  @override
  String get monthlySavingsTitle => 'Monthly savings';

  @override
  String get quickIncomeTitle => 'Quick income';

  @override
  String get maxQuickActionsNote => 'Max 6 actions';

  @override
  String get quickActionsLimitReached =>
      'You can only add up to 6 quick actions.';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingNoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get greetingNight => 'Good night,';

  @override
  String get dailyVibeLeadIn => 'Today\'s money vibe:';

  @override
  String get currentlySaved => 'Currently saved';

  @override
  String get mustBeNumber => 'Must be a number';

  @override
  String get deposit => 'Add';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get addSavingsTitle => 'Add savings';

  @override
  String get withdrawSavingsTitle => 'Withdraw savings';

  @override
  String get dateLabel => 'Date';

  @override
  String get amountLabel => 'Amount';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceDescribeLabel => 'Describe source';

  @override
  String get sourceRequired => 'Enter a source';

  @override
  String get categoryDescribeLabel => 'Describe category';

  @override
  String get categoryRequired => 'Enter a category';

  @override
  String dateFilterDateLabel(Object date) {
    return 'Date: $date';
  }

  @override
  String dateFilterRangeLabel(Object start, Object end) {
    return 'Range: $start - $end';
  }

  @override
  String get pickOneDate => 'Pick one date';

  @override
  String get pickDateRange => 'Pick date range';

  @override
  String get clearDateFilter => 'Clear date filter';

  @override
  String get dateFilter => 'Filter by date';

  @override
  String get reset => 'Clear';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String deleteSelectedExpensesConfirm(Object count) {
    return 'Delete $count selected expenses?';
  }

  @override
  String deleteSelectedExpensesDone(Object count) {
    return '$count expenses deleted';
  }

  @override
  String get noExpensesInDateFilter => 'No expenses in this date filter';

  @override
  String deleteSelectedIncomesConfirm(Object count) {
    return 'Delete $count selected incomes?';
  }

  @override
  String deleteSelectedIncomesDone(Object count) {
    return '$count incomes deleted';
  }

  @override
  String get noIncomesInDateFilter => 'No incomes in this date filter';

  @override
  String get wishlistAddItem => 'Add wishlist item';

  @override
  String get wishlistEditItem => 'Edit item';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get estimatedPrice => 'Estimated price';

  @override
  String get alreadySavedOptional => 'Already saved (optional)';

  @override
  String get validAmount => 'Enter a valid amount';

  @override
  String get ecommerceLinkOptional => 'E-commerce link (optional)';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Med';

  @override
  String get priorityHigh => 'High';

  @override
  String get deleteWishlistItemTitle => 'Delete item?';

  @override
  String deleteWishlistItemBody(Object name) {
    return 'Remove \"$name\" from the wishlist?';
  }

  @override
  String get markPurchasedTitle => 'Mark as purchased';

  @override
  String get markPurchasedBody =>
      'Also log this as an expense? You can set amount and category next.';

  @override
  String get markOnly => 'No, just mark';

  @override
  String get addExpense => 'Add expense';

  @override
  String get expenseDetails => 'Expense details';

  @override
  String get confirm => 'Confirm';

  @override
  String get fundsReady => 'Funds are ready! ';

  @override
  String get overTenYears => '>10 years away ';

  @override
  String achievableBy(Object month, Object year) {
    return 'Achievable by $month $year';
  }

  @override
  String savedAmountLabel(Object amount) {
    return '$amount saved';
  }

  @override
  String get buyLink => 'Buy / Link';

  @override
  String get wishlistExpenseNotePrefix => 'Wishlist';

  @override
  String get backupDialogTitle => 'Save database backup';

  @override
  String get backupExportSuccess => 'Database backup saved successfully.';

  @override
  String backupExportFailed(Object error) {
    return 'Failed to export database: $error';
  }

  @override
  String get autoBackupOffEnabled => 'Auto backup is off.';

  @override
  String get autoBackupDailyEnabled => 'Daily auto backup is on.';

  @override
  String get autoBackupWeeklyEnabled => 'Weekly auto backup is on.';

  @override
  String autoBackupSaveFailed(Object error) {
    return 'Failed to save auto backup setting: $error';
  }

  @override
  String autoBackupCreated(Object path) {
    return 'Auto backup created: $path';
  }

  @override
  String autoBackupCreateFailed(Object error) {
    return 'Failed to create auto backup: $error';
  }

  @override
  String get importDatabaseTitle => 'Import database?';

  @override
  String get importDatabaseBody =>
      'Current data will be replaced by backup data. Continue?';

  @override
  String get importSuccess => 'Import successful. Data has been restored.';

  @override
  String importFailed(Object error) {
    return 'Failed to import database: $error';
  }

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get backupRestoreSubtitle =>
      'Export your database to move it to another device. Import to restore all data.';

  @override
  String get exportDatabase => 'Export Database (.db)';

  @override
  String get importDatabase => 'Import Database (.db)';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String get off => 'Off';

  @override
  String get weekly => 'Weekly';

  @override
  String get runAutoBackupNow => 'Create Auto Backup Now';

  @override
  String get autoBackupHint =>
      'Auto backup files are saved in the app internal folder (Documents/backups).';

  @override
  String appVersion(Object version) {
    return 'App version: $version';
  }

  @override
  String get notificationTest => 'Notification test';

  @override
  String get notificationTestSubtitle =>
      'Tap the buttons below to preview notifications sent to your phone.';

  @override
  String get madeBy => 'Anti Boncos · made by Vion 🐺';

  @override
  String get notifNoonLabel => 'Noon (12:30)';

  @override
  String get notifNoonLateLabel => 'Still noon (13:45)';

  @override
  String get notifNightLabel => 'Night (20:00)';

  @override
  String get notifLateNightLabel => 'Too late (21:30)';

  @override
  String get notifIdleLabel => 'Idle (no transaction)';

  @override
  String get notifTitleNoon => 'Anti Boncos · noon';

  @override
  String get notifTitleNoonLate => 'Anti Boncos · still noon';

  @override
  String get notifTitleNight => 'Anti Boncos · night';

  @override
  String get notifTitleLateNight => 'Anti Boncos · too late';

  @override
  String get send => 'Send';
}
