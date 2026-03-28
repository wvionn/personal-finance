import 'package:intl/intl.dart';

String formatMoney(double value, {required String languageCode}) {
  final useEn = languageCode == 'en';
  final f = NumberFormat.currency(
    locale: useEn ? 'en_US' : 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return f.format(value);
}

String formatShortDate(DateTime d, {required String languageCode}) {
  final loc = languageCode == 'en' ? 'en_US' : 'id_ID';
  return DateFormat.MMMd(loc).format(d);
}

String formatMonthYear(DateTime d, {required String languageCode}) {
  final loc = languageCode == 'en' ? 'en_US' : 'id_ID';
  return DateFormat.yMMM(loc).format(d);
}

/// Shorter label for chart axis (e.g. "3 Mar").
String formatChartDay(DateTime d, {required String languageCode}) {
  final loc = languageCode == 'en' ? 'en_US' : 'id_ID';
  return DateFormat.MMMd(loc).format(d);
}
