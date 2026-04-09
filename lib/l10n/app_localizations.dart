import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @balanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All-time in − out'**
  String get balanceSubtitle;

  /// No description provided for @periodIncome.
  ///
  /// In en, this message translates to:
  /// **'In (period)'**
  String get periodIncome;

  /// No description provided for @periodExpense.
  ///
  /// In en, this message translates to:
  /// **'Out (period)'**
  String get periodExpense;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @trendIncome.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get trendIncome;

  /// No description provided for @trendExpense.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get trendExpense;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @savingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get savingsGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @validatorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get validatorTitleRequired;

  /// No description provided for @validatorAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get validatorAmountPositive;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @quickAddIncome10.
  ///
  /// In en, this message translates to:
  /// **'+10 rb'**
  String get quickAddIncome10;

  /// No description provided for @quickAddIncome20.
  ///
  /// In en, this message translates to:
  /// **'+20 rb'**
  String get quickAddIncome20;

  /// No description provided for @quickAddExpense10.
  ///
  /// In en, this message translates to:
  /// **'−10 rb'**
  String get quickAddExpense10;

  /// No description provided for @dailyStatus.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get dailyStatus;

  /// No description provided for @statusHemat.
  ///
  /// In en, this message translates to:
  /// **'Hemat'**
  String get statusHemat;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusBoros.
  ///
  /// In en, this message translates to:
  /// **'Boros'**
  String get statusBoros;

  /// No description provided for @statusHematHint.
  ///
  /// In en, this message translates to:
  /// **'Spending lighter than your month average.'**
  String get statusHematHint;

  /// No description provided for @statusNormalHint.
  ///
  /// In en, this message translates to:
  /// **'Right around your usual pace.'**
  String get statusNormalHint;

  /// No description provided for @statusBorosHint.
  ///
  /// In en, this message translates to:
  /// **'Above your month average — pace yourself.'**
  String get statusBorosHint;

  /// No description provided for @statusNoData.
  ///
  /// In en, this message translates to:
  /// **'Log a few expenses this month to unlock status.'**
  String get statusNoData;

  /// No description provided for @smartQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'One tap'**
  String get smartQuickAdd;

  /// No description provided for @customizeQuick.
  ///
  /// In en, this message translates to:
  /// **'Edit buttons'**
  String get customizeQuick;

  /// No description provided for @aiInput.
  ///
  /// In en, this message translates to:
  /// **'Type to log (smart)'**
  String get aiInput;

  /// No description provided for @aiHint.
  ///
  /// In en, this message translates to:
  /// **'Example: makan 25rb, kopi 15k'**
  String get aiHint;

  /// No description provided for @searchExpense.
  ///
  /// In en, this message translates to:
  /// **'Search category or note'**
  String get searchExpense;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get monthlyReport;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @noChartData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noChartData;

  /// No description provided for @wishlistPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get wishlistPurchased;

  /// No description provided for @addQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Add quick button'**
  String get addQuickTitle;

  /// No description provided for @editQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit quick button'**
  String get editQuickTitle;

  /// No description provided for @labelField.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelField;

  /// No description provided for @amountField.
  ///
  /// In en, this message translates to:
  /// **'Amount (Rp)'**
  String get amountField;

  /// No description provided for @categoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryField;

  /// No description provided for @emojiField.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emojiField;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @incomeSourceQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get incomeSourceQuick;

  /// No description provided for @noteQuickDash.
  ///
  /// In en, this message translates to:
  /// **'Dashboard quick'**
  String get noteQuickDash;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @todaySpend.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaySpend;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get expenseTitle;

  /// No description provided for @aiParseError.
  ///
  /// In en, this message translates to:
  /// **'Could not parse. Try: food 25k'**
  String get aiParseError;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @noSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noSearchMatches;

  /// No description provided for @tapToLog.
  ///
  /// In en, this message translates to:
  /// **'Use quick buttons or + to add.'**
  String get tapToLog;

  /// No description provided for @reportEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get reportEmptyMonth;

  /// No description provided for @percentOfSpend.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of spend'**
  String percentOfSpend(Object pct);

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @noIncomeYet.
  ///
  /// In en, this message translates to:
  /// **'No income yet'**
  String get noIncomeYet;

  /// No description provided for @noIncomeMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noIncomeMatches;

  /// No description provided for @tapToAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add income.'**
  String get tapToAddIncome;

  /// No description provided for @searchIncome.
  ///
  /// In en, this message translates to:
  /// **'Search source or note'**
  String get searchIncome;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist is empty'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save things you plan to buy later.'**
  String get wishlistEmptySubtitle;

  /// No description provided for @savingsWithdrawalNote.
  ///
  /// In en, this message translates to:
  /// **'Savings withdrawal'**
  String get savingsWithdrawalNote;

  /// No description provided for @monthlySavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly savings'**
  String get monthlySavingsTitle;

  /// No description provided for @quickIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick income'**
  String get quickIncomeTitle;

  /// No description provided for @maxQuickActionsNote.
  ///
  /// In en, this message translates to:
  /// **'Max 6 actions'**
  String get maxQuickActionsNote;

  /// No description provided for @quickActionsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can only add up to 6 quick actions.'**
  String get quickActionsLimitReached;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingNoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetingNoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night,'**
  String get greetingNight;

  /// No description provided for @dailyVibeLeadIn.
  ///
  /// In en, this message translates to:
  /// **'Today\'s money vibe:'**
  String get dailyVibeLeadIn;

  /// No description provided for @currentlySaved.
  ///
  /// In en, this message translates to:
  /// **'Currently saved'**
  String get currentlySaved;

  /// No description provided for @mustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a number'**
  String get mustBeNumber;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @addSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add savings'**
  String get addSavingsTitle;

  /// No description provided for @withdrawSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw savings'**
  String get withdrawSavingsTitle;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @sourceDescribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe source'**
  String get sourceDescribeLabel;

  /// No description provided for @sourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a source'**
  String get sourceRequired;

  /// No description provided for @categoryDescribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe category'**
  String get categoryDescribeLabel;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a category'**
  String get categoryRequired;

  /// No description provided for @dateFilterDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateFilterDateLabel(Object date);

  /// No description provided for @dateFilterRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range: {start} - {end}'**
  String dateFilterRangeLabel(Object start, Object end);

  /// No description provided for @pickOneDate.
  ///
  /// In en, this message translates to:
  /// **'Pick one date'**
  String get pickOneDate;

  /// No description provided for @pickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Pick date range'**
  String get pickDateRange;

  /// No description provided for @clearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilter;

  /// No description provided for @dateFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get dateFilter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get reset;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(Object count);

  /// No description provided for @deleteSelectedExpensesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected expenses?'**
  String deleteSelectedExpensesConfirm(Object count);

  /// No description provided for @deleteSelectedExpensesDone.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses deleted'**
  String deleteSelectedExpensesDone(Object count);

  /// No description provided for @noExpensesInDateFilter.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this date filter'**
  String get noExpensesInDateFilter;

  /// No description provided for @deleteSelectedIncomesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected incomes?'**
  String deleteSelectedIncomesConfirm(Object count);

  /// No description provided for @deleteSelectedIncomesDone.
  ///
  /// In en, this message translates to:
  /// **'{count} incomes deleted'**
  String deleteSelectedIncomesDone(Object count);

  /// No description provided for @noIncomesInDateFilter.
  ///
  /// In en, this message translates to:
  /// **'No incomes in this date filter'**
  String get noIncomesInDateFilter;

  /// No description provided for @wishlistAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add wishlist item'**
  String get wishlistAddItem;

  /// No description provided for @wishlistEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get wishlistEditItem;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @estimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price'**
  String get estimatedPrice;

  /// No description provided for @alreadySavedOptional.
  ///
  /// In en, this message translates to:
  /// **'Already saved (optional)'**
  String get alreadySavedOptional;

  /// No description provided for @validAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get validAmount;

  /// No description provided for @ecommerceLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'E-commerce link (optional)'**
  String get ecommerceLinkOptional;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @deleteWishlistItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteWishlistItemTitle;

  /// No description provided for @deleteWishlistItemBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the wishlist?'**
  String deleteWishlistItemBody(Object name);

  /// No description provided for @markPurchasedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as purchased'**
  String get markPurchasedTitle;

  /// No description provided for @markPurchasedBody.
  ///
  /// In en, this message translates to:
  /// **'Also log this as an expense? You can set amount and category next.'**
  String get markPurchasedBody;

  /// No description provided for @markOnly.
  ///
  /// In en, this message translates to:
  /// **'No, just mark'**
  String get markOnly;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense details'**
  String get expenseDetails;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @fundsReady.
  ///
  /// In en, this message translates to:
  /// **'Funds are ready! '**
  String get fundsReady;

  /// No description provided for @overTenYears.
  ///
  /// In en, this message translates to:
  /// **'>10 years away '**
  String get overTenYears;

  /// No description provided for @achievableBy.
  ///
  /// In en, this message translates to:
  /// **'Achievable by {month} {year}'**
  String achievableBy(Object month, Object year);

  /// No description provided for @savedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String savedAmountLabel(Object amount);

  /// No description provided for @buyLink.
  ///
  /// In en, this message translates to:
  /// **'Buy / Link'**
  String get buyLink;

  /// No description provided for @wishlistExpenseNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistExpenseNotePrefix;

  /// No description provided for @backupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save database backup'**
  String get backupDialogTitle;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database backup saved successfully.'**
  String get backupExportSuccess;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export database: {error}'**
  String backupExportFailed(Object error);

  /// No description provided for @autoBackupOffEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto backup is off.'**
  String get autoBackupOffEnabled;

  /// No description provided for @autoBackupDailyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily auto backup is on.'**
  String get autoBackupDailyEnabled;

  /// No description provided for @autoBackupWeeklyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Weekly auto backup is on.'**
  String get autoBackupWeeklyEnabled;

  /// No description provided for @autoBackupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save auto backup setting: {error}'**
  String autoBackupSaveFailed(Object error);

  /// No description provided for @autoBackupCreated.
  ///
  /// In en, this message translates to:
  /// **'Auto backup created: {path}'**
  String autoBackupCreated(Object path);

  /// No description provided for @autoBackupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create auto backup: {error}'**
  String autoBackupCreateFailed(Object error);

  /// No description provided for @importDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Import database?'**
  String get importDatabaseTitle;

  /// No description provided for @importDatabaseBody.
  ///
  /// In en, this message translates to:
  /// **'Current data will be replaced by backup data. Continue?'**
  String get importDatabaseBody;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful. Data has been restored.'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import database: {error}'**
  String importFailed(Object error);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your database to move it to another device. Import to restore all data.'**
  String get backupRestoreSubtitle;

  /// No description provided for @exportDatabase.
  ///
  /// In en, this message translates to:
  /// **'Export Database (.db)'**
  String get exportDatabase;

  /// No description provided for @importDatabase.
  ///
  /// In en, this message translates to:
  /// **'Import Database (.db)'**
  String get importDatabase;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get autoBackup;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @runAutoBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Create Auto Backup Now'**
  String get runAutoBackupNow;

  /// No description provided for @autoBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Auto backup files are saved in the app internal folder (Documents/backups).'**
  String get autoBackupHint;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version: {version}'**
  String appVersion(Object version);

  /// No description provided for @notificationTest.
  ///
  /// In en, this message translates to:
  /// **'Notification test'**
  String get notificationTest;

  /// No description provided for @notificationTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the buttons below to preview notifications sent to your phone.'**
  String get notificationTestSubtitle;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos · made by Vion 🐺'**
  String get madeBy;

  /// No description provided for @notifNoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Noon (12:30)'**
  String get notifNoonLabel;

  /// No description provided for @notifNoonLateLabel.
  ///
  /// In en, this message translates to:
  /// **'Still noon (13:45)'**
  String get notifNoonLateLabel;

  /// No description provided for @notifNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Night (20:00)'**
  String get notifNightLabel;

  /// No description provided for @notifLateNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Too late (21:30)'**
  String get notifLateNightLabel;

  /// No description provided for @notifIdleLabel.
  ///
  /// In en, this message translates to:
  /// **'Idle (no transaction)'**
  String get notifIdleLabel;

  /// No description provided for @notifTitleNoon.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos · noon'**
  String get notifTitleNoon;

  /// No description provided for @notifTitleNoonLate.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos · still noon'**
  String get notifTitleNoonLate;

  /// No description provided for @notifTitleNight.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos · night'**
  String get notifTitleNight;

  /// No description provided for @notifTitleLateNight.
  ///
  /// In en, this message translates to:
  /// **'Anti Boncos · too late'**
  String get notifTitleLateNight;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
