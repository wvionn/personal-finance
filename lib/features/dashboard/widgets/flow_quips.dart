import 'dart:math';

/// Snack copy for the dashboard flow card (casual / cheeky — Indonesian first).
final class FlowQuips {
  FlowQuips._();

  static final _rng = Random();

  static const _expenseId = <String>[
    'Uwaw juga ya hari ini pengeluarannya.',
    'Dicatat. Dompet agak ngelirik, tapi aman.',
    'Minus dikit, hidup tetap lanjut.',
    'Tercatat. Santai, yang penting ke-track.',
    'Siap. Pengeluaran masuk list.',
  ];

  static const _expenseFuelId = <String>[
    'Bensin dicatat. Gas jalan terus.',
    'Isi bensin ke-log. Mobil/motor aman.',
    'Bahan bakar masuk catatan. Lanjut jalan.',
  ];

  static const _expenseTransportId = <String>[
    'Transport dicatat. Mobilitas aman.',
    'Biaya jalan hari ini sudah masuk.',
    'Perjalanan ke-log. Mantap rapi.',
  ];

  static const _expenseShoppingId = <String>[
    'Belanja masuk catatan. Tetap chill.',
    'Keranjang aman, tracking juga aman.',
    'Belanja tercatat. Keuangan tetap terarah.',
  ];

  static const _incomeId = <String>[
    'Mantap, ada yang masuk.',
    'Nais, saldo ikut senyum dikit.',
    'Widih, nambah. Gitu dong.',
    'Alhamdulillah, ada tambahan halus.',
  ];

  static const _expenseEn = <String>[
    'Logged. Wallet noticed, but still under control.',
    'Recorded. Small spend, still chill.',
    'Saved. At least your tracking is clean.',
  ];

  static const _expenseFuelEn = <String>[
    'Fuel logged. Ready to roll.',
    'Gas spend recorded. Commute secured.',
    'Fuel cost saved. Keep going.',
  ];

  static const _expenseTransportEn = <String>[
    'Transport logged. Smooth move.',
    'Ride cost recorded. Nice and tidy.',
    'Travel spend saved.',
  ];

  static const _expenseShoppingEn = <String>[
    'Shopping logged. Balance still watched.',
    'Purchase recorded. Clean tracking.',
    'Saved. Retail therapy, but structured.',
  ];

  static const _expenseOverspendId = <String>[
    'Eh eh, ini pemasukan minus pengeluaran jebol, kamu boros lagi apa gimana ini?',
    'Saldo menjerit. Ngirit woi!',
    'Makin minus aja nih. Ingat, jajan pakai uang, bukan pakai doa.',
    'Dicatat, tapi awas dompet udah nangis darah.',
    'Overbudget alert. Gaya elit, saldo sulit.',
  ];

  static const _expenseOverspendEn = <String>[
    'Wait, expenses exceeded income? Your wallet is crying.',
    'Balance dropped below zero. Time to eat ice cubes.',
    'Logged. But seriously, stop spending.',
    'Overspending detected. Be better tomorrow.',
    'Minus balance? Bold strategy, let\'s see if it pays off.',
  ];

  static const _incomeEn = <String>[
    'Nice — something actually landed.',
    'Logged. The balance will take it.',
    'In it goes. Rare win for the number at the top.',
  ];

  static String afterExpense(String languageCode, {String? category, bool isOverspending = false}) {
    final isId = languageCode == 'id';
    
    if (isOverspending) {
      final list = isId ? _expenseOverspendId : _expenseOverspendEn;
      return list[_rng.nextInt(list.length)];
    }

    final key = (category ?? '').toLowerCase();

    late final List<String> list;
    if (key.contains('bahan bakar') || key.contains('bensin')) {
      list = isId ? _expenseFuelId : _expenseFuelEn;
    } else if (key.contains('transport')) {
      list = isId ? _expenseTransportId : _expenseTransportEn;
    } else if (key.contains('belanja')) {
      list = isId ? _expenseShoppingId : _expenseShoppingEn;
    } else {
      list = isId ? _expenseId : _expenseEn;
    }

    return list[_rng.nextInt(list.length)];
  }

  static String afterIncome(String languageCode) {
    final list = languageCode == 'id' ? _incomeId : _incomeEn;
    return list[_rng.nextInt(list.length)];
  }
}
