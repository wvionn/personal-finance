class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.accountType = 'cash',
    this.note,
  });

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String accountType;
  final String? note;
}
