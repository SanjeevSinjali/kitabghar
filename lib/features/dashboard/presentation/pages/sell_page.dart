import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, openAppSettings, PermissionActions, PermissionStatusGetters;
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';

class SellPage extends ConsumerStatefulWidget {
  const SellPage({super.key});

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  static const _montserrat = 'Montserrat';

  static const _categoryList = [
    'Programming',
    'Algorithms',
    'Networking',
    'Design',
    'AI / ML',
    'Operating Systems',
    'Database',
    'Other',
  ];

  final _titleController  = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController  = TextEditingController();
  final _descController   = TextEditingController();
  String? _selectedCategory;
  File?   _pickedImage;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile != null) setState(() => _pickedImage = File(xfile.path));
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog('Photo library');
    }
  }

  Future<void> _pickFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (xfile != null) setState(() => _pickedImage = File(xfile.path));
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog('Camera');
    }
  }

  void _showSettingsDialog(String permission) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '$permission access needed',
          style: const TextStyle(
            fontFamily: _montserrat,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Please enable $permission access in Settings to continue.',
          style: const TextStyle(fontFamily: _montserrat, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF1D3A52),
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Photo library',
                  style: TextStyle(
                    fontFamily: _montserrat,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF1D3A52),
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Take a photo',
                  style: TextStyle(
                    fontFamily: _montserrat,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _pickedImage == null) {
      SnackbarUtils.showError(
          context, 'Please fill all fields and add a photo.');
      return;
    }

    final token = ref.read(authViewModelProvider).user?.token ?? '';

    if (token.isEmpty) {
      SnackbarUtils.showError(
          context, 'You must be logged in to list a book.');
      return;
    }

    await ref.read(booksViewModelProvider.notifier).createBook(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      price: _priceController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory!,
      token: token,
      image: _pickedImage,
    );

    final booksState = ref.read(booksViewModelProvider);

    if (booksState.isSuccess && mounted) {
      _titleController.clear();
      _authorController.clear();
      _priceController.clear();
      _descController.clear();
      setState(() {
        _selectedCategory = null;
        _pickedImage = null;
      });
      ref.read(booksViewModelProvider.notifier).resetState();
      SnackbarUtils.showSuccess(context, 'Book listed successfully!');
      Navigator.pop(context);
    } else if (booksState.error != null && mounted) {
      SnackbarUtils.showError(context, booksState.error!);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(booksViewModelProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1D3A52),
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Sell a Book',
          style: TextStyle(
            fontFamily: _montserrat,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D3A52),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [

          // ── Image picker ──────────────────────────────
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDDD8CF),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _pickedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_pickedImage!, fit: BoxFit.cover),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _pickedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D3A52)
                                .withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 32,
                            color: Color(0xFF1D3A52),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add book cover',
                          style: TextStyle(
                            fontFamily: _montserrat,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3A52),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Photo · Camera',
                          style: TextStyle(
                            fontFamily: _montserrat,
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Book title ────────────────────────────────
          _buildLabel('Book title'),
          const SizedBox(height: 6),
          _buildField(_titleController, 'e.g. Clean Code'),
          const SizedBox(height: 14),

          // ── Author ────────────────────────────────────
          _buildLabel('Author'),
          const SizedBox(height: 6),
          _buildField(_authorController, 'e.g. Robert C. Martin'),
          const SizedBox(height: 14),

          // ── Price ─────────────────────────────────────
          _buildLabel('Price (Rs.)'),
          const SizedBox(height: 6),
          _buildField(
            _priceController,
            'e.g. 250',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),

          // ── Category ──────────────────────────────────
          _buildLabel('Category'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0D8CC)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text(
                  'Select a category',
                  style: TextStyle(
                    fontFamily: _montserrat,
                    fontSize: 13,
                    color: Colors.black38,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black38,
                ),
                style: const TextStyle(
                  fontFamily: _montserrat,
                  fontSize: 13,
                  color: Color(0xFF1D3A52),
                ),
                items: _categoryList
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Description ───────────────────────────────
          _buildLabel('Description'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0D8CC)),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 300,
              style: const TextStyle(
                fontFamily: _montserrat,
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                hintText: 'Write a short description about your book…',
                hintStyle: TextStyle(
                  fontFamily: _montserrat,
                  fontSize: 13,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Submit ────────────────────────────────────
          GestureDetector(
            onTap: isLoading ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1D3A52),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'List my book',
                        style: TextStyle(
                          fontFamily: _montserrat,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: _montserrat,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D3A52),
        ),
      );

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0D8CC)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: _montserrat, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: _montserrat,
            fontSize: 13,
            color: Colors.black38,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}