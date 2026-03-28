import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../domain/entities/wishlist_item.dart';

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getWishlist(includePurchased: true);
});
