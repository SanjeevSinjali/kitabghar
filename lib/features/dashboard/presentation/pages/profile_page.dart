import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/providers/avatar_provider.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/core/providers/theme_provider.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';
import 'package:kitabghar/features/notifications/presentation/pages/notifications_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(authViewModelProvider).user?.token;
      if (token != null && token.isNotEmpty) {
        ref.read(booksViewModelProvider.notifier).getMyBooks(token: token);
      }
    });
  }

  Future<void> _pickAvatar(String email) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: ctx.textPrimary),
              title: Text('Photo Library',
                  style: TextStyle(color: ctx.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  await ref
                      .read(avatarProvider.notifier)
                      .setAvatar(email, File(picked.path));
                  await ref.read(notificationsProvider.notifier).addNotification(
                        email,
                        title: 'Profile Updated',
                        message: 'Your profile picture has been updated.',
                        type: 'profile_updated',
                      );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: ctx.textPrimary),
              title: Text('Camera', style: TextStyle(color: ctx.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  await ref
                      .read(avatarProvider.notifier)
                      .setAvatar(email, File(picked.path));
                  await ref.read(notificationsProvider.notifier).addNotification(
                        email,
                        title: 'Profile Updated',
                        message: 'Your profile picture has been updated.',
                        type: 'profile_updated',
                      );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final booksState = ref.watch(booksViewModelProvider);
    final user = authState.user;
    final isDarkMode = ref.watch(themeModeProvider.notifier).isDarkMode;
    final avatarFile = ref.watch(avatarProvider);

    final myListings = booksState.myBooks;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 28),

          // ── Avatar ──────────────────────────────────────
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.15),
                  backgroundImage:
                      avatarFile != null ? FileImage(avatarFile) : null,
                  child: avatarFile == null
                      ? Icon(Icons.person_rounded,
                          size: 52, color: context.colors.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: user?.email != null
                        ? () => _pickAvatar(user!.email)
                        : null,
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
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
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
          _SectionLabel(label: 'My Listings'),
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
                  'No listings yet. Sell your first book!',
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
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final book = myListings[index];
                  return _ListingCard(book: book);
                },
              ),
            ),

          const SizedBox(height: 28),

          // ── Account ──────────────────────────────────────
          _SectionLabel(label: 'Account'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.manage_accounts_outlined,
              label: 'Manage Profile',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.security_outlined,
              label: 'Security & Privacy',
              onTap: () {},
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Preferences ──────────────────────────────────
          _SectionLabel(label: 'Preferences'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
            _SettingItem(
              icon: isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.dark_mode_outlined,
              label: 'Dark Mode',
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
              label: 'Language',
              trailing: Text(
                'English',
                style: TextStyle(color: context.textTertiary, fontSize: 13),
              ),
              onTap: () {},
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Support ──────────────────────────────────────
          _SectionLabel(label: 'Support'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.help_outline_rounded,
              label: 'Help Center',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.description_outlined,
              label: 'Terms & Policies',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.info_outline_rounded,
              label: 'About Us',
              onTap: () {},
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Logout ─────────────────────────────────────
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              iconColor: context.colors.error,
              labelColor: context.colors.error,
              onTap: () {
                _confirmLogout(context, ref, user?.email);
              },
              isLast: true,
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, String? email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
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
            child: Text('Log Out', style: TextStyle(color: context.colors.error)),
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
    return Container(
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
                    errorBuilder: (_, _, _) => _placeholder(context),
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