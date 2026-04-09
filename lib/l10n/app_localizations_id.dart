// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Anti Boncos';

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
  String get dailyStatus => 'Belum ada data';

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
  String get smartQuickAdd => 'Satu ketuk';

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

  @override
  String get savingsWithdrawalNote => 'Tarik tabungan';

  @override
  String get monthlySavingsTitle => 'Tabungan bulanan';

  @override
  String get quickIncomeTitle => 'Pemasukan cepat';

  @override
  String get maxQuickActionsNote => 'Maks 6 aksi';

  @override
  String get quickActionsLimitReached =>
      'Kamu hanya bisa menambahkan sampai 6 aksi cepat.';

  @override
  String get greetingMorning => 'Selamat pagi,';

  @override
  String get greetingNoon => 'Selamat siang,';

  @override
  String get greetingEvening => 'Selamat sore,';

  @override
  String get greetingNight => 'Selamat malam,';

  @override
  String get dailyVibeLeadIn => 'Vibe keuangan hari ini:';

  @override
  String get currentlySaved => 'Terkumpul saat ini';

  @override
  String get mustBeNumber => 'Harus berupa angka';

  @override
  String get deposit => 'Setor';

  @override
  String get withdraw => 'Tarik';

  @override
  String get addSavingsTitle => 'Setor tabungan';

  @override
  String get withdrawSavingsTitle => 'Tarik tabungan';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get amountLabel => 'Nominal';

  @override
  String get noteOptionalLabel => 'Catatan (opsional)';

  @override
  String get sourceLabel => 'Sumber';

  @override
  String get sourceDescribeLabel => 'Jelaskan sumber';

  @override
  String get sourceRequired => 'Isi sumber pemasukan';

  @override
  String get categoryDescribeLabel => 'Jelaskan kategori';

  @override
  String get categoryRequired => 'Isi kategori';

  @override
  String dateFilterDateLabel(Object date) {
    return 'Tanggal: $date';
  }

  @override
  String dateFilterRangeLabel(Object start, Object end) {
    return 'Rentang: $start - $end';
  }

  @override
  String get pickOneDate => 'Pilih satu tanggal';

  @override
  String get pickDateRange => 'Pilih rentang tanggal';

  @override
  String get clearDateFilter => 'Reset filter tanggal';

  @override
  String get dateFilter => 'Filter tanggal';

  @override
  String get reset => 'Reset';

  @override
  String selectedCount(Object count) {
    return '$count dipilih';
  }

  @override
  String deleteSelectedExpensesConfirm(Object count) {
    return 'Hapus $count pengeluaran terpilih?';
  }

  @override
  String deleteSelectedExpensesDone(Object count) {
    return '$count pengeluaran dihapus';
  }

  @override
  String get noExpensesInDateFilter => 'Tidak ada pengeluaran pada tanggal ini';

  @override
  String deleteSelectedIncomesConfirm(Object count) {
    return 'Hapus $count pemasukan terpilih?';
  }

  @override
  String deleteSelectedIncomesDone(Object count) {
    return '$count pemasukan dihapus';
  }

  @override
  String get noIncomesInDateFilter => 'Tidak ada pemasukan pada tanggal ini';

  @override
  String get wishlistAddItem => 'Tambah item wishlist';

  @override
  String get wishlistEditItem => 'Ubah item';

  @override
  String get nameLabel => 'Nama';

  @override
  String get nameRequired => 'Isi nama';

  @override
  String get estimatedPrice => 'Perkiraan harga';

  @override
  String get alreadySavedOptional => 'Sudah terkumpul (opsional)';

  @override
  String get validAmount => 'Masukkan nominal yang valid';

  @override
  String get ecommerceLinkOptional => 'Link e-commerce (opsional)';

  @override
  String get priority => 'Prioritas';

  @override
  String get priorityLow => 'Rendah';

  @override
  String get priorityMedium => 'Sedang';

  @override
  String get priorityHigh => 'Tinggi';

  @override
  String get deleteWishlistItemTitle => 'Hapus item?';

  @override
  String deleteWishlistItemBody(Object name) {
    return 'Hapus \"$name\" dari wishlist?';
  }

  @override
  String get markPurchasedTitle => 'Tandai sudah dibeli';

  @override
  String get markPurchasedBody =>
      'Apakah kamu ingin mencatat ini ke pengeluaran bulan ini?';

  @override
  String get markOnly => 'Tidak, tandai saja';

  @override
  String get addExpense => 'Catat pengeluaran';

  @override
  String get expenseDetails => 'Detail pengeluaran';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get fundsReady => 'Dana sudah terkumpul! ';

  @override
  String get overTenYears => '>10 tahun lagi ';

  @override
  String achievableBy(Object month, Object year) {
    return 'Kebeli di $month $year';
  }

  @override
  String savedAmountLabel(Object amount) {
    return '$amount terkumpul';
  }

  @override
  String get buyLink => 'Beli / Link';

  @override
  String get wishlistExpenseNotePrefix => 'Wishlist';

  @override
  String get backupDialogTitle => 'Simpan backup database';

  @override
  String get backupExportSuccess => 'Backup database berhasil disimpan.';

  @override
  String backupExportFailed(Object error) {
    return 'Gagal export database: $error';
  }

  @override
  String get autoBackupOffEnabled => 'Backup otomatis dimatikan.';

  @override
  String get autoBackupDailyEnabled => 'Backup otomatis harian aktif.';

  @override
  String get autoBackupWeeklyEnabled => 'Backup otomatis mingguan aktif.';

  @override
  String autoBackupSaveFailed(Object error) {
    return 'Gagal simpan pengaturan backup otomatis: $error';
  }

  @override
  String autoBackupCreated(Object path) {
    return 'Backup otomatis dibuat: $path';
  }

  @override
  String autoBackupCreateFailed(Object error) {
    return 'Gagal membuat backup otomatis: $error';
  }

  @override
  String get importDatabaseTitle => 'Import database?';

  @override
  String get importDatabaseBody =>
      'Data sekarang akan diganti dengan isi file backup. Lanjut?';

  @override
  String get importSuccess => 'Import berhasil. Data sudah dipulihkan.';

  @override
  String importFailed(Object error) {
    return 'Gagal import database: $error';
  }

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get backupRestoreSubtitle =>
      'Export database agar bisa dipindah ke HP lain. Import untuk balikin semua data.';

  @override
  String get exportDatabase => 'Export Database (.db)';

  @override
  String get importDatabase => 'Import Database (.db)';

  @override
  String get autoBackup => 'Backup otomatis';

  @override
  String get off => 'Off';

  @override
  String get weekly => 'Mingguan';

  @override
  String get runAutoBackupNow => 'Buat Backup Otomatis Sekarang';

  @override
  String get autoBackupHint =>
      'File backup otomatis disimpan ke folder internal aplikasi (Documents/backups).';

  @override
  String appVersion(Object version) {
    return 'Versi aplikasi: $version';
  }

  @override
  String get notificationTest => 'Test notifikasi';

  @override
  String get notificationTestSubtitle =>
      'Tap tombol di bawah untuk preview notifikasi yang akan dikirim ke HP kamu.';

  @override
  String get madeBy => 'Anti Boncos · dibuat oleh Vion 🐺';

  @override
  String get notifNoonLabel => 'Siang (12:30)';

  @override
  String get notifNoonLateLabel => 'Masih siang (13:45)';

  @override
  String get notifNightLabel => 'Malam (20:00)';

  @override
  String get notifLateNightLabel => 'Bablas (21:30)';

  @override
  String get notifIdleLabel => 'Idle (tidak ada transaksi)';

  @override
  String get notifTitleNoon => 'Anti Boncos · siang';

  @override
  String get notifTitleNoonLate => 'Anti Boncos · masih siang';

  @override
  String get notifTitleNight => 'Anti Boncos · malam';

  @override
  String get notifTitleLateNight => 'Anti Boncos · bablas';

  @override
  String get send => 'Kirim';
}
