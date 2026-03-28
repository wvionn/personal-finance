// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Catat Uang';

  @override
  String get dashboard => 'Beranda';

  @override
  String get income => 'Pemasukan';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get balance => 'Saldo';

  @override
  String get balanceSubtitle => 'Total masuk − keluar';

  @override
  String get periodIncome => 'Masuk (periode)';

  @override
  String get periodExpense => 'Keluar (periode)';

  @override
  String get trend => 'Tren';

  @override
  String get trendIncome => 'Masuk';

  @override
  String get trendExpense => 'Keluar';

  @override
  String get monthly => 'Bulanan';

  @override
  String get daily => 'Harian';

  @override
  String get savingsGoal => 'Target tabungan';

  @override
  String get goalName => 'Nama target';

  @override
  String get validatorTitleRequired => 'Isi judul dulu';

  @override
  String get validatorAmountPositive => 'Nominal harus lebih dari 0';

  @override
  String get quickAdd => 'Tambah cepat';

  @override
  String get quickAddIncome10 => '+10 rb';

  @override
  String get quickAddIncome20 => '+20 rb';

  @override
  String get quickAddExpense10 => '−10 rb';

  @override
  String get dailyStatus => 'Status hari ini';

  @override
  String get statusHemat => 'Hemat';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusBoros => 'Boros';

  @override
  String get statusHematHint => 'Pengeluaran di bawah rata-rata bulan ini.';

  @override
  String get statusNormalHint => 'Sekitar pace biasamu.';

  @override
  String get statusBorosHint => 'Di atas rata-rata — perlambat sedikit.';

  @override
  String get statusNoData => 'Catat beberapa pengeluaran dulu untuk status.';

  @override
  String get smartQuickAdd => 'Satu ketukan';

  @override
  String get customizeQuick => 'Atur tombol';

  @override
  String get aiInput => 'Ketik cepat (pintar)';

  @override
  String get aiHint => 'Contoh: makan 25rb, kopi 15k';

  @override
  String get searchExpense => 'Cari kategori atau catatan';

  @override
  String get monthlyReport => 'Laporan bulanan';

  @override
  String get exportCsv => 'Ekspor CSV';

  @override
  String get noChartData => 'Belum ada data';

  @override
  String get wishlistPlanned => 'Direncanakan';

  @override
  String get wishlistPurchased => 'Dibeli';

  @override
  String get addQuickTitle => 'Tombol cepat baru';

  @override
  String get editQuickTitle => 'Edit tombol cepat';

  @override
  String get labelField => 'Nama';

  @override
  String get amountField => 'Nominal (Rp)';

  @override
  String get categoryField => 'Kategori';

  @override
  String get emojiField => 'Emoji';

  @override
  String get edit => 'Ubah';

  @override
  String get purchased => 'Dibeli';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get add => 'Tambah';

  @override
  String get incomeSourceQuick => 'Tambah cepat';

  @override
  String get noteQuickDash => 'Cepat beranda';

  @override
  String get recorded => 'Tercatat';

  @override
  String get todaySpend => 'Hari ini';

  @override
  String get expenseTitle => 'Pengeluaran';

  @override
  String get manualEntry => 'Input manual';

  @override
  String get aiParseError => 'Tidak dikenali. Contoh: makan 25rb';

  @override
  String get noExpensesYet => 'Belum ada pengeluaran';

  @override
  String get noSearchMatches => 'Tidak ada hasil';

  @override
  String get tapToLog => 'Pakai tombol cepat atau + untuk menambah.';

  @override
  String get reportEmptyMonth => 'Tidak ada pengeluaran bulan ini.';

  @override
  String percentOfSpend(Object pct) {
    return '$pct% dari pengeluaran';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get noIncomeYet => 'Belum ada pemasukan';

  @override
  String get noIncomeMatches => 'Tidak ada hasil';

  @override
  String get tapToAddIncome => 'Ketuk + untuk menambah pemasukan.';

  @override
  String get searchIncome => 'Cari sumber atau catatan';

  @override
  String get wishlistEmptyTitle => 'Wishlist kosong';

  @override
  String get wishlistEmptySubtitle => 'Simpan barang yang ingin dibeli nanti.';
}
