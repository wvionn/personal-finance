String expenseCategoryLabel(String raw, String languageCode) {
  final key = raw.trim().toLowerCase();
  if (languageCode == 'id') {
    return switch (key) {
      'food' => 'Makan',
      'fuel' => 'Bahan bakar',
      'drink' => 'Minuman',
      'transport' => 'Transport',
      'education' => 'Pendidikan',
      'entertainment' => 'Hiburan',
      'health' => 'Kesehatan',
      'shopping' => 'Belanja',
      'housing' => 'Tempat tinggal',
      'other' => 'Lainnya',
      _ => raw,
    };
  }

  return switch (key) {
    'makan' => 'Food',
    'bahan bakar' => 'Fuel',
    'minuman' => 'Drink',
    'transport' => 'Transport',
    'pendidikan' => 'Education',
    'hiburan' => 'Entertainment',
    'kesehatan' => 'Health',
    'belanja' => 'Shopping',
    'tempat tinggal' => 'Housing',
    'lainnya' => 'Other',
    _ => raw,
  };
}

String incomeSourceLabel(String raw, String languageCode) {
  final key = raw.trim().toLowerCase();
  if (languageCode == 'id') {
    return switch (key) {
      'allowance' => 'Uang saku',
      'freelance' => 'Freelance',
      'gift' => 'Hadiah',
      'part-time job' => 'Kerja paruh waktu',
      'scholarship' => 'Beasiswa',
      'other' => 'Lainnya',
      _ => raw,
    };
  }

  return switch (key) {
    'uang saku' => 'Allowance',
    'freelance' => 'Freelance',
    'hadiah' => 'Gift',
    'kerja paruh waktu' => 'Part-time job',
    'beasiswa' => 'Scholarship',
    'lainnya' => 'Other',
    _ => raw,
  };
}

String accountTypeLabel(String raw, String languageCode) {
  final key = raw.trim().toLowerCase();
  if (languageCode == 'id') {
    return switch (key) {
      'cash' => 'Tunai',
      'bank' => 'Bank',
      'all' => 'Semua',
      _ => raw,
    };
  }

  return switch (key) {
    'cash' => 'Cash',
    'bank' => 'Bank',
    'all' => 'All',
    _ => raw,
  };
}
