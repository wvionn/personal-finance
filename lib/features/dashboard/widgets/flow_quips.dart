import 'dart:math';

/// Snack copy for the dashboard flow card (casual / cheeky — Indonesian first).
final class FlowQuips {
  FlowQuips._();

  static final _rng = Random();

  static const _expenseId = <String>[
    'Uwaw juga ya hari ini pengeluarannya.',
    'Dicatat. Semoga makannya enak, dompetnya ikut sabar ya.',
    'Minus buat Makan. Wajar lah... kan?',
    'Tercatat. Perut happy, saldo ikut kepo.',
    'Siap. Komite perut menang ronde ini.',
  ];

  static const _incomeId = <String>[
    'Mantap, ada yang masuk.',
    'Nais, saldo ikut senyum dikit.',
    'Widih, nambah. Gitu dong.',
    'Alhamdulillah, ada tambahan halus.',
  ];

  static const _expenseEn = <String>[
    'Logged. Hope the meal was worth the wallet wince.',
    'There it goes. Stomach committee: 1 — spreadsheet: 0.',
    'Recorded. Treat yourself energy, I guess.',
  ];

  static const _incomeEn = <String>[
    'Nice — something actually landed.',
    'Logged. The balance will take it.',
    'In it goes. Rare win for the number at the top.',
  ];

  static String afterExpense(String languageCode) {
    final list = languageCode == 'id' ? _expenseId : _expenseEn;
    return list[_rng.nextInt(list.length)];
  }

  static String afterIncome(String languageCode) {
    final list = languageCode == 'id' ? _incomeId : _incomeEn;
    return list[_rng.nextInt(list.length)];
  }
}
