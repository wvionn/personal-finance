// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Catat Uang';

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
  String get dailyStatus => 'Today\'s vibe';

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
  String get manualEntry => 'Manual entry';

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
}
