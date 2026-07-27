import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';
import 'package:kitabghar/features/books/presentation/widgets/book_card.dart';
import 'package:kitabghar/features/books/presentation/widgets/book_detail_sheet.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/sell_page.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';
  String _selectedCategory = 'All';

  static const _categories = [
    _Category('All', Icons.apps_rounded),
    _Category('Fiction', Icons.menu_book_rounded),
    _Category('Non-Fiction', Icons.public_rounded),
    _Category('Academic', Icons.school_rounded),
    _Category('Self-Help', Icons.self_improvement_rounded),
    _Category('Biography', Icons.person_rounded),
    _Category("Children's", Icons.child_care_rounded),
    _Category('Comics', Icons.brush_rounded),
    _Category('Other', Icons.category_rounded),
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
    ref.read(wishlistViewModelProvider.notifier).getWishlist(token: token);
  }

  List<BooksEntity> _filtered(List<BooksEntity> books) {
    return books.where((b) {
      final matchesCategory =
          _selectedCategory == 'All' || b.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          b.title.toLowerCase().contains(_query.toLowerCase()) ||
          b.author.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    final booksState = ref.watch(booksViewModelProvider);
    final books = _filtered(booksState.books);
    // "Trending" is a fixed, hand-picked set — always these exact books,
    // completely independent of the category filter chips above (unlike
    // "All Listings", which does respect the filter).
    const trendingTitles = {
      "You Don't Know JS Yet: Get Started",
      'Code Complete',
    };
    final trending = booksState.books
        .where((b) => trendingTitles.contains(b.title))
        .toList();

    return Scaffold(
      backgroundColor: context.backgroundColor,

      // ── Sell FAB ──────────────────────────────────────
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellPage()),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: accent,
          onRefresh: () async => _loadBooks(),
          child: CustomScrollView(
            slivers: [

              // ── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good morning',
                          style: TextStyle(fontSize: 13, color: context.textSecondary)),
                      const SizedBox(height: 2),
                      Text('Find your next read',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary)),
                    ],
                  ),
                ),
              ),

              // ── Search bar ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
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
                      cursorColor: accent,
                      decoration: InputDecoration(
                        hintText: 'Search books, authors…',
                        hintStyle:
                            TextStyle(fontSize: 13, color: context.textTertiary),
                        prefixIcon: Icon(Icons.search,
                            color: context.textTertiary, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Category chips ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final selected = _selectedCategory == _categories[i].name;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategory = _categories[i].name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? accent : context.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? accent
                                    : context.theme.dividerColor,
                                width: 1.5,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: accent.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3)),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _categories[i].icon,
                                  size: 14,
                                  color: selected ? Colors.white : accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _categories[i].name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Loading / error states ────────────────────────
              if (booksState.isLoading && booksState.books.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: accent),
                  ),
                )
              else if (booksState.error != null && booksState.books.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              size: 48, color: context.textTertiary),
                          const SizedBox(height: 12),
                          Text('Could not load books',
                              style: TextStyle(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                )
              else if (books.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                )
              else ...[
                // Trending section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Trending Books',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary)),
                      ],
                    ),
                  ),
                ),

                // Trending horizontal list
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: trending.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: 130,
                          child: BookCard(
                            book: trending[i],
                            onTap: () => BookDetailSheet.show(
                              context,
                              ref,
                              book: trending[i],
                              onBought: _loadBooks,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // All Listings header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('All Listings',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary)),
                      ],
                    ),
                  ),
                ),

                // All Listings grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => BookCard(
                        book: books[i],
                        onTap: () => BookDetailSheet.show(
                          context,
                          ref,
                          book: books[i],
                          onBought: _loadBooks,
                        ),
                      ),
                      childCount: books.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.66,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}