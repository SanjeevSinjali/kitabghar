import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/localization/app_strings.dart';
import 'package:kitabghar/core/providers/locale_provider.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/features/chatbot/presentation/widgets/chatbot_panel.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/explore_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/homescreen_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/profile_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/purchases_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/sell_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/wish_list_page.dart';
import 'package:kitabghar/features/notifications/presentation/pages/notifications_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;
  bool _fabExpanded = false;

  final List<Widget> _tabs = const [
    HomeScreen(),
    ExploreScreen(),
    PurchasesScreen(),
    WishListScreen(),
    ProfileScreen(),
  ];

  void _closeFabMenu() {
    if (_fabExpanded) setState(() => _fabExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final locale = ref.watch(localeProvider);
    String t(String key) => AppStrings.of(key, locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_name')),
        actions: [
          if (_currentIndex != 4)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: t('notifications'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.cardColor,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _fabExpanded ? 1 : 0,
              child: !_fabExpanded
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentIndex == 0) ...[
                          _MiniFabButton(
                            icon: Icons.add_rounded,
                            backgroundColor: accent,
                            label: 'Sell',
                            onTap: () {
                              _closeFabMenu();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SellPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        _MiniFabButton(
                          icon: Icons.chat_bubble_rounded,
                          backgroundColor: const Color(0xFF1E3A5F),
                          label: 'Chat',
                          onTap: () {
                            _closeFabMenu();
                            ChatbotPanel.show(context);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _fabExpanded = !_fabExpanded),
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
              child: AnimatedRotation(
                turns: _fabExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _fabExpanded
                      ? Icons.close_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _closeFabMenu,
        behavior: HitTestBehavior.translucent,
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          _fabExpanded = false;
        }),
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.cardColor,
        selectedItemColor: accent,
        unselectedItemColor: context.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: t('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: t('nav_explore'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: t('nav_purchases'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: t('nav_favourite'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: t('nav_profile'),
          ),
        ],
      ),
    );
  }
}

/// A small circular action button used inside the expandable FAB menu,
/// with a text label to its left so it's clear what each one does.
class _MiniFabButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  const _MiniFabButton({
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}