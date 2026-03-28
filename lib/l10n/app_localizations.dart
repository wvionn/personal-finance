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
  /// **'Catat Uang'**
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
  /// **'Today\'s vibe'**
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

  /// No description provided for @wishlistPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get wishlistPlanned;

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

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

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
