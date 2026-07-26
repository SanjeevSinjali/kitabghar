import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';

/// Shared book tile used by both the Explore and Home grids. Shows the
/// cover image, genre/condition badges, a working wishlist heart, and
/// opens [onTap] (typically a detail/buy sheet) when tapped.
class BookCard extends ConsumerWidget {
  final BooksEntity book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  static Color conditionColor(BuildContext context, String condition) {
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

  Future<void> _toggleWishlist(BuildContext context, WidgetRef ref) async {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token == null || token.isEmpty || book.id == null) return;

    final error = await ref.read(wishlistViewModelProvider.notifier).toggleWishlist(
          token: token,
          item: WishlistEntity(
            bookId: book.id!,
            title: book.title,
            author: book.author,
            price: book.price,
            image: book.image ?? '',
            condition: book.condition,
          ),
        );

    if (error != null && context.mounted) {
      // Most likely the backend's hard 5-item wishlist limit.
      SnackbarUtils.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ApiEndpoints.bookImageUrl(book.image);
    final isWishlisted = book.id != null &&
        ref.watch(wishlistViewModelProvider).isWishlisted(book.id!);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.isDarkMode
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ─────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(context),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null ? child : _placeholder(context),
                            )
                          : _placeholder(context),
                    ),
                  ),
                  // ── Genre badge ────────────────────────
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // ── Condition badge ────────────────────
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: conditionColor(context, book.condition),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // ── Wishlist heart ──────────────────────
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleWishlist(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWishlisted ? Colors.redAccent : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Title, author, price ──────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: context.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${book.price}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.isDarkMode
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFF0F0F0),
      child: Icon(Icons.menu_book_rounded, color: context.textTertiary, size: 36),
    );
  }
}