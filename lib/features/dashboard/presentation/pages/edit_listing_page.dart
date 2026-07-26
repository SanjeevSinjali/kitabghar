import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';

class EditListingPage extends ConsumerStatefulWidget {
  final BooksEntity book;

  const EditListingPage({super.key, required this.book});

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  static const _categoryList = [
    'Fiction',
    'Non-Fiction',
    'Academic',
    'Self-Help',
    'Biography',
    "Children's",
    'Comics',
    'Other',
  ];

  static const _conditionList = ['Like New', 'Good', 'Fair'];

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  String? _selectedCategory;
  String? _selectedCondition;
  File? _newImage;

  final _picker = ImagePicker();
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book.title);
    _authorController = TextEditingController(text: book.author);
    _priceController = TextEditingController(text: book.price);
    _descController = TextEditingController(text: book.description);
    _selectedCategory =
        _categoryList.contains(book.category) ? book.category : null;
    _selectedCondition =
        _conditionList.contains(book.condition) ? book.condition : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
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
              title: Text('Photo Library', style: TextStyle(color: ctx.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 85);
                if (picked != null) setState(() => _newImage = File(picked.path));
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: ctx.textPrimary),
              title: Text('Camera', style: TextStyle(color: ctx.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 85);
                if (picked != null) setState(() => _newImage = File(picked.path));
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final token = ref.read(authViewModelProvider).user?.token;
    final bookId = widget.book.id;
    if (token == null || bookId == null) return;

    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedCondition == null) {
      SnackbarUtils.showError(context, 'Please fill all required fields.');
      return;
    }

    setState(() => _isSaving = true);

    final error = await ref.read(booksViewModelProvider.notifier).updateBook(
          id: bookId,
          token: token,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          price: _priceController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          condition: _selectedCondition,
          image: _newImage,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      SnackbarUtils.showError(context, error);
      return;
    }

    SnackbarUtils.showSuccess(context, 'Listing updated successfully.');
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Listing', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${widget.book.title}"? This cannot be undone.',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = ref.read(authViewModelProvider).user?.token;
    final bookId = widget.book.id;
    if (token == null || bookId == null) return;

    setState(() => _isDeleting = true);
    await ref.read(booksViewModelProvider.notifier).deleteBook(id: bookId, token: token);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    final error = ref.read(booksViewModelProvider).error;
    if (error != null) {
      SnackbarUtils.showError(context, error);
      return;
    }

    SnackbarUtils.showSuccess(context, 'Listing deleted.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existingImageUrl = ApiEndpoints.bookImageUrl(widget.book.image);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        actions: [
          IconButton(
            icon: _isDeleting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.colors.error),
                  )
                : Icon(Icons.delete_outline_rounded, color: context.colors.error),
            tooltip: 'Delete listing',
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Cover image ──────────────────────────────
          GestureDetector(
            onTap: _pickNewImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_newImage != null)
                    Image.file(_newImage!, fit: BoxFit.cover)
                  else if (existingImageUrl.isNotEmpty)
                    Image.network(
                      existingImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                          Icons.menu_book_rounded,
                          size: 48,
                          color: context.textTertiary),
                    )
                  else
                    Icon(Icons.menu_book_rounded,
                        size: 48, color: context.textTertiary),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(context, 'Book title'),
          const SizedBox(height: 6),
          _buildField(context, _titleController, 'e.g. Clean Code'),
          const SizedBox(height: 14),

          _buildLabel(context, 'Author'),
          const SizedBox(height: 6),
          _buildField(context, _authorController, 'e.g. Robert C. Martin'),
          const SizedBox(height: 14),

          _buildLabel(context, 'Price (Rs.)'),
          const SizedBox(height: 6),
          _buildField(context, _priceController, 'e.g. 250',
              keyboardType: TextInputType.number),
          const SizedBox(height: 14),

          _buildLabel(context, 'Category'),
          const SizedBox(height: 6),
          _buildDropdown(
            context,
            value: _selectedCategory,
            hint: 'Select a category',
            items: _categoryList,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 14),

          _buildLabel(context, 'Condition'),
          const SizedBox(height: 6),
          _buildDropdown(
            context,
            value: _selectedCondition,
            hint: 'Select a condition',
            items: _conditionList,
            onChanged: (v) => setState(() => _selectedCondition = v),
          ),
          const SizedBox(height: 14),

          _buildLabel(context, 'Description'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 300,
              style: TextStyle(fontSize: 13, color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Write a short description about your book…',
                hintStyle: TextStyle(fontSize: 13, color: context.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 28),

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
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.textTertiary,
        ),
      );

  Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 13, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: context.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: context.textTertiary)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.textTertiary),
          dropdownColor: context.cardColor,
          style: TextStyle(fontSize: 13, color: context.textPrimary),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}