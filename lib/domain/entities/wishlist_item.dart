enum WishlistPriority { low, medium, high }

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.priority,
    this.targetAmount = 0.0,
    this.savedAmount = 0.0,
    this.itemUrl,
    this.purchased = false,
    this.purchasedAt,
  });

  final String id;
  final String name;
  final double estimatedPrice;
  final WishlistPriority priority;
  final double targetAmount;
  final double savedAmount;
  final String? itemUrl;
  final bool purchased;
  final DateTime? purchasedAt;

  WishlistItem copyWith({
    String? id,
    String? name,
    double? estimatedPrice,
    WishlistPriority? priority,
    double? targetAmount,
    double? savedAmount,
    String? itemUrl,
    bool? purchased,
    DateTime? purchasedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      priority: priority ?? this.priority,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      itemUrl: itemUrl ?? this.itemUrl,
      purchased: purchased ?? this.purchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
