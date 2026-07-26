import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/widgets/book_card.dart';
import 'package:kitabghar/features/purchases/domain/entities/khalti_session.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/presentation/pages/khalti_checkout_page.dart';
import 'package:kitabghar/features/purchases/presentation/view_model/purchase_view_model.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';

/// Shared bottom sheet showing full book details with a working "Buy Now"
/// flow. Used from both Explore and Home so the buy/wishlist logic lives
/// in exactly one place.
class BookDetailSheet extends ConsumerStatefulWidget {
  final BooksEntity book;
  final bool isOwnListing;
  final VoidCallback onBought;

  const BookDetailSheet({
    super.key,
    required this.book,
    required this.isOwnListing,
    required this.onBought,
  });

  /// Convenience helper — figures out isOwnListing for you and opens the
  /// sheet, so callers don't have to repeat that logic.
  static void show(
    BuildContext context,
    WidgetRef ref, {
    required BooksEntity book,
    required VoidCallback onBought,
  }) {
    final currentUserId = ref.read(authViewModelProvider).user?.id;
    final isOwnListing =
        book.sellerId != null && book.sellerId == currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookDetailSheet(
        book: book,
        isOwnListing: isOwnListing,
        onBought: onBought,
      ),
    );
  }

  @override
  ConsumerState<BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends ConsumerState<BookDetailSheet> {
  bool _isBuying = false;

  Future<void> _buyNow() async {
    print('=== BUY NOW TAPPED (Khalti flow) ===');
    final book = widget.book;
    final authState = ref.read(authViewModelProvider).user;
    if (authState?.token == null || book.id == null) return;

    setState(() => _isBuying = true);

    final purchaseItem = PurchaseEntity(
      bookId: book.id!,
      title: book.title,
      author: book.author,
      price: book.price,
      image: book.image ?? '',
      condition: book.condition,
    );

    // ── Step 1: ask the backend to start a Khalti payment session ──
    print('=== STEP 1: calling initiateKhaltiPayment ===');
    final initiateResult = await ref
        .read(purchaseViewModelProvider.notifier)
        .initiateKhaltiPayment(token: authState!.token!, item: purchaseItem);

    KhaltiSession? session;
    String? initiateError;
    initiateResult.fold(
      (failure) => initiateError = failure.message,
      (s) => session = s,
    );
    print('=== STEP 1 RESULT: session=${session?.paymentUrl}, error=$initiateError ===');

    if (session == null) {
      if (!mounted) return;
      setState(() => _isBuying = false);
      SnackbarUtils.showError(context, initiateError ?? 'Could not start payment.');
      return;
    }

    if (!mounted) return;

    // ── Step 2: open Khalti's checkout page and wait for the result ──
    print('=== STEP 2: pushing KhaltiCheckoutPage ===');
    final status = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => KhaltiCheckoutPage(paymentUrl: session!.paymentUrl),
      ),
    );
    print('=== STEP 2 RESULT: status=$status ===');

    if (!mounted) return;

    if (status != 'Completed') {
      setState(() => _isBuying = false);
      SnackbarUtils.showError(
        context,
        status == 'Cancelled' || status == null
            ? 'Payment was cancelled.'
            : 'Payment was not completed (status: $status).',
      );
      return;
    }

    // ── Step 3: verify server-side and complete the purchase ──
    print('=== STEP 3: calling verifyKhaltiPayment ===');
    final error = await ref.read(purchaseViewModelProvider.notifier).verifyKhaltiPayment(
          token: authState.token!,
          pidx: session!.pidx,
          item: purchaseItem,
        );
    print('=== STEP 3 RESULT: error=$error ===');

    if (!mounted) return;
    setState(() => _isBuying = false);

    if (error != null) {
      SnackbarUtils.showError(context, error);
      return;
    }

    // Purchasing removes the book from wishlists server-side too — keep
    // local wishlist state in sync so the heart icon doesn't lie.
    ref.read(wishlistViewModelProvider.notifier).removeFromWishlist(
          token: authState.token!,
          bookId: book.id!,
        );

    if (authState.email.isNotEmpty) {
      ref.read(notificationsProvider.notifier).addNotification(
            authState.email,
            title: 'Purchase Successful',
            message: 'You bought "${book.title}" for Rs. ${book.price}.',
            type: 'order',
          );
    }

    Navigator.pop(context);
    SnackbarUtils.showSuccess(context, 'You bought "${book.title}"!');
    widget.onBought();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final imageUrl = ApiEndpoints.bookImageUrl(book.image);

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 120,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: context.isDarkMode
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF0F0F0),
                              child: Icon(Icons.menu_book_rounded,
                                  color: context.textTertiary),
                            ),
                          )
                        : Container(
                            color: context.isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F0F0),
                            child: Icon(Icons.menu_book_rounded,
                                color: context.textTertiary),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: TextStyle(
                            fontSize: 13, color: context.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: BookCard.conditionColor(context, book.condition),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.condition,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Rs. ${book.price}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (book.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: context.textTertiary)),
              const SizedBox(height: 6),
              Text(
                book.description,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
            ],
            if (book.sellerName != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.storefront_outlined,
                      size: 16, color: context.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Sold by ${book.sellerName}',
                    style: TextStyle(fontSize: 12, color: context.textTertiary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (widget.isOwnListing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'This is your own listing',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBuying ? null : _buyNow,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isBuying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Buy Now',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}