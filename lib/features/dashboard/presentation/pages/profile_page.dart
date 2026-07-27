import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/localization/app_strings.dart';
import 'package:kitabghar/core/providers/light_sensor_provider.dart';
import 'package:kitabghar/core/providers/locale_provider.dart';
import 'package:kitabghar/core/providers/theme_provider.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/edit_listing_page.dart';
import 'package:kitabghar/features/notifications/presentation/pages/notifications_page.dart';
import 'package:kitabghar/features/profile/presentation/pages/manage_profile_page.dart';
import 'package:kitabghar/features/profile/presentation/pages/security_privacy_page.dart';
import 'package:kitabghar/features/profile/presentation/view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(authViewModelProvider).user?.token;
      if (token != null && token.isNotEmpty) {
        ref.read(booksViewModelProvider.notifier).getMyBooks(token: token);
        // Loads the real, server-stored avatar (and name/email) — this is
        // what makes the photo persist across logout/login and reinstalls,
        // since it's fetched fresh from the backend every time this page
        // opens, rather than read from local-only device storage.
        ref.read(profileViewModelProvider.notifier).getProfile(token: token);
      }
    });
  }

  void _openManageProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageProfilePage()),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppLocale locale) {
    String t(String key) => AppStrings.of(key, locale);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('select_language'), style: TextStyle(color: context.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppLocale>(
              value: AppLocale.en,
              groupValue: locale,
              title: Text(t('english'), style: TextStyle(color: context.textPrimary)),
              activeColor: context.colors.primary,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(AppLocale.en);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<AppLocale>(
              value: AppLocale.ne,
              groupValue: locale,
              title: Text(t('nepali'), style: TextStyle(color: context.textPrimary)),
              activeColor: context.colors.primary,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(AppLocale.ne);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final booksState = ref.watch(booksViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final user = authState.user;
    final profile = profileState.profile;
    final isDarkMode = ref.watch(themeModeProvider.notifier).isDarkMode;
    final locale = ref.watch(localeProvider);
    String t(String key) => AppStrings.of(key, locale);

    final myListings = booksState.myBooks;
    final avatarUrl = ApiEndpoints.avatarUrl(profile?.avatar);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t('profile_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 28),

          // ── Avatar ──────────────────────────────────────
          // Tapping it takes you to Manage Profile — the single place to
          // actually change your photo, avoiding two separate upload flows.
          Center(
            child: GestureDetector(
              onTap: _openManageProfile,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        context.colors.primary.withValues(alpha: 0.15),
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Icon(Icons.person_rounded,
                            size: 52, color: context.colors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.backgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Name & Email ─────────────────────────────────
          Center(
            child: Text(
              user?.name ?? 'User Name',
              style: context.textStyles.titleLarge?.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.email ?? 'username@mail.com',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ),

          const SizedBox(height: 32),

          // ── My Listings ──────────────────────────────────
          _SectionLabel(label: t('my_listings')),
          const SizedBox(height: 12),

          if (myListings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  t('no_listings'),
                  style: TextStyle(color: context.textTertiary, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 175,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: myListings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final book = myListings[index];
                  return _ListingCard(book: book);
                },
              ),
            ),

          const SizedBox(height: 28),

          // ── Account ──────────────────────────────────────
          _SectionLabel(label: t('account')),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.manage_accounts_outlined,
              label: t('manage_profile'),
              onTap: _openManageProfile,
            ),
            _SettingItem(
              icon: Icons.security_outlined,
              label: t('security_privacy'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityPrivacyPage()),
                );
              },
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Preferences ──────────────────────────────────
          _SectionLabel(label: t('preferences')),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.notifications_none_rounded,
              label: t('notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
            _SettingItem(
              icon: Icons.brightness_auto_rounded,
              label: t('auto_brightness'),
              trailing: Switch(
                value: ref.watch(autoLightProvider),
                onChanged: (_) {
                  ref.read(autoLightProvider.notifier).toggle();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onTap: () {
                ref.read(autoLightProvider.notifier).toggle();
              },
            ),
            _SettingItem(
              icon: isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.dark_mode_outlined,
              label: t('dark_mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setDarkMode(value);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).toggle();
              },
            ),
            _SettingItem(
              icon: Icons.translate_rounded,
              label: t('language'),
              trailing: Text(
                locale == AppLocale.ne ? t('nepali') : t('english'),
                style: TextStyle(color: context.textTertiary, fontSize: 13),
              ),
              onTap: () => _showLanguagePicker(context, ref, locale),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Support ──────────────────────────────────────
          _SectionLabel(label: t('support')),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.help_outline_rounded,
              label: t('help_center'),
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.description_outlined,
              label: t('terms_policies'),
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.info_outline_rounded,
              label: t('about_us'),
              onTap: () {},
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Logout ─────────────────────────────────────
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.logout_rounded,
              label: t('log_out'),
              iconColor: context.colors.error,
              labelColor: context.colors.error,
              onTap: () {
                _confirmLogout(context, ref, user?.email, locale);
              },
              isLast: true,
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmLogout(
      BuildContext context, WidgetRef ref, String? email, AppLocale locale) {
    String t(String key) => AppStrings.of(key, locale);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('log_out'), style: TextStyle(color: context.textPrimary)),
        content: Text(
          t('log_out_confirm_message'),
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel'), style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (email != null) {
                ref.read(authViewModelProvider.notifier).logout(email);
              }
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text(t('log_out'), style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.textTertiary,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ── Settings Group ────────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: items),
    );
  }
}

// ── Setting Item ──────────────────────────────────────────────────────────────
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
    this.isLast = false,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: iconColor ?? context.textPrimary, size: 22),
          title: Text(
            label,
            style: TextStyle(
              color: labelColor ?? context.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: context.textTertiary, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          dense: true,
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, indent: 52),
      ],
    );
  }
}

// ── Listing Card ──────────────────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final BooksEntity book;
  const _ListingCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.bookImageUrl(book.image);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditListingPage(book: book)),
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: context.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${book.price}',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
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
      height: 100,
      width: 120,
      color: context.isDarkMode
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFF0F0F0),
      child: Icon(Icons.book_rounded, color: context.textTertiary, size: 36),
    );
  }
}