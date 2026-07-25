import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';
import 'package:kitabghar/features/dashboard/presentation/widgets/book_card.dart';
import 'package:kitabghar/features/dashboard/presentation/widgets/book_detail_sheet.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _query = '';
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Academic',
    'Self-Help',
    'Biography',
    "Children's",
    'Comics',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBooks());
  }

  void _loadBooks() {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token == null || token.isEmpty) return;
    ref.read(booksViewModelProvider.notifier).getAllBooks(token: token);
    // Also load wishlist so the heart icons reflect current state.
    ref.read(wishlistViewModelProvider.notifier).getWishlist(token: token);
  }

  List<BooksEntity> _filtered(List<BooksEntity> books) {
    return books.where((b) {
      // Already-sold books shouldn't be browsable/buyable anymore.
      final isActive = b.status == 'Active';
      final matchesCategory =
          _selectedCategory == 'All' || b.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          b.title.toLowerCase().contains(_query.toLowerCase()) ||
          b.author.toLowerCase().contains(_query.toLowerCase());
      return isActive && matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksViewModelProvider);
    final books = _filtered(booksState.books);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: context.isDarkMode
                      ? null
                      : [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(fontSize: 13, color: context.textPrimary),
                  cursorColor: context.colors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search books, authors…',
                    hintStyle:
                        TextStyle(fontSize: 13, color: context.textTertiary),
                    prefixIcon:
                        Icon(Icons.search, color: context.textTertiary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // ── Category filter chips ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final selected = _selectedCategory == _categories[i];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = _categories[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? context.colors.primary
                              : context.cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? context.colors.primary
                                : context.theme.dividerColor,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : context.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Content ────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: context.colors.primary,
                onRefresh: () async => _loadBooks(),
                child: _buildContent(booksState, books),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic booksState, List<BooksEntity> books) {
    if (booksState.isLoading && booksState.books.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (booksState.error != null && booksState.books.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('Could not load books',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    booksState.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textTertiary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (books.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 48, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('No books found',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (_, i) => BookCard(
        book: books[i],
        onTap: () => BookDetailSheet.show(
          context,
          ref,
          book: books[i],
          onBought: _loadBooks,
        ),
      ),
    );
  }
}