enum QuickActionType { income, expense }

class QuickAction {
  const QuickAction({
    required this.id,
    required this.type,
    required this.label,
    required this.emoji,
    required this.amount,
    this.category,
    this.source,
    this.useCount = 0,
    this.sortOrder = 0,
  });

  final String id;
  final QuickActionType type;
  final String label;
  final String emoji;
  final double amount;
  final String? category;
  final String? source;
  final int useCount;
  final int sortOrder;

  QuickAction copyWith({
    String? id,
    QuickActionType? type,
    String? label,
    String? emoji,
    double? amount,
    String? category,
    String? source,
    int? useCount,
    int? sortOrder,
  }) {
    return QuickAction(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      source: source ?? this.source,
      useCount: useCount ?? this.useCount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
