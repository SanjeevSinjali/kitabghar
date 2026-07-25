import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:kitabghar/features/wishlist/presentation/state/wishlist_state.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  ConsumerState<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends ConsumerState<WishListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token == null || token.isEmpty) return;
    ref.read(wishlistViewModelProvider.notifier).getWishlist(token: token);
  }

  Future<void> _remove(WishlistEntity item) async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token == null || token.isEmpty) return;
    await ref
        .read(wishlistViewModelProvider.notifier)
        .removeFromWishlist(token: token, bookId: item.bookId);
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text('Wishlist (${wishlistState.items.length}/5)'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async => _load(),
        child: _buildContent(wishlistState),
      ),
    );
  }

  Widget _buildContent(WishlistState state) {
    if (state.isLoading && state.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('Could not load your wishlist',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 56, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('Your wishlist is empty',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('Tap the heart on any book to save it here',
                    style: TextStyle(color: context.textTertiary, fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _WishlistTile(
        item: state.items[index],
        onRemove: () => _remove(state.items[index]),
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final WishlistEntity item;
  final VoidCallback onRemove;

  const _WishlistTile({required this.item, required this.onRemove});

  Color _conditionColor(BuildContext context, String condition) {
    switch (condition) {
      case 'Like New':
        return const Color(0xFF2ECC71);
      case 'Good':
        return const Color(0xFF3FA7D6);
      case 'Fair':
        return const Color(0xFFF5A623);
      default:
        return context.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.bookImageUrl(item.image);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 84,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs. ${item.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _conditionColor(context, item.condition),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite_rounded, color: context.colors.error),
            onPressed: onRemove,
            tooltip: 'Remove from wishlist',
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.isDarkMode
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFF0F0F0),
      child: Icon(Icons.menu_book_rounded, color: context.textTertiary, size: 24),
    );
  }
}