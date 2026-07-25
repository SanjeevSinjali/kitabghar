import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/explore_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/homescreen_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/profile_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/add_to_cart.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/wish_list_page.dart';
import 'package:kitabghar/features/notifications/presentation/pages/notifications_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    ExploreScreen(),
    AddToCartScreen(),
    WishListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KitabGhar'),
        actions: [
          if (_currentIndex != 4)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: 'Notifications',
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
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}