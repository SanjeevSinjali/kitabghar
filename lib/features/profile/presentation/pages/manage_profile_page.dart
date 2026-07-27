import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/profile/presentation/view_model/profile_view_model.dart';

class ManageProfilePage extends ConsumerStatefulWidget {
  const ManageProfilePage({super.key});

  @override
  ConsumerState<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends ConsumerState<ManageProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();

  File? _pickedAvatar;
  bool _controllersInitialized = false;
  bool _isSaving = false;

  String? get _token => ref.read(authViewModelProvider).user?.token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = _token;
      if (token != null) {
        ref.read(profileViewModelProvider.notifier).getProfile(token: token);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
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
                  source: ImageSource.gallery,
                  imageQuality: 50,
                  maxWidth: 800,
                );
                if (picked != null) {
                  setState(() => _pickedAvatar = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: ctx.textPrimary),
              title: Text('Camera', style: TextStyle(color: ctx.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                  maxWidth: 800,
                );
                if (picked != null) {
                  setState(() => _pickedAvatar = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final token = _token;
    if (token == null) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      SnackbarUtils.showError(context, 'Name and email cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    final error = await ref.read(profileViewModelProvider.notifier).updateProfile(
          token: token,
          name: name,
          email: email,
          avatar: _pickedAvatar,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      SnackbarUtils.showError(context, error);
      return;
    }

    // Keep the rest of the app (Profile page header, etc.) in sync
    // immediately, without requiring a re-login.
    ref.read(authViewModelProvider.notifier).updateLocalUser(name: name, email: email);

    setState(() => _pickedAvatar = null);
    SnackbarUtils.showSuccess(context, 'Profile updated successfully.');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final profile = profileState.profile;

    // Populate the text fields once, the first time the profile loads —
    // don't overwrite the user's in-progress edits on every rebuild.
    if (profile != null && !_controllersInitialized) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _controllersInitialized = true;
    }

    final avatarUrl = ApiEndpoints.avatarUrl(profile?.avatar);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(title: const Text('Manage Profile')),
      body: profileState.isLoading && profile == null
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Avatar ──────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            context.colors.primary.withValues(alpha: 0.15),
                        backgroundImage: _pickedAvatar != null
                            ? FileImage(_pickedAvatar!)
                            : (avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl) as ImageProvider
                                : null),
                        child: _pickedAvatar == null && avatarUrl.isEmpty
                            ? Icon(Icons.person_rounded,
                                size: 52, color: context.colors.primary)
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

                const SizedBox(height: 32),

                // ── Name ──────────────────────────────────────
                Text('Full Name',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.textTertiary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: context.textTertiary),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────────
                Text('Email',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.textTertiary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        color: context.textTertiary),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Save ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}