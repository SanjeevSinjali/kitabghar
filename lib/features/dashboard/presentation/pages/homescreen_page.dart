import 'package:flutter/material.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/sell_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    _Category('All', Icons.apps_rounded),
    _Category('Programming', Icons.code_rounded),
    _Category('Algorithms', Icons.account_tree_rounded),
    _Category('Networking', Icons.lan_rounded),
    _Category('Design', Icons.palette_rounded),
    _Category('AI / ML', Icons.psychology_rounded),
  ];

  int _selectedCategory = 0;

  static const _books = [
    _Book('Clean Code', 'Robert C.Martin', 'Rs. 250', '4.8', 'assets/images/book_1.jpg'),
    _Book('Introduction to Algorithm', 'Thomas H.Cormen', 'Rs. 150', '4.7', 'assets/images/book_2.jpg'),
    _Book('Computer Networking', 'James F.Kurose', 'Rs. 300', '4.9', 'assets/images/book_3.jpg'),
    _Book('Design Pattern', 'Eric Gamma', 'Rs. 220', '4.6', 'assets/images/book_4.jpg'),
    _Book('The Pragmatic Programmer', 'Andrew Hunt & David Thomas', 'Rs. 120', '4.8', 'assets/images/book_5.jpg'),
    _Book('Database System Concept', 'S.Sudarshan & Henry K.Korth', 'Rs. 180', '4.5', 'assets/images/book_6.jpg'),
    _Book('Operating System Concepts', 'James Peterson & Abraham Silberschatz', 'Rs. 200', '4.7', 'assets/images/book_7.jpg'),
    _Book('Artificial Intelligence', 'Stuart Russell & Peter Norvig', 'Rs. 160', '4.6', 'assets/images/book_8.jpg'),
    _Book('You Don\'t Know JS Yet', 'Kyle Simpson', 'Rs. 270', '4.5', 'assets/images/book_9.jpg'),
    _Book('Code Complete', 'Steve McConnell', 'Rs. 190', '4.7', 'assets/images/book_10.jpg'),
  ];

  // Light-mode tint backgrounds behind the book cover art.
  // In dark mode these are dimmed down so they don't glow against
  // a near-black page.
  static const _cardColorsLight = [
    Color(0xFFE8F0F7),
    Color(0xFFFFF3E8),
    Color(0xFFEAF7EE),
    Color(0xFFF7EAF0),
    Color(0xFFF0F0F7),
    Color(0xFFFFF8E1),
    Color(0xFFE8F7F0),
    Color(0xFFF7F0E8),
    Color(0xFFEEF0F7),
    Color(0xFFF7EEF0),
  ];

  static const _cardColorsDark = [
    Color(0xFF2A3A47),
    Color(0xFF473C2A),
    Color(0xFF2A472F),
    Color(0xFF472A3A),
    Color(0xFF2E2E47),
    Color(0xFF473F2A),
    Color(0xFF2A4740),
    Color(0xFF473F2A),
    Color(0xFF2E2A47),
    Color(0xFF472A2E),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    final cardColors = context.isDarkMode ? _cardColorsDark : _cardColorsLight;

    return Scaffold(
      backgroundColor: context.backgroundColor,

      // ── Round + FAB ──────────────────────────────────────
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
        child: CustomScrollView(
          slivers: [

            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning 👋',
                            style: TextStyle(
                                fontSize: 13, color: context.textSecondary)),
                        const SizedBox(height: 2),
                        Text('Find your next read',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary)),
                      ],
                    ),
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
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    cursorColor: accent,
                    decoration: InputDecoration(
                      filled: false,
                      hintText: 'Search books, authors…',
                      hintStyle:
                          TextStyle(fontSize: 13, color: context.textTertiary),
                      prefixIcon:
                          Icon(Icons.search, color: context.textTertiary, size: 20),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune,
                            color: Colors.white, size: 16),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
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
                      final selected = _selectedCategory == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = i),
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

            // Trending section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text('See all',
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondary)),
                    ),
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
                  itemCount: _books.length,
                  itemBuilder: (_, i) => _TrendingCard(
                    book: _books[i],
                    color: cardColors[i],
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
            // ↓ padding bottom changed to 100 so FAB doesn't cover last card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _GridBookCard(
                    book: _books[i % _books.length],
                    color: cardColors[i % cardColors.length],
                  ),
                  childCount: _books.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.70,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────
class _Book {
  final String title, author, price, rating, image;
  const _Book(this.title, this.author, this.price, this.rating, this.image);
}

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}

// ── Trending card ─────────────────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final _Book book;
  final Color color;
  const _TrendingCard({required this.book, required this.color});

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14),
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
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 120,
              color: color,
              child: Image.asset(
                book.image,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Icon(Icons.menu_book_rounded,
                      size: 48, color: accent.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary)),
                const SizedBox(height: 2),
                Text(book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: context.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(book.price,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFA726)),
                        const SizedBox(width: 2),
                        Text(book.rating,
                            style: TextStyle(
                                fontSize: 10, color: context.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid card ─────────────────────────────────────────────────
class _GridBookCard extends StatelessWidget {
  final _Book book;
  final Color color;
  const _GridBookCard({required this.book, required this.color});

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    return Container(
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
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: color,
                child: Image.asset(
                  book.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(Icons.menu_book_rounded,
                        size: 48, color: accent.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary)),
                const SizedBox(height: 2),
                Text(book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: context.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(book.price,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}