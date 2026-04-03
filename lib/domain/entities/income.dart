class Income {
  const Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.accountType = 'cash',
    this.note,
  });

  final String id;
  final double amount;
  final String source;
  final DateTime date;
  final String accountType;
  final String? note;
}
