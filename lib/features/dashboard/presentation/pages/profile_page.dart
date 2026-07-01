import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfileScreen> {
  static const _montserrat = 'Montserrat';
  File? _avatarImage;
  final _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Colors.black87),
              title: Text('Photo Library',
                  style: TextStyle(
                      fontFamily: _montserrat, color: Colors.black87)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  setState(() => _avatarImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: Colors.black87),
              title: Text('Camera',
                  style: TextStyle(
                      fontFamily: _montserrat, color: Colors.black87)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  setState(() => _avatarImage = File(picked.path));
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

    final myListings = booksState.books
        .where((b) => b.sellerId != null && b.sellerId == user?.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontFamily: _montserrat,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
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
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : null,
                  child: _avatarImage == null
                      ? const Icon(Icons.person_rounded,
                          size: 52, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
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
              style: TextStyle(
                color: Colors.black,
                fontFamily: _montserrat,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.email ?? 'username@mail.com',
              style: TextStyle(
                color: Colors.black54,
                fontFamily: _montserrat,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── My Listings ──────────────────────────────────
          _SectionLabel(label: 'My Listings', montserrat: _montserrat),
          const SizedBox(height: 12),

          if (myListings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'No listings yet. Sell your first book!',
                  style: TextStyle(
                    color: Colors.black38,
                    fontFamily: _montserrat,
                    fontSize: 13,
                  ),
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
                  return _ListingCard(
                      book: book, montserrat: _montserrat);
                },
              ),
            ),

          const SizedBox(height: 28),

          // ── Account ──────────────────────────────────────
          _SectionLabel(label: 'Account', montserrat: _montserrat),
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
          _SectionLabel(label: 'Preferences', montserrat: _montserrat),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeThumbColor: Colors.black87,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.translate_rounded,
              label: 'Language',
              trailing: Text(
                'English',
                style: TextStyle(
                    color: Colors.black38,
                    fontFamily: _montserrat,
                    fontSize: 13),
              ),
              onTap: () {},
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Support ──────────────────────────────────────
          _SectionLabel(label: 'Support', montserrat: _montserrat),
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final String montserrat;
  const _SectionLabel({required this.label, required this.montserrat});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.black45,
        fontFamily: montserrat,
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
        color: Colors.white,
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

  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: Colors.black87, size: 22),
          title: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.black38, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          dense: true,
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFEEEEEE),
            indent: 52,
          ),
      ],
    );
  }
}

// ── Listing Card ──────────────────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final dynamic book;
  final String montserrat;
  const _ListingCard({required this.book, required this.montserrat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
            child: book.coverImage != null
                ? Image.network(
                    'http://192.168.18.118:5000/${book.coverImage}',
                    height: 100,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: montserrat,
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
                    color: Colors.black54,
                    fontFamily: montserrat,
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

  Widget _placeholder() {
    return Container(
      height: 100,
      width: 120,
      color: const Color(0xFFF0F0F0),
      child: const Icon(Icons.book_rounded, color: Colors.black12, size: 36),
    );
  }
}