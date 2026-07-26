import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
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
      _showWishlistLimitDialog(context);
    }
  }

  void _showWishlistLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: dialogContext.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded,
                  color: dialogContext.colors.primary, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is full',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: dialogContext.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You can save up to 5 books at a time. Remove one from your wishlist to add something new.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: dialogContext.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ApiEndpoints.bookImageUrl(book.image);
    final isWishlisted = book.id != null &&
        ref.watch(wishlistViewModelProvider).isWishlisted(book.id!);
    final isSold = book.status == 'Sold';

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
                    child: Opacity(
                      opacity: isSold ? 0.5 : 1.0,
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
                  // ── Condition badge OR Sold badge ──────
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSold
                            ? Colors.black87
                            : conditionColor(context, book.condition),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSold ? 'Sold' : book.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // ── Wishlist heart (hidden once sold) ──
                  if (!isSold)
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
                      color: isSold ? context.textTertiary : context.textPrimary,
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
                      color: isSold ? context.textTertiary : context.colors.primary,
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