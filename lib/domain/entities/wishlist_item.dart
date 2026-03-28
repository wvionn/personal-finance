enum WishlistPriority { low, medium, high }

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.priority,
    this.purchased = false,
    this.purchasedAt,
  });

  final String id;
  final String name;
  final double estimatedPrice;
  final WishlistPriority priority;
  final bool purchased;
  final DateTime? purchasedAt;

  WishlistItem copyWith({
    String? id,
    String? name,
    double? estimatedPrice,
    WishlistPriority? priority,
    bool? purchased,
    DateTime? purchasedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      priority: priority ?? this.priority,
      purchased: purchased ?? this.purchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
